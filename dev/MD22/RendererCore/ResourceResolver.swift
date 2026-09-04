import Foundation

enum ResourceResolver {
    static func resolve(_ reference: String, relativeTo documentURL: URL) -> URL? {
        guard !reference.isEmpty else { return nil }
        if let absolute = URL(string: reference), absolute.scheme != nil {
            return absolute
        }
        let path = reference.removingPercentEncoding ?? reference
        return URL(fileURLWithPath: path, relativeTo: documentURL.deletingLastPathComponent())
            .standardizedFileURL
    }

    static func isMarkdown(_ url: URL) -> Bool {
        ["md", "markdown", "mdown", "mkd", "mkdn"].contains(url.pathExtension.lowercased())
    }
}

