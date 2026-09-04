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
}
