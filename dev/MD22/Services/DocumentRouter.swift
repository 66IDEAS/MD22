import AppKit
import Observation
import UniformTypeIdentifiers

enum DocumentRouteSource: String, Sendable, Codable, Hashable {
    case openPanel
    case finder
    case drop
    case history
    case bookmark
    case link
    case restoration
}

enum DocumentOpenDisposition: Sendable {
    case currentWindow
    case newWindow
}

struct DocumentRoute: Identifiable, Sendable {
    let id = UUID()
    let url: URL
    let source: DocumentRouteSource
    let disposition: DocumentOpenDisposition
    let bookmarkID: UUID?
    let headingID: String?
    let location: ReadingLocation?
}

struct DocumentWindowRequest: Identifiable, Sendable, Codable, Hashable {
    let id: UUID
    let path: String
    let source: DocumentRouteSource
    let bookmarkID: UUID?
    let headingID: String?
    let location: ReadingLocation?

    init(route: DocumentRoute) {
        id = route.id
        path = route.url.standardizedFileURL.path
        source = route.source
        bookmarkID = route.bookmarkID
        headingID = route.headingID
        location = route.location
    }

    var url: URL { URL(fileURLWithPath: path) }
}

@MainActor
@Observable
final class DocumentRouter {
    private(set) var pendingRoute: DocumentRoute?
    private let platform: any PlatformIntegrating

    init(platform: any PlatformIntegrating) {
        self.platform = platform
    }

    nonisolated static let allowedExtensions: Set<String> = ["md", "markdown", "mdown", "mkd", "mkdn"]

    static var contentTypes: [UTType] {
        var types: [UTType] = []
        for pathExtension in allowedExtensions {
            if let type = UTType(filenameExtension: pathExtension), !types.contains(type) {
                types.append(type)
            }
        }
        return types.isEmpty ? [.plainText] : types
    }

    @discardableResult
    func route(
        _ url: URL,
        source: DocumentRouteSource,
        disposition: DocumentOpenDisposition = .currentWindow,
        bookmarkID: UUID? = nil,
        location: ReadingLocation? = nil
    ) throws -> DocumentRoute {
        let headingID = url.fragment
        var components = URLComponents(url: url.standardizedFileURL, resolvingAgainstBaseURL: false)
        components?.fragment = nil
        let canonicalURL = components?.url ?? url.standardizedFileURL
        guard Self.accepts(canonicalURL) else { throw MD22Error.unsupportedFile }
        let route = DocumentRoute(
            url: canonicalURL,
            source: source,
            disposition: disposition,
            bookmarkID: bookmarkID,
            headingID: headingID,
            location: location
        )
        pendingRoute = route
        return route
    }

    func chooseMarkdownFile() async -> URL? {
        let panel = NSOpenPanel()
        panel.title = String(localized: "Open Markdown")
        panel.prompt = String(localized: "Open")
        panel.allowedContentTypes = Self.contentTypes
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.resolvesAliases = true
        guard await panel.begin() == .OK else { return nil }
        return panel.url
    }

    func resolveAndRoute(
        reference: String,
        relativeTo documentURL: URL,
        disposition: DocumentOpenDisposition = .currentWindow
    ) throws {
        guard let destination = ResourceResolver.resolve(reference, relativeTo: documentURL) else {
            throw MD22Error.unavailableFile
        }
        if destination.isFileURL, Self.accepts(destination) {
            try route(destination, source: .link, disposition: disposition)
        } else {
            platform.openExternally(destination)
        }
    }

    func reveal(_ url: URL) {
        platform.revealInFinder(url)
    }

    func openExternally(_ url: URL) {
        platform.openExternally(url)
    }

    nonisolated static func accepts(_ url: URL) -> Bool {
        url.isFileURL && allowedExtensions.contains(url.pathExtension.lowercased())
    }
}
