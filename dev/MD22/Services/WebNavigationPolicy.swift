import Foundation
import WebKit

@MainActor
final class WebNavigationPolicy: WebPage.NavigationDeciding {
    var onOpenURL: ((URL) -> Void)?

    func decidePolicy(
        for action: WebPage.NavigationAction,
        preferences: inout WebPage.NavigationPreferences
    ) async -> WKNavigationActionPolicy {
        guard action.navigationType == .linkActivated,
              let url = action.request.url else { return .allow }
        onOpenURL?(url)
        return .cancel
    }

    func decidePolicy(for response: WebPage.NavigationResponse) async -> WKNavigationResponsePolicy {
        response.canShowMimeType ? .allow : .cancel
    }
}
