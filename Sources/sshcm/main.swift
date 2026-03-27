import Foundation
import SSHCMCore

struct CLI {
    private let store = SSHConfigStore()
    private let keyManager = SSHKeyManager()

    func run() -> Int32 {
        let args = Array(CommandLine.arguments.dropFirst())
        guard let command = args.first else {
            printHelp()
            return 0
        }

        do {
            switch command {
            case "list":
                try list(Array(args.dropFirst()))
            case "connect":
                try connect(Array(args.dropFirst()))
            case "jump":
                try jump(Array(args.dropFirst()))
            case "forward":
                try forward(Array(args.dropFirst()))
            case "doctor-keys":
                try doctorKeys()
            case "keygen":
                try keygen(Array(args.dropFirst()))
            case "import-key":
                try importKey(Array(args.dropFirst()))
            case "help", "-h", "--help":
                printHelp()
            default:
                throw SSHCMError.invalidConfig("Unknown command: \(command)")
            }
            return 0
        } catch {
            fputs("Error: \(error.localizedDescription)\n", stderr)
            return 1
        }
    }

    private func list(_ args: [String]) throws {
        var group: String?
        var tag: String?

        var index = 0
        while index < args.count {
            let token = args[index]
            if token == "--group", index + 1 < args.count {
                group = args[index + 1]
                index += 2
            } else if token == "--tag", index + 1 < args.count {
                tag = args[index + 1]
                index += 2
            } else {
                throw SSHCMError.invalidConfig("Unknown argument for list: \(token)")
            }
        }

        let doc = try store.loadDocument()
        let hosts = doc.hosts.filter { host in
            let groupMatch = group.map { host.metadata.group.caseInsensitiveCompare($0) == .orderedSame } ?? true
            let tagMatch = tag.map { host.hasTag($0) } ?? true
            return groupMatch && tagMatch
        }

        if hosts.isEmpty {
            print("No hosts found")
            return
        }

        for host in hosts {
            let tags = host.metadata.tags.joined(separator: ",")
            print("\(host.primaryAlias)\tgroup=\(host.metadata.group)\ttags=[\(tags)]\thostname=\(host.hostName)")
        }
    }

    private func connect(_ args: [String]) throws {
        guard let query = args.first else {
            throw SSHCMError.invalidConfig("Usage: sshcm connect <host-or-tag>")
        }

        let doc = try store.loadDocument()
        let matches = store.findHosts(matching: query, in: doc.hosts)
        guard !matches.isEmpty else {
            throw SSHCMError.invalidConfig("No host found for query: \(query)")
        }

        let exactAlias = matches.first { $0.aliases.contains(where: { $0.caseInsensitiveCompare(query) == .orderedSame }) }
        let target = exactAlias ?? matches[0]

        if matches.count > 1 && exactAlias == nil {
            fputs("Multiple hosts matched tag '\(query)'. Connecting to '\(target.primaryAlias)'.\n", stderr)
        }

        try runSSH(arguments: [target.primaryAlias])
    }

    private func jump(_ args: [String]) throws {
        guard let target = args.first else {
            throw SSHCMError.invalidConfig("Usage: sshcm jump <target> --via <bastion-chain>")
        }

        var via: String?
        var index = 1
        while index < args.count {
            let token = args[index]
            if token == "--via", index + 1 < args.count {
                via = args[index + 1]
                index += 2
            } else {
                throw SSHCMError.invalidConfig("Unknown argument for jump: \(token)")
            }
        }

        guard let via else {
            throw SSHCMError.invalidConfig("Missing --via for jump")
        }

        try runSSH(arguments: ["-J", via, target])
    }

