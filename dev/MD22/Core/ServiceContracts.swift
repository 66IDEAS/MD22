import Foundation

protocol FileAccessing: Sendable {
    func read(_ url: URL) async throws -> DocumentSnapshot
    func isAvailable(_ url: URL) async -> Bool
}

@MainActor
protocol DocumentRendering: AnyObject {
    func render(snapshot: DocumentSnapshot, themeID: String) async throws
    func navigate(to headingID: String) async
    func restore(_ location: ReadingLocation) async
    func currentLocation() async -> ReadingLocation
}

@MainActor
protocol HistoryPersisting: AnyObject {
    func reload() throws
    func markUnavailable(path: String) throws
}

@MainActor
protocol DocumentExporting: AnyObject {
    func export(snapshot: DocumentSnapshot, format: ExportFormat, themeID: String) async throws -> URL
}

@MainActor
protocol PlatformIntegrating: AnyObject {
    func revealInFinder(_ url: URL)
    func openExternally(_ url: URL)
}

@MainActor
protocol UpdateChecking: AnyObject {
    var canCheckForUpdates: Bool { get }
    var automaticallyChecksForUpdates: Bool { get set }
    func checkForUpdates()
}
