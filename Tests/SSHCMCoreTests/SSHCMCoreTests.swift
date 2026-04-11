import XCTest
@testable import SSHCMCore

final class SSHCMCoreTests: XCTestCase {
    func testParserUnderstandsMetadataAndForwards() throws {
        let content = """
        # sshcm:begin
        # sshcm: {"group":"prod","tags":["db","cn"],"managed":true}
        # sshcm:end
        Host prod-db
            HostName 10.0.0.10
            User ubuntu
            Port 22
            IdentityFile ~/.ssh/id_ed25519
            ProxyJump bastion1,bastion2
            ProxyCommand ssh proxy -W %h:%p 2>/dev/null
            LocalForward 127.0.0.1:5432 127.0.0.1:5432
            DynamicForward 1080
            Compression yes
        """

        let parser = SSHConfigParser()
        let doc = try parser.parse(content: content)

        XCTAssertEqual(doc.hosts.count, 1)
        let host = try XCTUnwrap(doc.hosts.first)
        XCTAssertEqual(host.primaryAlias, "prod-db")
        XCTAssertEqual(host.metadata.group, "prod")
        XCTAssertEqual(host.metadata.tags, ["db", "cn"])
        XCTAssertEqual(host.proxyJump, "bastion1,bastion2")
        XCTAssertEqual(host.proxyCommand, "ssh proxy -W %h:%p 2>/dev/null")
        XCTAssertEqual(host.forwards.count, 2)
        XCTAssertEqual(host.extraDirectives, [SSHDirective(key: "Compression", value: "yes")])

        let output = SSHConfigFormatter().formatHosts(doc.hosts)
        XCTAssertTrue(output.contains("# sshcm:begin"))
        XCTAssertTrue(output.contains("ProxyJump bastion1,bastion2"))
        XCTAssertTrue(output.contains("ProxyCommand ssh proxy -W %h:%p 2>/dev/null"))
        XCTAssertTrue(output.contains("DynamicForward 1080"))
    }

    func testParserDefaultsMetadataWhenCommentIsMissing() throws {
        let content = """
        Host plain
            HostName plain.internal
        """

        let doc = try SSHConfigParser().parse(content: content)
        let host = try XCTUnwrap(doc.hosts.first)
        XCTAssertEqual(host.metadata.group, "ungrouped")
        XCTAssertTrue(host.metadata.tags.isEmpty)
        XCTAssertTrue(host.metadata.managed)
    }

    func testParserKeepsMetadataForMultipleHostsInOneFile() throws {
        let content = """
        # sshcm:begin
        # sshcm: {"group":"g1","tags":[],"managed":true}
        # sshcm:end
        Host h1
            HostName 10.0.0.1

        # sshcm:begin
        # sshcm: {"group":"g2","tags":[],"managed":true}
        # sshcm:end
        Host h2
            HostName 10.0.0.2
        """

        let doc = try SSHConfigParser().parse(content: content)
        XCTAssertEqual(doc.hosts.count, 2)
        XCTAssertEqual(doc.hosts[0].primaryAlias, "h1")
        XCTAssertEqual(doc.hosts[0].metadata.group, "g1")
        XCTAssertEqual(doc.hosts[1].primaryAlias, "h2")
        XCTAssertEqual(doc.hosts[1].metadata.group, "g2")
    }

    func testStoreSaveCreatesManagedLayoutAndBackup() throws {
        let root = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let sshDir = root.appendingPathComponent(".ssh", isDirectory: true)
        try FileManager.default.createDirectory(at: sshDir, withIntermediateDirectories: true)

        let oldConfig = """
        Host old
            HostName old.example.com
            User root
        """
        let configURL = sshDir.appendingPathComponent("config")
        try oldConfig.write(to: configURL, atomically: true, encoding: .utf8)

        let store = SSHConfigStore(sshDirectory: sshDir)
        let imported = try store.loadDocument()
        XCTAssertEqual(imported.hosts.count, 1)

        var hosts = imported.hosts
        hosts.append(
            SSHHostEntry(
                aliases: ["prod-db"],
                hostName: "10.0.0.10",
                user: "ubuntu",
                port: 22,
                identityFile: "~/.ssh/id_ed25519",
                proxyJump: "bastion",
                forwards: [SSHPortForward(type: .local, spec: "127.0.0.1:5432 127.0.0.1:5432")],
                metadata: SSHHostMetadata(group: "prod", tags: ["db"], managed: true)
            )
        )

        let result = try store.save(document: SSHConfigDocument(globalDirectives: [SSHDirective(key: "ServerAliveInterval", value: "30")], hosts: hosts))
        XCTAssertNotNil(result.backupURL)

        let mainConfig = try String(contentsOf: store.configFileURL, encoding: .utf8)
        XCTAssertTrue(mainConfig.contains("Include ~/.ssh/config.d/*.conf"))

        let managedFiles = try FileManager.default.contentsOfDirectory(at: store.configDirectoryURL, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "conf" }
            .map(\.lastPathComponent)
            .sorted()

        XCTAssertTrue(managedFiles.contains("00-globals.conf"))
        XCTAssertTrue(managedFiles.contains(where: { $0.contains("prod") }))

        let before = try snapshotFileContents(in: store.configDirectoryURL)
        _ = try store.save(document: SSHConfigDocument(globalDirectives: [SSHDirective(key: "ServerAliveInterval", value: "30")], hosts: hosts))
        let after = try snapshotFileContents(in: store.configDirectoryURL)
        XCTAssertEqual(before, after)

        let backups = try FileManager.default.contentsOfDirectory(at: store.backupDirectoryURL, includingPropertiesForKeys: nil)
        XCTAssertFalse(backups.isEmpty)
    }

