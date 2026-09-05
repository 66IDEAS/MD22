import Foundation
import SwiftData

@Model
final class HistoryRecord {
    @Attribute(.unique) var canonicalPath: String
    var id: UUID
    var displayName: String
    var parentPath: String
    var bookmarkData: Data?
    var fileIdentifier: String?
    var lastOpenedAt: Date
    var isPinned: Bool
    var pinOrder: Int
    var isAvailable: Bool

    init(
        url: URL,
        bookmarkData: Data? = nil,
        fileIdentifier: String? = nil,
        lastOpenedAt: Date = .now
    ) {
        canonicalPath = url.standardizedFileURL.path
        id = UUID()
        displayName = url.lastPathComponent
        parentPath = url.deletingLastPathComponent().path
        self.bookmarkData = bookmarkData
        self.fileIdentifier = fileIdentifier
        self.lastOpenedAt = lastOpenedAt
        isPinned = false
        pinOrder = 0
        isAvailable = true
    }
}

@Model
final class ReadingStateRecord {
    @Attribute(.unique) var canonicalPath: String
    var headingID: String?
    var progress: Double
    var verticalOffset: Double
    var updatedAt: Date

    init(path: String, location: ReadingLocation = .beginning) {
        canonicalPath = path
        headingID = location.headingID
        progress = location.progress
        verticalOffset = location.verticalOffset
        updatedAt = .now
    }

    var location: ReadingLocation {
        get { ReadingLocation(headingID: headingID, progress: progress, verticalOffset: verticalOffset) }
        set {
            headingID = newValue.headingID
            progress = newValue.progress
            verticalOffset = newValue.verticalOffset
            updatedAt = .now
        }
    }
}

@Model
final class BookmarkRecord {
    var id: UUID
    var canonicalPath: String
    var fileDisplayName: String
    var kindRawValue: String
    var headingID: String?
    var title: String
    var excerpt: String?
    var progress: Double
    var verticalOffset: Double
    var createdAt: Date

    init(
        url: URL,
        kind: BookmarkKind,
        headingID: String? = nil,
        title: String,
        excerpt: String? = nil,
        location: ReadingLocation
    ) {
        id = UUID()
        canonicalPath = url.standardizedFileURL.path
        fileDisplayName = url.lastPathComponent
        kindRawValue = kind.rawValue
        self.headingID = headingID
        self.title = title
        self.excerpt = excerpt
        progress = location.progress
        verticalOffset = location.verticalOffset
        createdAt = .now
    }

    var kind: BookmarkKind {
        BookmarkKind(rawValue: kindRawValue) ?? .position
    }

    var location: ReadingLocation {
        ReadingLocation(headingID: headingID, progress: progress, verticalOffset: verticalOffset)
    }
}

