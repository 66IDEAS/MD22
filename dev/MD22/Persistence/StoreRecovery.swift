import Foundation

enum StoreRecovery {
    static let currentVersion = "1.0.0"
    static let storeName = "Metadata.store"
    static let versionMarkerName = "schema.version"

    static func prepareBackupIfNeeded(in directory: URL) throws -> URL? {
        let fileManager = FileManager.default
        let store = directory.appending(path: storeName)
        guard fileManager.fileExists(atPath: store.path) else { return nil }

        let marker = directory.appending(path: versionMarkerName)
        let previousVersion = try? String(contentsOf: marker, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard previousVersion != currentVersion else { return nil }

        let backup = directory
            .appending(path: "Backups", directoryHint: .isDirectory)
            .appending(path: "Before-\(timestamp())", directoryHint: .isDirectory)
        try fileManager.createDirectory(at: backup, withIntermediateDirectories: true)
        try copyStoreFamily(from: directory, to: backup)
        return backup
    }

    static func writeCurrentVersion(in directory: URL) throws {
        try currentVersion.write(
            to: directory.appending(path: versionMarkerName),
            atomically: true,
            encoding: .utf8
        )
    }

    static func preserveDamagedStore(in directory: URL) throws -> URL? {
        let fileManager = FileManager.default
        let store = directory.appending(path: storeName)
        guard fileManager.fileExists(atPath: store.path) else { return nil }
        let damaged = directory
            .appending(path: "Recovery", directoryHint: .isDirectory)
            .appending(path: "Damaged-\(timestamp())", directoryHint: .isDirectory)
        try fileManager.createDirectory(at: damaged, withIntermediateDirectories: true)

        for name in storeFamilyNames where fileManager.fileExists(atPath: directory.appending(path: name).path) {
            try fileManager.moveItem(
                at: directory.appending(path: name),
                to: damaged.appending(path: name)
            )
        }
        return damaged
    }

    private static let storeFamilyNames = [storeName, "\(storeName)-wal", "\(storeName)-shm"]

    private static func copyStoreFamily(from source: URL, to destination: URL) throws {
        let fileManager = FileManager.default
        for name in storeFamilyNames where fileManager.fileExists(atPath: source.appending(path: name).path) {
            try fileManager.copyItem(at: source.appending(path: name), to: destination.appending(path: name))
        }
    }

    private static func timestamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: .now).replacingOccurrences(of: ":", with: "-")
    }
}

