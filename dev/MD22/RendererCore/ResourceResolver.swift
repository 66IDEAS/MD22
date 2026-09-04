import Foundation

enum ResourceResolver {
    static func resolve(_ reference: String, relativeTo documentURL: URL) -> URL? {
        guard !reference.isEmpty else { return nil }
        if let absolute = URL(string: reference), absolute.scheme != nil {
            return absolute
        }
        let parts = reference.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)
        let encodedPath = String(parts[0])
        let path = encodedPath.removingPercentEncoding ?? encodedPath
        let fileURL = URL(fileURLWithPath: path, relativeTo: documentURL.deletingLastPathComponent())
            .standardizedFileURL
        guard parts.count == 2 else { return fileURL }
        var components = URLComponents(url: fileURL, resolvingAgainstBaseURL: false)
        components?.percentEncodedFragment = String(parts[1])
        return components?.url ?? fileURL
    }

    static func isMarkdown(_ url: URL) -> Bool {
        ["md", "markdown", "mdown", "mkd", "mkdn"].contains(url.pathExtension.lowercased())
    }
}
