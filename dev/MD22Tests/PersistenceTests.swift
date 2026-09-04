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

    @Test("History is unique and removals preserve independent reading state")
    func historyLifecycle() throws {
        let persistence = try PersistenceController(isStoredInMemoryOnly: true)
        let suite = try #require(UserDefaults(suiteName: UUID().uuidString))
        let repository = HistoryRepository(container: persistence.container, defaults: suite)
        let url = URL(fileURLWithPath: "/tmp/Project/README.md")
        let first = DocumentSnapshot(url: url, markdown: "First", modificationDate: nil, fileIdentifier: "1")
        let second = DocumentSnapshot(url: url, markdown: "Second", modificationDate: nil, fileIdentifier: "1")
        try repository.recordOpen(first)
        try repository.recordOpen(second)
        #expect(repository.recentRecords.count == 1)

        let location = ReadingLocation(headingID: "chapter", progress: 0.4, verticalOffset: 120)
        try repository.saveReadingLocation(location, for: url)
        try repository.remove(try #require(repository.recentRecords.first))
        #expect(repository.recentRecords.isEmpty)
        #expect(try repository.readingLocation(for: url) == location)
    }

    @Test("Clearing history preserves pinned files")
    func clearPreservesPins() throws {
        let persistence = try PersistenceController(isStoredInMemoryOnly: true)
        let repository = HistoryRepository(container: persistence.container)
        for index in 0..<2 {
            let url = URL(fileURLWithPath: "/tmp/file-\(index).md")
            try repository.recordOpen(DocumentSnapshot(url: url, markdown: "", modificationDate: nil, fileIdentifier: nil))
        }
        let pinned = try #require(repository.recentRecords.first)
        try repository.setPinned(true, for: pinned)
        try repository.clearUnpinnedHistory()
        #expect(repository.pinnedRecords.count == 1)
        #expect(repository.recentRecords.isEmpty)
    }

    @Test("Pinned entries keep manual order and unavailable state")
    func pinOrderAndAvailability() throws {
        let persistence = try PersistenceController(isStoredInMemoryOnly: true)
        let repository = HistoryRepository(container: persistence.container)
        for name in ["first.md", "second.md", "third.md"] {
            let url = URL(fileURLWithPath: "/tmp/\(name)")
            try repository.recordOpen(DocumentSnapshot(url: url, markdown: "", modificationDate: nil, fileIdentifier: nil))
        }
        for record in repository.recentRecords {
            try repository.setPinned(true, for: record)
        }
        let originalFirstPath = try #require(repository.pinnedRecords.first).canonicalPath
        try repository.reorderPinned(fromOffsets: IndexSet(integer: 0), toOffset: repository.pinnedRecords.count)
        #expect(repository.pinnedRecords.last?.canonicalPath == originalFirstPath)

        try repository.markUnavailable(path: originalFirstPath)
        let unavailable = try #require(repository.pinnedRecords.first { $0.canonicalPath == originalFirstPath })
        #expect(unavailable.isPinned)
        #expect(!unavailable.isAvailable)
    }

    @Test("Bookmarks survive history removal and invalid targets reconcile")
    func bookmarks() throws {
        let persistence = try PersistenceController(isStoredInMemoryOnly: true)
        let history = HistoryRepository(container: persistence.container)
        let bookmarks = BookmarkRepository(container: persistence.container)
        let file = FileManager.default.temporaryDirectory.appending(path: "Bookmark-\(UUID()).md")
        try "# Kept\n\nSelected passage".write(to: file, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: file) }
        let snapshot = DocumentSnapshot(url: file, markdown: "# Kept\n\nSelected passage", modificationDate: nil, fileIdentifier: nil)
        let location = ReadingLocation(headingID: "kept", progress: 0.4, verticalOffset: 100)
        try history.recordOpen(snapshot)
        _ = try bookmarks.add(url: file, kind: .heading, headingID: "kept", title: "Kept", excerpt: nil, location: location)
        _ = try bookmarks.add(url: file, kind: .passage, headingID: "kept", title: "Selected passage", excerpt: "Selected passage", location: location)
        try history.remove(try #require(history.recentRecords.first))
        #expect(bookmarks.records.count == 2)

        let changed = DocumentSnapshot(url: file, markdown: "# Changed", modificationDate: nil, fileIdentifier: nil)
        try bookmarks.reconcile(snapshot: changed, analysis: MarkdownAnalysis.analyze(changed.markdown))
        #expect(bookmarks.records.isEmpty)
    }
}