    private func forward(_ args: [String]) throws {
        guard let target = args.first else {
            throw SSHCMError.invalidConfig("Usage: sshcm forward <target> [--L spec|--R spec|--D spec]")
        }

        var sshArgs: [String] = []
        var index = 1
        while index < args.count {
            let token = args[index]
            switch token {
            case "--L", "--R", "--D":
                guard index + 1 < args.count else {
                    throw SSHCMError.invalidConfig("Missing spec for \(token)")
                }
                let flag = token.replacingOccurrences(of: "--", with: "-")
                sshArgs.append(flag)
                sshArgs.append(args[index + 1])
                index += 2
            default:
                throw SSHCMError.invalidConfig("Unknown argument for forward: \(token)")
            }
        }

        sshArgs.append(target)
        try runSSH(arguments: sshArgs)
    }

    private func doctorKeys() throws {
        let result = try keyManager.doctorKeys()
        print("Scanned: \(result.scannedFiles)")
        print("Permissions fixed: \(result.fixedPermissions.count)")
        for file in result.fixedPermissions {
            print("  - \(file.path)")
        }
        print("SSH agent reachable: \(result.sshAgentReachable ? "yes" : "no")")
        if !result.sshAddOutput.isEmpty {
            print("ssh-add -l: \(result.sshAddOutput.trimmingCharacters(in: .whitespacesAndNewlines))")
        }
    }

    private func keygen(_ args: [String]) throws {
        guard let name = args.first else {
            throw SSHCMError.invalidConfig("Usage: sshcm keygen <name> [--type ed25519] [--add-agent] [--use-keychain]")
        }

        var type = "ed25519"
        var addAgent = false
        var useKeychain = false
        var index = 1
        while index < args.count {
            let token = args[index]
            if token == "--type", index + 1 < args.count {
                type = args[index + 1]
                index += 2
            } else if token == "--add-agent" {
                addAgent = true
                index += 1
            } else if token == "--use-keychain" {
                useKeychain = true
                index += 1
            } else {
                throw SSHCMError.invalidConfig("Unknown argument for keygen: \(token)")
            }
        }

        let key = try keyManager.generateKeyPair(name: name, type: type)
        print("Created key: \(key.path)")
        if addAgent {
            let output = try keyManager.addKeyToAgent(key, useKeychain: useKeychain)
            if !output.isEmpty {
                print(output.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }

    private func importKey(_ args: [String]) throws {
        guard let path = args.first else {
            throw SSHCMError.invalidConfig("Usage: sshcm import-key <path> [--name key_name] [--add-agent] [--use-keychain]")
        }

        var name: String?
        var addAgent = false
        var useKeychain = false
        var index = 1
        while index < args.count {
            let token = args[index]
            if token == "--name", index + 1 < args.count {
                name = args[index + 1]
                index += 2
            } else if token == "--add-agent" {
                addAgent = true
                index += 1
            } else if token == "--use-keychain" {
                useKeychain = true
                index += 1
            } else {
                throw SSHCMError.invalidConfig("Unknown argument for import-key: \(token)")
            }
        }

        let keyURL = try keyManager.importPrivateKey(from: URL(fileURLWithPath: path), as: name)
        print("Imported key: \(keyURL.path)")
        if addAgent {
            let output = try keyManager.addKeyToAgent(keyURL, useKeychain: useKeychain)
            if !output.isEmpty {
                print(output.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }

    private func runSSH(arguments: [String]) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ssh")
        process.arguments = arguments
        process.standardInput = FileHandle.standardInput
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError

        try process.run()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            throw SSHCMError.commandFailed(command: "/usr/bin/ssh \(arguments.joined(separator: " "))", output: "Exited with status \(process.terminationStatus)")
        }
    }

    private func printHelp() {
        print(
            """
            sshcm - SSH Config Manager CLI

            Commands:
              list [--group <name>] [--tag <tag>]
              connect <host-or-tag>
              jump <target> --via <bastion-chain>
              forward <target> [--L spec] [--R spec] [--D spec]
              doctor-keys
              keygen <name> [--type ed25519] [--add-agent] [--use-keychain]
              import-key <path> [--name key_name] [--add-agent] [--use-keychain]
            """
        )
    }
}

exit(CLI().run())
