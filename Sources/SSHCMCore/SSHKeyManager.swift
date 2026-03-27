import Foundation

public struct SSHLocalKey: Identifiable, Hashable, Sendable {
    public var id: String { name }
    public var name: String
    public var privateKeyPath: String?
    public var publicKeyPath: String?
    public var fingerprint: String?

    public init(name: String, privateKeyPath: String?, publicKeyPath: String?, fingerprint: String?) {
        self.name = name
        self.privateKeyPath = privateKeyPath
        self.publicKeyPath = publicKeyPath
        self.fingerprint = fingerprint
    }
}

public struct KeyDoctorResult: Sendable {
    public var scannedFiles: Int
    public var fixedPermissions: [URL]
    public var sshAgentReachable: Bool
    public var sshAddOutput: String

    public init(scannedFiles: Int, fixedPermissions: [URL], sshAgentReachable: Bool, sshAddOutput: String) {
        self.scannedFiles = scannedFiles
        self.fixedPermissions = fixedPermissions
        self.sshAgentReachable = sshAgentReachable
        self.sshAddOutput = sshAddOutput
    }
}

public final class SSHKeyManager {
    private let fileManager: FileManager
    private let processRunner: ProcessRunner
    private let sshDirectory: URL

    public init(
        sshDirectory: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".ssh", isDirectory: true),
        fileManager: FileManager = .default,
        processRunner: ProcessRunner = ProcessRunner()
    ) {
        self.sshDirectory = sshDirectory
        self.fileManager = fileManager
        self.processRunner = processRunner
    }

    @discardableResult
    public func generateKeyPair(name: String, type: String = "ed25519", comment: String? = nil) throws -> URL {
        try ensureSSHDirectory()
        let privateKeyURL = sshDirectory.appendingPathComponent(name)
        let comment = comment ?? "sshcm@\(Host.current().localizedName ?? "mac")"

        let args = ["-t", type, "-f", privateKeyURL.path, "-N", "", "-C", comment]
        if fileManager.fileExists(atPath: privateKeyURL.path) {
            throw SSHCMError.ioError("Key already exists at \(privateKeyURL.path)")
        }

        _ = try processRunner.run(executable: "/usr/bin/ssh-keygen", arguments: args)
        try fixKeyPermission(for: privateKeyURL, isPublic: false)
        let pub = URL(fileURLWithPath: privateKeyURL.path + ".pub")
        if fileManager.fileExists(atPath: pub.path) {
            try fixKeyPermission(for: pub, isPublic: true)
        }
        return privateKeyURL
    }

    @discardableResult
    public func importPrivateKey(from source: URL, as name: String? = nil) throws -> URL {
        try ensureSSHDirectory()
        guard fileManager.fileExists(atPath: source.path) else {
            throw SSHCMError.ioError("Source key does not exist: \(source.path)")
        }

        let targetName = name ?? source.lastPathComponent
        let target = sshDirectory.appendingPathComponent(targetName)
        if source.standardizedFileURL != target.standardizedFileURL {
            if fileManager.fileExists(atPath: target.path) {
                throw SSHCMError.ioError("Target already exists: \(target.path)")
            }
            try fileManager.copyItem(at: source, to: target)
        }

        try fixKeyPermission(for: target, isPublic: false)
        let sourcePub = URL(fileURLWithPath: source.path + ".pub")
        let targetPub = URL(fileURLWithPath: target.path + ".pub")
        if fileManager.fileExists(atPath: sourcePub.path), !fileManager.fileExists(atPath: targetPub.path) {
            try fileManager.copyItem(at: sourcePub, to: targetPub)
        }
        if fileManager.fileExists(atPath: targetPub.path) {
            try fixKeyPermission(for: targetPub, isPublic: true)
        }

        return target
    }

    @discardableResult
    public func addKeyToAgent(_ keyURL: URL, useKeychain: Bool) throws -> String {
        var args: [String] = []
        if useKeychain {
            args.append("--apple-use-keychain")
        }
        args.append(keyURL.path)

        do {
            let result = try processRunner.run(executable: "/usr/bin/ssh-add", arguments: args)
            return result.combinedOutput
        } catch {
            if useKeychain {
                let fallback = try processRunner.run(executable: "/usr/bin/ssh-add", arguments: ["-K", keyURL.path])
                return fallback.combinedOutput
            }
            throw error
        }
    }

    public func doctorKeys() throws -> KeyDoctorResult {
        try ensureSSHDirectory()
        let items = try fileManager.contentsOfDirectory(at: sshDirectory, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])

        var fixed: [URL] = []
        for item in items {
            let values = try item.resourceValues(forKeys: [.isDirectoryKey])
            if values.isDirectory == true { continue }

            if item.lastPathComponent == "config" || item.lastPathComponent == "known_hosts" {
                continue
            }
            let isPublic = item.pathExtension == "pub"
            if try fixKeyPermission(for: item, isPublic: isPublic) {
                fixed.append(item)
            }
        }

        let agentResult = try processRunner.run(executable: "/usr/bin/ssh-add", arguments: ["-l"], allowNonZeroExit: true)
        let reachable = agentResult.status == 0 || agentResult.stderr.lowercased().contains("no identities")

        return KeyDoctorResult(
            scannedFiles: items.count,
            fixedPermissions: fixed.sorted { $0.path < $1.path },
            sshAgentReachable: reachable,
            sshAddOutput: agentResult.combinedOutput
        )
    }

    public func listLocalKeys() throws -> [SSHLocalKey] {
        try ensureSSHDirectory()
        let excluded: Set<String> = [
            "config",
            "known_hosts",
            "known_hosts.old",
            "authorized_keys",
            "authorized_keys2",
            "environment"
        ]

        let items = try fileManager.contentsOfDirectory(
            at: sshDirectory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        var pairs: [String: (privateKey: URL?, publicKey: URL?)] = [:]

        for item in items {
            let values = try item.resourceValues(forKeys: [.isDirectoryKey])
            if values.isDirectory == true { continue }

            let name = item.lastPathComponent
            if excluded.contains(name) { continue }

            if name.hasSuffix(".pub") {
                let base = String(name.dropLast(4))
                guard base.hasPrefix("id_") else { continue }
                var pair = pairs[base] ?? (nil, nil)
                pair.publicKey = item
                pairs[base] = pair
            } else {
                guard name.hasPrefix("id_") else { continue }
                var pair = pairs[name] ?? (nil, nil)
                pair.privateKey = item
                pairs[name] = pair
            }
        }

        return pairs
            .keys
            .sorted()
            .compactMap { name in
                guard let pair = pairs[name] else { return nil }
                if pair.privateKey == nil, pair.publicKey == nil { return nil }

                let fingerprintSource = pair.publicKey ?? pair.privateKey
                let fingerprint = fingerprintSource.flatMap { try? fingerprintForKeyFile($0) }
                return SSHLocalKey(
                    name: name,
                    privateKeyPath: pair.privateKey?.path,
                    publicKeyPath: pair.publicKey?.path,
                    fingerprint: fingerprint
                )
            }
    }

    private func ensureSSHDirectory() throws {
        if !fileManager.fileExists(atPath: sshDirectory.path) {
            try fileManager.createDirectory(at: sshDirectory, withIntermediateDirectories: true)
        }

        try setPermissions(path: sshDirectory.path, mode: 0o700)
    }

    private func fingerprintForKeyFile(_ file: URL) throws -> String? {
        let result = try processRunner.run(
            executable: "/usr/bin/ssh-keygen",
            arguments: ["-lf", file.path],
            allowNonZeroExit: true
        )
        guard result.status == 0 else { return nil }
        let line = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        return line.isEmpty ? nil : line
    }

    @discardableResult
    private func fixKeyPermission(for file: URL, isPublic: Bool) throws -> Bool {
        let mode: Int16 = isPublic ? 0o644 : 0o600
        return try setPermissions(path: file.path, mode: mode)
    }

    @discardableResult
    private func setPermissions(path: String, mode: Int16) throws -> Bool {
        let attr = try fileManager.attributesOfItem(atPath: path)
        let current = (attr[.posixPermissions] as? NSNumber)?.int16Value
        if current == mode {
            return false
        }
        try fileManager.setAttributes([.posixPermissions: NSNumber(value: mode)], ofItemAtPath: path)
        return true
    }
}