    func testStoreFiltersManagedIncludeFromGlobalsToAvoidRecursion() throws {
        let root = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let sshDir = root.appendingPathComponent(".ssh", isDirectory: true)
        try FileManager.default.createDirectory(at: sshDir, withIntermediateDirectories: true)

        let store = SSHConfigStore(sshDirectory: sshDir)
        let managedInclude = "\(store.configDirectoryURL.path)/*.conf"
        let doc = SSHConfigDocument(
            globalDirectives: [
                SSHDirective(key: "Include", value: managedInclude),
                SSHDirective(key: "Include", value: "/tmp/sshcm-extra.conf"),
                SSHDirective(key: "ServerAliveInterval", value: "30")
            ],
            hosts: [
                SSHHostEntry(aliases: ["demo"], hostName: "demo.local", metadata: SSHHostMetadata(group: "test", tags: [], managed: true))
            ]
        )

        _ = try store.save(document: doc)
        let globalsURL = store.configDirectoryURL.appendingPathComponent("00-globals.conf")
        let globals = try String(contentsOf: globalsURL, encoding: .utf8)

        XCTAssertFalse(globals.contains("Include \(managedInclude)"))
        XCTAssertTrue(globals.contains("Include /tmp/sshcm-extra.conf"))
        XCTAssertTrue(globals.contains("ServerAliveInterval 30"))
    }

    func testStoreFiltersMainConfigIncludeFromGlobalsToAvoidRecursion() throws {
        let root = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let sshDir = root.appendingPathComponent(".ssh", isDirectory: true)
        try FileManager.default.createDirectory(at: sshDir, withIntermediateDirectories: true)

        let store = SSHConfigStore(sshDirectory: sshDir)
        let doc = SSHConfigDocument(
            globalDirectives: [
                SSHDirective(key: "Include", value: "~/.ssh/config"),
                SSHDirective(key: "Include", value: "/tmp/another.conf"),
            ],
            hosts: [
                SSHHostEntry(aliases: ["demo"], hostName: "demo.local", metadata: SSHHostMetadata(group: "test", tags: [], managed: true))
            ]
        )

        _ = try store.save(document: doc)
        let globalsURL = store.configDirectoryURL.appendingPathComponent("00-globals.conf")
        let globals = try String(contentsOf: globalsURL, encoding: .utf8)

        XCTAssertFalse(globals.contains("Include ~/.ssh/config"))
        XCTAssertTrue(globals.contains("Include /tmp/another.conf"))
    }

    func testFindHostsMatchesAliasThenTag() {
        let store = SSHConfigStore(sshDirectory: URL(fileURLWithPath: "/tmp/sshcm-test"))
        let hosts = [
            SSHHostEntry(aliases: ["prod-api"], hostName: "prod-api.local", metadata: SSHHostMetadata(group: "prod", tags: ["api"], managed: true)),
            SSHHostEntry(aliases: ["dev-api"], hostName: "dev-api.local", metadata: SSHHostMetadata(group: "dev", tags: ["api"], managed: true))
        ]

        let alias = store.findHosts(matching: "prod-api", in: hosts)
        XCTAssertEqual(alias.count, 1)
        XCTAssertEqual(alias.first?.primaryAlias, "prod-api")

        let byTag = store.findHosts(matching: "api", in: hosts)
        XCTAssertEqual(byTag.count, 2)
    }

    func testKeyManagerListsExistingKeys() throws {
        let root = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let sshDir = root.appendingPathComponent(".ssh", isDirectory: true)
        try FileManager.default.createDirectory(at: sshDir, withIntermediateDirectories: true)

        try "private".write(to: sshDir.appendingPathComponent("id_test"), atomically: true, encoding: .utf8)
        try "public".write(to: sshDir.appendingPathComponent("id_test.pub"), atomically: true, encoding: .utf8)
        try "private2".write(to: sshDir.appendingPathComponent("custom_key"), atomically: true, encoding: .utf8)
        try "public2".write(to: sshDir.appendingPathComponent("custom_key.pub"), atomically: true, encoding: .utf8)
        try "host".write(to: sshDir.appendingPathComponent("known_hosts"), atomically: true, encoding: .utf8)
        try "cfg".write(to: sshDir.appendingPathComponent("config"), atomically: true, encoding: .utf8)

        let manager = SSHKeyManager(sshDirectory: sshDir)
        let keys = try manager.listLocalKeys()

        XCTAssertTrue(keys.contains(where: { $0.name == "id_test" }))
        XCTAssertFalse(keys.contains(where: { $0.name == "custom_key" }))
        XCTAssertFalse(keys.contains(where: { $0.name == "known_hosts" }))
        XCTAssertFalse(keys.contains(where: { $0.name == "config" }))
    }

    private func makeTempDirectory() throws -> URL {
        let base = FileManager.default.temporaryDirectory
        let url = base.appendingPathComponent("sshcm-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func snapshotFileContents(in directory: URL) throws -> [String: String] {
        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "conf" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        var snapshot: [String: String] = [:]
        for file in files {
            snapshot[file.lastPathComponent] = try String(contentsOf: file, encoding: .utf8)
        }
        return snapshot
    }
}
