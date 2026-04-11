import Foundation

public struct SaveResult: Sendable {
    public var backupURL: URL?
    public var writtenFiles: [URL]

    public init(backupURL: URL?, writtenFiles: [URL]) {
        self.backupURL = backupURL
        self.writtenFiles = writtenFiles
    }
}

public final class SSHConfigStore {
    private let fileManager: FileManager
    private let parser: SSHConfigParser
    private let formatter: SSHConfigFormatter
    private let writer: AtomicFileWriter

    public let sshDirectory: URL
    public let configFileURL: URL
    public let configDirectoryURL: URL
    public let backupDirectoryURL: URL

    public init(
        sshDirectory: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".ssh", isDirectory: true),
        fileManager: FileManager = .default,
        parser: SSHConfigParser = SSHConfigParser(),
        formatter: SSHConfigFormatter = SSHConfigFormatter(),
        writer: AtomicFileWriter = AtomicFileWriter()
    ) {
        self.sshDirectory = sshDirectory
        self.fileManager = fileManager
        self.parser = parser
        self.formatter = formatter
        self.writer = writer
        self.configFileURL = sshDirectory.appendingPathComponent("config")
        self.configDirectoryURL = sshDirectory.appendingPathComponent("config.d", isDirectory: true)
        self.backupDirectoryURL = sshDirectory.appendingPathComponent("backup", isDirectory: true)
    }

    public func loadDocument() throws -> SSHConfigDocument {
        try writer.ensureDirectory(sshDirectory)

        var merged = SSHConfigDocument()
        if fileManager.fileExists(atPath: configFileURL.path) {
            let content = try String(contentsOf: configFileURL, encoding: .utf8)
            let doc = try parser.parse(content: content)
            merged.globalDirectives.append(contentsOf: doc.globalDirectives)
            merged.hosts.append(contentsOf: doc.hosts)

            let includePaths = doc.globalDirectives
                .filter { $0.key.caseInsensitiveCompare("Include") == .orderedSame }
                .map(\.value)

            for includePath in includePaths {
                for resolved in try resolveInclude(includePath) {
                    let includeContent = try String(contentsOf: resolved, encoding: .utf8)
                    let includeDoc = try parser.parse(content: includeContent)
                    merged.globalDirectives.append(contentsOf: includeDoc.globalDirectives)
                    merged.hosts.append(contentsOf: includeDoc.hosts)
                }
            }
        }

        merged.hosts = deduplicateHosts(merged.hosts)
        return merged
    }

    public func save(document: SSHConfigDocument) throws -> SaveResult {
        try writer.ensureDirectory(sshDirectory)
        try writer.ensureDirectory(configDirectoryURL)

        let backup = try writer.createBackupIfExists(file: configFileURL, in: backupDirectoryURL)

        let normalizedHosts = normalizeHosts(document.hosts)
        let groupBuckets = Dictionary(grouping: normalizedHosts) { slug(from: $0.metadata.group) }
        var writtenFiles: [URL] = []

        let existingManagedFiles = try fileManager.contentsOfDirectory(at: configDirectoryURL, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "conf" }
        for file in existingManagedFiles {
            try fileManager.removeItem(at: file)
        }

        let safeGlobalDirectives = sanitizeGlobalDirectives(document.globalDirectives)
        let globalContent = formatter.formatGlobalDirectives(safeGlobalDirectives)
        if !globalContent.isEmpty {
            let globalsFile = configDirectoryURL.appendingPathComponent("00-globals.conf")
            try writer.writeAtomically(globalContent, to: globalsFile)
            writtenFiles.append(globalsFile)
        }

        for (index, group) in groupBuckets.keys.sorted().enumerated() {
            let hosts = groupBuckets[group] ?? []
            let fileName = String(format: "%02d-%@.conf", index + 1, group)
            let fileURL = configDirectoryURL.appendingPathComponent(fileName)
            let content = formatter.formatHosts(hosts)
            try writer.writeAtomically(content, to: fileURL)
            writtenFiles.append(fileURL)
        }

        let mainConfig = [
            "# Managed by SSH Config Manager (sshcm)",
            "# This file is rewritten by the tool.",
            "Include ~/.ssh/config.d/*.conf",
            ""
        ].joined(separator: "\n")
        try writer.writeAtomically(mainConfig, to: configFileURL)
        writtenFiles.append(configFileURL)

        return SaveResult(backupURL: backup, writtenFiles: writtenFiles.sorted { $0.path < $1.path })
    }

    public func findHosts(matching query: String, in hosts: [SSHHostEntry]) -> [SSHHostEntry] {
        if query.isEmpty { return hosts }
        let lower = query.lowercased()
        let byAlias = hosts.filter { host in
            host.aliases.contains(where: { $0.lowercased() == lower })
        }
        if !byAlias.isEmpty {
            return byAlias
        }
        return hosts.filter { $0.metadata.tags.map { $0.lowercased() }.contains(lower) }
    }

    private func deduplicateHosts(_ hosts: [SSHHostEntry]) -> [SSHHostEntry] {
        var seen: Set<String> = []
        var results: [SSHHostEntry] = []

        for host in hosts {
            let key = host.aliases.joined(separator: "|").lowercased()
            if seen.contains(key) { continue }
            seen.insert(key)
            results.append(host)
        }

        return normalizeHosts(results)
    }

    private func normalizeHosts(_ hosts: [SSHHostEntry]) -> [SSHHostEntry] {
        hosts
            .map { host in
                var copy = host
                let aliases = host.aliases.filter { !$0.isEmpty }
                copy.aliases = aliases.isEmpty ? [host.hostName] : aliases
                copy.hostName = copy.hostName.trimmingCharacters(in: .whitespacesAndNewlines)
                if copy.hostName.isEmpty {
                    copy.hostName = copy.aliases.first ?? "example.com"
                }
                copy.user = copy.user?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
                copy.identityFile = copy.identityFile?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
                copy.proxyJump = copy.proxyJump?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
                copy.proxyCommand = copy.proxyCommand?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
                copy.metadata.group = copy.metadata.group.isEmpty ? "ungrouped" : copy.metadata.group
                copy.metadata.tags = Array(Set(copy.metadata.tags.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })).sorted()
                return copy
            }
            .sorted { lhs, rhs in
                let lg = lhs.metadata.group.lowercased()
                let rg = rhs.metadata.group.lowercased()
                if lg == rg {
                    return lhs.primaryAlias.lowercased() < rhs.primaryAlias.lowercased()
                }
                return lg < rg
            }
    }

    private func resolveInclude(_ includePath: String) throws -> [URL] {
        let normalized = includePath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return [] }

        let expandedPath = normalized.hasPrefix("~/")
            ? fileManager.homeDirectoryForCurrentUser.appendingPathComponent(String(normalized.dropFirst(2))).path
            : normalized

        if expandedPath.contains("*") {
            let pathURL = URL(fileURLWithPath: expandedPath)
            let directory = pathURL.deletingLastPathComponent()
            let pattern = pathURL.lastPathComponent
            let regexPattern = "^" + NSRegularExpression.escapedPattern(for: pattern).replacingOccurrences(of: "\\*", with: ".*") + "$"
            let regex = try NSRegularExpression(pattern: regexPattern)

            let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            return files
                .filter {
                    let name = $0.lastPathComponent
                    let range = NSRange(location: 0, length: name.utf16.count)
                    return regex.firstMatch(in: name, options: [], range: range) != nil
                }
                .sorted { $0.path < $1.path }
        }

        let url = URL(fileURLWithPath: expandedPath)
        return fileManager.fileExists(atPath: url.path) ? [url] : []
    }

    private func sanitizeGlobalDirectives(_ directives: [SSHDirective]) -> [SSHDirective] {
        directives.filter { directive in
            if directive.key.caseInsensitiveCompare("Include") != .orderedSame {
                return true
            }
            return !isRecursiveIncludePath(directive.value)
        }
    }

    private func isRecursiveIncludePath(_ value: String) -> Bool {
        let tokens = value
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)

        guard !tokens.isEmpty else { return false }

        let managedDirectory = configDirectoryURL.standardizedFileURL.path
        let mainConfigPath = configFileURL.standardizedFileURL.path
        for token in tokens {
            let tokenLower = token.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if tokenLower == "~/.ssh/config" || tokenLower.hasSuffix("/.ssh/config") {
                return true
            }
            let expanded = expandPath(token)
            let fileURL = URL(fileURLWithPath: expanded)
            let includeDirectory: URL

            if expanded.contains("*") {
                includeDirectory = fileURL.deletingLastPathComponent()
            } else if fileURL.pathExtension == "conf" {
                includeDirectory = fileURL.deletingLastPathComponent()
            } else {
                includeDirectory = fileURL
            }

            if includeDirectory.standardizedFileURL.path == managedDirectory {
                return true
            }
            if fileURL.standardizedFileURL.path == mainConfigPath {
                return true
            }
        }
        return false
    }

    private func expandPath(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("~/") {
            return fileManager.homeDirectoryForCurrentUser
                .appendingPathComponent(String(trimmed.dropFirst(2)))
                .path
        }
        return trimmed
    }

    private func slug(from text: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let mapped = text.lowercased().unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" }
        let raw = String(mapped)
        let collapsed = raw.replacingOccurrences(of: "--+", with: "-", options: .regularExpression)
        return collapsed.trimmingCharacters(in: CharacterSet(charactersIn: "-_")).isEmpty ? "ungrouped" : collapsed.trimmingCharacters(in: CharacterSet(charactersIn: "-_"))
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
