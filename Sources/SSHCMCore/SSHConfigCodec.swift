import Foundation

public struct SSHConfigParser {
    public init() {}

    public func parse(content: String) throws -> SSHConfigDocument {
        var globalDirectives: [SSHDirective] = []
        var hosts: [SSHHostEntry] = []

        var currentAliases: [String] = []
        var currentDirectives: [SSHDirective] = []
        var currentMetadata: SSHHostMetadata?
        var pendingMetadata: SSHHostMetadata?

        func flushHostIfNeeded() {
            guard !currentAliases.isEmpty else { return }
            hosts.append(buildHost(aliases: currentAliases, directives: currentDirectives, metadata: currentMetadata))
            currentAliases = []
            currentDirectives = []
            currentMetadata = nil
        }

        let lines = content.components(separatedBy: .newlines)
        var lineIndex = 0
        while lineIndex < lines.count {
            let rawLine = lines[lineIndex]
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.isEmpty || line.hasPrefix("#") {
                if line == "# sshcm:begin" {
                    if lineIndex + 1 < lines.count {
                        let jsonLine = lines[lineIndex + 1].trimmingCharacters(in: .whitespaces)
                        if jsonLine.hasPrefix("# sshcm:") {
                            let payload = jsonLine.replacingOccurrences(of: "# sshcm:", with: "").trimmingCharacters(in: .whitespaces)
                            if let data = payload.data(using: .utf8),
                               let decoded = try? JSONDecoder().decode(SSHHostMetadata.self, from: data) {
                                pendingMetadata = decoded
                            }
                        }
                    }
                }
                lineIndex += 1
                continue
            }

            if let directive = parseDirective(line) {
                if directive.key.caseInsensitiveCompare("Host") == .orderedSame {
                    flushHostIfNeeded()
                    currentAliases = directive.value.split(whereSeparator: { $0.isWhitespace }).map(String.init)
                    currentMetadata = pendingMetadata
                    pendingMetadata = nil
                } else if currentAliases.isEmpty {
                    globalDirectives.append(directive)
                } else {
                    currentDirectives.append(directive)
                }
            }

            lineIndex += 1
        }

        flushHostIfNeeded()
        return SSHConfigDocument(globalDirectives: globalDirectives, hosts: hosts)
    }

    private func parseDirective(_ line: String) -> SSHDirective? {
        guard !line.isEmpty else { return nil }
        let comps = line.split(maxSplits: 1, omittingEmptySubsequences: true, whereSeparator: { $0.isWhitespace })
        guard !comps.isEmpty else { return nil }
        let key = String(comps[0])
        let value = comps.count > 1 ? String(comps[1]).trimmingCharacters(in: .whitespaces) : ""
        return SSHDirective(key: key, value: value)
    }

    private func buildHost(aliases: [String], directives: [SSHDirective], metadata: SSHHostMetadata?) -> SSHHostEntry {
        var hostName = aliases.first ?? ""
        var user: String?
        var port: Int?
        var identityFile: String?
        var proxyJump: String?
        var proxyCommand: String?
        var forwards: [SSHPortForward] = []
        var extraDirectives: [SSHDirective] = []

        for directive in directives {
            switch directive.key.lowercased() {
            case "hostname":
                hostName = directive.value
            case "user":
                user = directive.value
            case "port":
                port = Int(directive.value)
            case "identityfile":
                identityFile = directive.value
            case "proxyjump":
                proxyJump = directive.value
            case "proxycommand":
                proxyCommand = directive.value
            case "localforward":
                forwards.append(SSHPortForward(type: .local, spec: directive.value))
            case "remoteforward":
                forwards.append(SSHPortForward(type: .remote, spec: directive.value))
            case "dynamicforward":
                forwards.append(SSHPortForward(type: .dynamic, spec: directive.value))
            default:
                extraDirectives.append(directive)
            }
        }

        return SSHHostEntry(
            aliases: aliases,
            hostName: hostName,
            user: user,
            port: port,
            identityFile: identityFile,
            proxyJump: proxyJump,
            proxyCommand: proxyCommand,
            forwards: forwards,
            metadata: metadata ?? SSHHostMetadata(),
            extraDirectives: extraDirectives
        )
    }
}

public struct SSHConfigFormatter {
    public init() {}

    public func formatGlobalDirectives(_ directives: [SSHDirective]) -> String {
        guard !directives.isEmpty else { return "" }
        return directives.map { "\($0.key) \($0.value)".trimmingCharacters(in: .whitespaces) }.joined(separator: "\n") + "\n\n"
    }

    public func formatHosts(_ hosts: [SSHHostEntry]) -> String {
        var blocks: [String] = []
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]

        for host in hosts {
            var lines: [String] = []
            lines.append("# sshcm:begin")
            if let jsonData = try? encoder.encode(host.metadata),
               let json = String(data: jsonData, encoding: .utf8) {
                lines.append("# sshcm: \(json)")
            } else {
                lines.append("# sshcm: {\"group\":\"ungrouped\",\"managed\":true,\"tags\":[]}")
            }
            lines.append("# sshcm:end")
            lines.append("Host \(host.aliases.joined(separator: " "))")
            lines.append("    HostName \(host.hostName)")
            if let user = host.user, !user.isEmpty {
                lines.append("    User \(user)")
            }
            if let port = host.port {
                lines.append("    Port \(port)")
            }
            if let identityFile = host.identityFile, !identityFile.isEmpty {
                lines.append("    IdentityFile \(identityFile)")
            }
            if let proxyJump = host.proxyJump, !proxyJump.isEmpty {
                lines.append("    ProxyJump \(proxyJump)")
            }
            if let proxyCommand = host.proxyCommand, !proxyCommand.isEmpty {
                lines.append("    ProxyCommand \(proxyCommand)")
            }
            for forward in host.forwards where !forward.spec.isEmpty {
                lines.append("    \(forward.type.directiveKey) \(forward.spec)")
            }
            for extra in host.extraDirectives where !extra.key.isEmpty {
                if extra.value.isEmpty {
                    lines.append("    \(extra.key)")
                } else {
                    lines.append("    \(extra.key) \(extra.value)")
                }
            }
            blocks.append(lines.joined(separator: "\n"))
        }

        return blocks.joined(separator: "\n\n") + (blocks.isEmpty ? "" : "\n")
    }
}
