import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class HistoryRepository: HistoryPersisting {
    private enum DefaultsKey {
        static let lastDocumentPath = "lastDocumentPath"
    }

    private let context: ModelContext
    private let defaults: UserDefaults

    private(set) var pinnedRecords: [HistoryRecord] = []
    private(set) var recentRecords: [HistoryRecord] = []

    init(container: ModelContainer, defaults: UserDefaults = .standard) {
        context = container.mainContext
        self.defaults = defaults
        try? reload()
    }

    func reload() throws {
        let records = try context.fetch(FetchDescriptor<HistoryRecord>())
        pinnedRecords = records
            .filter(\.isPinned)
            .sorted { lhs, rhs in
                lhs.pinOrder == rhs.pinOrder ? lhs.lastOpenedAt > rhs.lastOpenedAt : lhs.pinOrder < rhs.pinOrder
            }
        recentRecords = records
            .filter { !$0.isPinned }
            .sorted { $0.lastOpenedAt > $1.lastOpenedAt }
    }

    @discardableResult
    func recordOpen(_ snapshot: DocumentSnapshot) throws -> HistoryRecord {
        let path = snapshot.url.standardizedFileURL.path
        let identity = DocumentIdentity.capture(for: snapshot.url)
        let record: HistoryRecord
        if let existing = try historyRecord(path: path) {
            record = existing
            record.displayName = snapshot.url.lastPathComponent
            record.parentPath = snapshot.url.deletingLastPathComponent().path
            record.bookmarkData = identity.bookmarkData
            record.fileIdentifier = snapshot.fileIdentifier ?? identity.fileIdentifier
            record.lastOpenedAt = .now
            record.isAvailable = true
        } else {
            record = HistoryRecord(
                url: snapshot.url,
                bookmarkData: identity.bookmarkData,
                fileIdentifier: snapshot.fileIdentifier ?? identity.fileIdentifier
            )
            context.insert(record)
        }
        defaults.set(path, forKey: DefaultsKey.lastDocumentPath)
        try context.save()
        try reload()
        return record
    }

    func remove(_ record: HistoryRecord) throws {
        context.delete(record)
        try context.save()
        try reload()
    }

    func clearUnpinnedHistory() throws {
        for record in recentRecords {
            context.delete(record)
        }
        try context.save()
        try reload()
    }

    func markUnavailable(path: String) throws {
        guard let record = try historyRecord(path: path) else { return }
        record.isAvailable = false
        try context.save()
        try reload()
    }

    func setPinned(_ isPinned: Bool, for record: HistoryRecord) throws {
        record.isPinned = isPinned
        if isPinned {
            record.pinOrder = (pinnedRecords.map(\.pinOrder).max() ?? -1) + 1
        }
        try context.save()
        try reload()
    }

    func reorderPinned(fromOffsets: IndexSet, toOffset: Int) throws {
        var ordered = pinnedRecords
        ordered.move(fromOffsets: fromOffsets, toOffset: toOffset)
        for (index, record) in ordered.enumerated() {
            record.pinOrder = index
        }
        try context.save()
        try reload()
    }

    func historyRecord(path: String) throws -> HistoryRecord? {
        let canonicalPath = URL(fileURLWithPath: path).standardizedFileURL.path
        let descriptor = FetchDescriptor<HistoryRecord>(
            predicate: #Predicate { $0.canonicalPath == canonicalPath }
        )
        return try context.fetch(descriptor).first
    }

    func resolvedURL(for record: HistoryRecord) -> URL? {
        let direct = URL(fileURLWithPath: record.canonicalPath)
        if FileManager.default.isReadableFile(atPath: direct.path) { return direct }
        guard let data = record.bookmarkData else { return nil }
        var stale = false
        return try? URL(
            resolvingBookmarkData: data,
            options: [.withoutUI],
            relativeTo: nil,
            bookmarkDataIsStale: &stale
        )
    }

    func saveReadingLocation(_ location: ReadingLocation, for url: URL) throws {
        let path = url.standardizedFileURL.path
        if let existing = try readingState(path: path) {
            existing.location = location
        } else {
            context.insert(ReadingStateRecord(path: path, location: location))
        }
        try context.save()
    }

    func readingLocation(for url: URL) throws -> ReadingLocation {
        try readingState(path: url.standardizedFileURL.path)?.location ?? .beginning
    }

    var lastDocumentURL: URL? {
        guard let path = defaults.string(forKey: DefaultsKey.lastDocumentPath) else { return nil }
        return URL(fileURLWithPath: path)
    }

    private func readingState(path: String) throws -> ReadingStateRecord? {
        let descriptor = FetchDescriptor<ReadingStateRecord>(
            predicate: #Predicate { $0.canonicalPath == path }
        )
        return try context.fetch(descriptor).first
    }
}

