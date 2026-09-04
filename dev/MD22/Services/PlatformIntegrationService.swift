import AppKit

@MainActor
final class PlatformIntegrationService: PlatformIntegrating {
    func revealInFinder(_ url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    func openExternally(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
}

