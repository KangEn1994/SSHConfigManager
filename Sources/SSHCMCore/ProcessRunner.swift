import Foundation

public struct ProcessResult: Sendable {
    public var status: Int32
    public var stdout: String
    public var stderr: String

    public var combinedOutput: String {
        [stdout, stderr].filter { !$0.isEmpty }.joined(separator: "\n")
    }
}

public struct ProcessRunner {
    public init() {}

    @discardableResult
    public func run(
        executable: String,
        arguments: [String],
        environment: [String: String]? = nil,
        currentDirectoryURL: URL? = nil,
        allowNonZeroExit: Bool = false
    ) throws -> ProcessResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        if let environment {
            process.environment = ProcessInfo.processInfo.environment.merging(environment, uniquingKeysWith: { _, new in new })
        }
        if let currentDirectoryURL {
            process.currentDirectoryURL = currentDirectoryURL
        }

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()
        process.waitUntilExit()

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""

        let result = ProcessResult(status: process.terminationStatus, stdout: stdout, stderr: stderr)
        if !allowNonZeroExit, result.status != 0 {
            let cmd = ([executable] + arguments).joined(separator: " ")
            throw SSHCMError.commandFailed(command: cmd, output: result.combinedOutput)
        }

        return result
    }
}
