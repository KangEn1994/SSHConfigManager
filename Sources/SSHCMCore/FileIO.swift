import Foundation

public struct AtomicFileWriter {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func ensureDirectory(_ directory: URL) throws {
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    public func writeAtomically(_ content: String, to path: URL) throws {
        let directory = path.deletingLastPathComponent()
        try ensureDirectory(directory)

        let temp = directory.appendingPathComponent(".tmp-\(UUID().uuidString)-\(path.lastPathComponent)")
        do {
            try content.write(to: temp, atomically: true, encoding: .utf8)
            if fileManager.fileExists(atPath: path.path) {
                _ = try fileManager.replaceItemAt(path, withItemAt: temp)
            } else {
                try fileManager.moveItem(at: temp, to: path)
            }
        } catch {
            try? fileManager.removeItem(at: temp)
            throw error
        }
    }

    @discardableResult
    public func createBackupIfExists(file: URL, in backupDirectory: URL) throws -> URL? {
        guard fileManager.fileExists(atPath: file.path) else { return nil }
        try ensureDirectory(backupDirectory)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss-SSS"
        let timestamp = formatter.string(from: Date())
        let nonce = UUID().uuidString.prefix(8)
        let backupURL = backupDirectory.appendingPathComponent("\(file.lastPathComponent).\(timestamp)-\(nonce).bak")
        try fileManager.copyItem(at: file, to: backupURL)
        return backupURL
    }
}
