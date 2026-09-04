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
        records = try context.fetch(
            FetchDescriptor<BookmarkRecord>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        )
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
        let record = BookmarkRecord(
            url: url,
            kind: kind,
            headingID: headingID,
            title: title,
            excerpt: excerpt,
            location: location
        )
        context.insert(record)
        try context.save()
        try reload()
        return record
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
}
