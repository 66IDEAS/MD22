import Foundation
import SwiftData
import Testing
@testable import MD22

@MainActor
@Suite("Application-scoped persistence")
struct PersistenceTests {
    @Test("Metadata models persist without project sidecars")
    func inMemoryModels() throws {
        let persistence = try PersistenceController(isStoredInMemoryOnly: true)
        let context = persistence.container.mainContext
        let url = URL(fileURLWithPath: "/tmp/Project/README.md")
        context.insert(HistoryRecord(url: url))
        context.insert(ReadingStateRecord(path: url.path))
        context.insert(BookmarkRecord(url: url, kind: .position, title: "Position", location: .beginning))
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<HistoryRecord>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<ReadingStateRecord>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<BookmarkRecord>()) == 1)
    }

    @Test("A pre-migration store family receives a recoverable backup")
    func migrationBackup() throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let bytes = Data("metadata".utf8)
        try bytes.write(to: directory.appending(path: StoreRecovery.storeName))
        try "0.9.0".write(
            to: directory.appending(path: StoreRecovery.versionMarkerName),
            atomically: true,
            encoding: .utf8
        )

        let createdBackup = try StoreRecovery.prepareBackupIfNeeded(in: directory)
        let backup = try #require(createdBackup)
        #expect(try Data(contentsOf: backup.appending(path: StoreRecovery.storeName)) == bytes)
    }
}
