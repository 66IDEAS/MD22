import Foundation

struct DocumentIdentity: Sendable, Equatable {
    let canonicalPath: String
    let bookmarkData: Data?
    let fileIdentifier: String?

    static func capture(for url: URL) -> DocumentIdentity {
        let canonicalURL = url.standardizedFileURL
        let values = try? canonicalURL.resourceValues(forKeys: [.fileResourceIdentifierKey])
        let bookmark = try? canonicalURL.bookmarkData(
            options: .minimalBookmark,
            includingResourceValuesForKeys: [.fileResourceIdentifierKey],
            relativeTo: nil
        )
        return DocumentIdentity(
            canonicalPath: canonicalURL.path,
            bookmarkData: bookmark,
            fileIdentifier: values?.fileResourceIdentifier.map { String(describing: $0) }
        )
    }
}

