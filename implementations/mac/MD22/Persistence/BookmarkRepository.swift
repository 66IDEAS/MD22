import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class BookmarkRepository {
    private let context: ModelContext
    private(set) var records: [BookmarkRecord] = []

    init(container: ModelContainer) {
        context = container.mainContext
        try? reload()
    }

    func reload() throws {
        let fetched = try context.fetch(
            FetchDescriptor<BookmarkRecord>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        )
        var uniqueRecords: [BookmarkRecord] = []
        var removedDuplicate = false
        for record in fetched {
            if uniqueRecords.contains(where: { Self.matches($0, record) }) {
                context.delete(record)
                removedDuplicate = true
            } else {
                uniqueRecords.append(record)
            }
        }
        if removedDuplicate {
            try context.save()
        }
        records = uniqueRecords
    }

    func records(for url: URL?) -> [BookmarkRecord] {
        guard let path = url?.standardizedFileURL.path else { return [] }
        return records.filter { $0.canonicalPath == path }
    }

    @discardableResult
    func add(
        url: URL,
        kind: BookmarkKind,
        headingID: String?,
        title: String,
        excerpt: String?,
        location: ReadingLocation
    ) throws -> BookmarkRecord {
        let candidate = BookmarkRecord(
            url: url,
            kind: kind,
            headingID: headingID,
            title: title,
            excerpt: excerpt,
            location: location
        )
        if let existing = records.first(where: { Self.matches($0, candidate) }) {
            return existing
        }
        context.insert(candidate)
        try context.save()
        try reload()
        return candidate
    }

    func remove(_ record: BookmarkRecord) throws {
        context.delete(record)
        try context.save()
        try reload()
    }

    func reconcile(snapshot: DocumentSnapshot, analysis: DocumentAnalysis) throws {
        let documentRecords = records(for: snapshot.url)
        for record in documentRecords {
            let isValid: Bool
            switch record.kind {
            case .heading:
                isValid = record.headingID.map { id in analysis.headings.contains { $0.id == id } } ?? false
            case .passage:
                isValid = record.excerpt.map(snapshot.markdown.contains) ?? false
            case .position:
                isValid = true
            }
            if !isValid { context.delete(record) }
        }
        try context.save()
        try reload()
    }

    private static func matches(_ left: BookmarkRecord, _ right: BookmarkRecord) -> Bool {
        guard left.canonicalPath == right.canonicalPath, left.kind == right.kind else {
            return false
        }
        switch left.kind {
        case .heading:
            return left.headingID != nil && left.headingID == right.headingID
        case .passage:
            guard normalized(left.excerpt) == normalized(right.excerpt),
                  left.headingID == right.headingID else { return false }
            return locationsAreNear(left.location, right.location)
        case .position:
            return left.headingID == right.headingID
                && locationsAreNear(left.location, right.location)
        }
    }

    private static func normalized(_ value: String?) -> String? {
        value?
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }

    private static func locationsAreNear(_ left: ReadingLocation, _ right: ReadingLocation) -> Bool {
        abs(left.verticalOffset - right.verticalOffset) <= 32
            || abs(left.progress - right.progress) <= 0.002
    }
}
