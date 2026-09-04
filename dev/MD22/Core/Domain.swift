import Foundation

struct DocumentSnapshot: Sendable, Equatable {
    let url: URL
    let markdown: String
    let modificationDate: Date?
    let fileIdentifier: String?
}

struct Heading: Sendable, Identifiable, Equatable, Hashable {
    let id: String
    let level: Int
    let title: String
}

struct DocumentAnalysis: Sendable, Equatable {
    let headings: [Heading]
    let wordCount: Int
    let estimatedReadingMinutes: Int
}

struct ReadingLocation: Sendable, Codable, Equatable {
    var headingID: String?
    var progress: Double
    var verticalOffset: Double

    static let beginning = ReadingLocation(headingID: nil, progress: 0, verticalOffset: 0)
}

struct NavigationEntry: Sendable, Equatable {
    let url: URL
    let location: ReadingLocation
}

struct RendererViewState: Sendable, Equatable {
    let location: ReadingLocation
    let wordCount: Int
    let linkDestination: String?
    let selectedText: String
}

struct DocumentSearchState: Sendable, Equatable {
    var query = ""
    var activeIndex = -1
    var matchCount = 0
    var section = ""
}

enum BookmarkKind: String, Sendable, Codable, CaseIterable {
    case heading
    case passage
    case position
}

enum ExportFormat: String, Sendable, Codable, CaseIterable {
    case html
    case pdf
}

enum MD22Error: LocalizedError, Sendable, Equatable {
    case unsupportedFile
    case unavailableFile
    case unreadableFile
    case invalidEncoding
    case rendererUnavailable
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .unsupportedFile: String(localized: "That item is not a Markdown file.")
        case .unavailableFile: String(localized: "The file is no longer available.")
        case .unreadableFile: String(localized: "The file could not be read.")
        case .invalidEncoding: String(localized: "The file is not valid UTF-8 text.")
        case .rendererUnavailable: String(localized: "The Markdown renderer is unavailable.")
        case .exportFailed: String(localized: "The document could not be exported.")
        }
    }
}
