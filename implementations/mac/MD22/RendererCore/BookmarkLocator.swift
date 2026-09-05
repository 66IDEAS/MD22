import Foundation

struct BookmarkTarget: Sendable, Codable, Equatable {
    let kind: BookmarkKind
    let headingID: String?
    let excerpt: String?
    let location: ReadingLocation
}

enum BookmarkLocator {
    static func bestLocation(for target: BookmarkTarget, in analysis: DocumentAnalysis) -> ReadingLocation {
        if let headingID = target.headingID,
           analysis.headings.contains(where: { $0.id == headingID }) {
            return ReadingLocation(
                headingID: headingID,
                progress: target.location.progress,
                verticalOffset: target.location.verticalOffset
            )
        }
        return ReadingLocation(
            headingID: nil,
            progress: min(max(target.location.progress, 0), 1),
            verticalOffset: max(target.location.verticalOffset, 0)
        )
    }
}

