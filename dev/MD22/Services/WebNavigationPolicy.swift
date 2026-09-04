import Foundation
import WebKit

@MainActor
final class WebNavigationPolicy: WebPage.NavigationDeciding {
    var onOpenURL: ((URL) -> Void)?

    func decidePolicy(
        for action: WebPage.NavigationAction,
        preferences: inout WebPage.NavigationPreferences
    ) async -> WKNavigationActionPolicy {
        guard let url = action.request.url else { return .cancel }
        if action.navigationType == .linkActivated {
            onOpenURL?(url)
            return .cancel
        }
        return Self.isInternalPageURL(url) ? .allow : .cancel
    }

    func decidePolicy(for response: WebPage.NavigationResponse) async -> WKNavigationResponsePolicy {
        guard response.canShowMimeType,
              let url = response.response.url,
              Self.isInternalPageURL(url) else { return .cancel }
        return .allow
    }

    nonisolated static func isInternalPageURL(_ url: URL) -> Bool {
        url.scheme == "file" || url.scheme == "about"
    }
}
