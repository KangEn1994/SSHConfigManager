import Foundation

public enum ForwardType: String, Codable, CaseIterable, Sendable {
    case local
    case remote
    case dynamic

    public var directiveKey: String {
        switch self {
        case .local:
            return "LocalForward"
        case .remote:
            return "RemoteForward"
        case .dynamic:
            return "DynamicForward"
        }
    }
}

public struct SSHPortForward: Codable, Hashable, Sendable {
    public var type: ForwardType
    public var spec: String

    public init(type: ForwardType, spec: String) {
        self.type = type
        self.spec = spec
    }
}

public struct SSHHostMetadata: Codable, Hashable, Sendable {
    public var group: String
    public var tags: [String]
    public var managed: Bool

    public init(group: String = "ungrouped", tags: [String] = [], managed: Bool = true) {
        self.group = group
        self.tags = tags
        self.managed = managed
    }
}

public struct SSHDirective: Codable, Hashable, Sendable {
    public var key: String
    public var value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

public struct SSHHostEntry: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var aliases: [String]
    public var hostName: String
    public var user: String?
    public var port: Int?
    public var identityFile: String?
    public var proxyJump: String?
    public var proxyCommand: String?
    public var forwards: [SSHPortForward]
    public var metadata: SSHHostMetadata
    public var extraDirectives: [SSHDirective]

    public init(
        id: UUID = UUID(),
        aliases: [String],
        hostName: String,
        user: String? = nil,
        port: Int? = nil,
        identityFile: String? = nil,
        proxyJump: String? = nil,
        proxyCommand: String? = nil,
        forwards: [SSHPortForward] = [],
        metadata: SSHHostMetadata = SSHHostMetadata(),
        extraDirectives: [SSHDirective] = []
    ) {
        self.id = id
        self.aliases = aliases
        self.hostName = hostName
        self.user = user
        self.port = port
        self.identityFile = identityFile
        self.proxyJump = proxyJump
        self.proxyCommand = proxyCommand
        self.forwards = forwards
        self.metadata = metadata
        self.extraDirectives = extraDirectives
    }

    public var primaryAlias: String {
        aliases.first ?? ""
    }

    public func hasTag(_ tag: String) -> Bool {
        metadata.tags.contains { $0.caseInsensitiveCompare(tag) == .orderedSame }
    }

    public func withAlias(_ alias: String) -> SSHHostEntry {
        var copy = self
        if copy.aliases.isEmpty {
            copy.aliases = [alias]
        } else {
            copy.aliases[0] = alias
        }
        return copy
    }
}

public struct SSHConfigDocument: Sendable {
    public var globalDirectives: [SSHDirective]
    public var hosts: [SSHHostEntry]

    public init(globalDirectives: [SSHDirective] = [], hosts: [SSHHostEntry] = []) {
        self.globalDirectives = globalDirectives
        self.hosts = hosts
    }
}

public enum SSHCMError: LocalizedError {
    case invalidConfig(String)
    case ioError(String)
    case commandFailed(command: String, output: String)

    public var errorDescription: String? {
        switch self {
        case .invalidConfig(let message):
            return "Invalid SSH config: \(message)"
        case .ioError(let message):
            return "I/O error: \(message)"
        case .commandFailed(let command, let output):
            return "Command failed: \(command)\n\(output)"
        }
    }
}
