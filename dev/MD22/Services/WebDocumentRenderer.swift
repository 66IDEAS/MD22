import Foundation
import Observation
import WebKit

@MainActor
@Observable
final class WebDocumentRenderer: DocumentRendering {
    let page: WebPage
    let navigationPolicy: WebNavigationPolicy
    private(set) var renderError: String?
    private(set) var debugMessage: String?
    private(set) var isReady = false
    private(set) var pendingNavigationURL: URL?

    init() {
        var configuration = WebPage.Configuration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.loadsSubresources = true
        configuration.defaultNavigationPreferences.allowsContentJavaScript = true
        let policy = WebNavigationPolicy()
        navigationPolicy = policy
        page = WebPage(configuration: configuration, navigationDecider: policy)
        policy.onOpenURL = { [weak self] url in
            self?.pendingNavigationURL = url
        }
    }

    func render(snapshot: DocumentSnapshot, themeID: String) async throws {
        isReady = false
        renderError = nil
        debugMessage = nil
        do {
            let document = try RendererHTMLBuilder.build(snapshot: snapshot)
            for try await _ in page.load(html: document.html, baseURL: document.baseURL) {}
            for _ in 0..<500 {
                try Task.checkCancellation()
                if let ready = try? await page.callJavaScript(
                    "return document.documentElement.dataset.ready === 'true'",
                    contentWorld: .page
                ) as? Bool, ready {
                    isReady = true
                    return
                }
                try await Task.sleep(for: .milliseconds(20))
            }
            do {
                debugMessage = try await page.callJavaScript(
                    "return JSON.stringify({readyState:document.readyState,bridge:typeof window.MD22,error:window.__MD22_ERROR__,length:document.documentElement.outerHTML.length})",
                    contentWorld: .page
                ) as? String
            } catch {
                debugMessage = "JavaScript probe failed: \(error.localizedDescription)"
            }
            throw MD22Error.rendererUnavailable
        } catch {
            if debugMessage == nil {
                debugMessage = "Navigation or rendering failed: \(String(describing: error))"
            }
            renderError = error.localizedDescription
            throw error
        }
    }

    func navigate(to headingID: String) async {
        _ = try? await page.callJavaScript(
            "window.MD22?.navigateTo(arguments.id)",
            arguments: ["id": headingID],
            contentWorld: .page
        )
    }

    func restore(_ location: ReadingLocation) async {
        guard let data = try? JSONEncoder().encode(location),
              let json = String(data: data, encoding: .utf8) else { return }
        _ = try? await page.callJavaScript(
            "window.MD22?.restore(JSON.parse(arguments.location))",
            arguments: ["location": json],
            contentWorld: .page
        )
    }

    func currentLocation() async -> ReadingLocation {
        guard let result = try? await page.callJavaScript("return window.MD22?.state()", contentWorld: .page),
              let dictionary = result as? [String: Any] else { return .beginning }
        return ReadingLocation(
            headingID: dictionary["headingID"] as? String,
            progress: dictionary["progress"] as? Double ?? 0,
            verticalOffset: dictionary["verticalOffset"] as? Double ?? 0
        )
    }

    func consumePendingNavigation() -> URL? {
        defer { pendingNavigationURL = nil }
        return pendingNavigationURL
    }

    func semanticHTML() async -> String? {
        try? await page.callJavaScript(
            "return document.querySelector('#document-root')?.innerHTML",
            contentWorld: .page
        ) as? String
    }

    func viewState() async -> RendererViewState? {
        guard let result = try? await page.callJavaScript("return window.MD22?.state()", contentWorld: .page),
              let state = result as? [String: Any] else { return nil }
        return RendererViewState(
            location: ReadingLocation(
                headingID: state["headingID"] as? String,
                progress: state["progress"] as? Double ?? 0,
                verticalOffset: state["verticalOffset"] as? Double ?? 0
            ),
            wordCount: state["wordCount"] as? Int ?? 0,
            linkDestination: state["linkDestination"] as? String,
            selectedText: state["selectedText"] as? String ?? ""
        )
    }
}
