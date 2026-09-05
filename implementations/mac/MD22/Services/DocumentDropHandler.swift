import Foundation

enum DocumentDropHandler {
    static func firstMarkdownURL(in urls: [URL]) -> URL? {
        urls.first(where: DocumentRouter.accepts)
    }
}

