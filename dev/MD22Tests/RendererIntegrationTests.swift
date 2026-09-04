import Foundation
import Testing
@testable import MD22

@MainActor
@Suite("Local WebKit renderer")
struct RendererIntegrationTests {
    @Test("Bundled renderer reaches a ready semantic document")
    func rendererBecomesReady() async throws {
        let snapshot = DocumentSnapshot(
            url: URL(fileURLWithPath: "/tmp/Renderer.md"),
            markdown: "# Rendered\n\nA local **document** with $x^2$.",
            modificationDate: nil,
            fileIdentifier: nil
        )
        let renderer = WebDocumentRenderer()
        do {
            try await renderer.render(snapshot: snapshot, themeID: "light")
        } catch {
            Issue.record("Renderer failed: \(renderer.debugMessage ?? error.localizedDescription)")
            return
        }

        #expect(renderer.isReady)
        let headings = try await renderer.page.callJavaScript("return window.MD22.headings()", contentWorld: .page)
            as? [[String: Any]]
        #expect(headings?.first?["title"] as? String == "Rendered")
    }

    @Test("The generated page has a restrictive content policy")
    func restrictivePolicy() throws {
        let snapshot = DocumentSnapshot(
            url: URL(fileURLWithPath: "/tmp/Security.md"),
            markdown: "# Safe",
            modificationDate: nil,
            fileIdentifier: nil
        )
        let html = try RendererHTMLBuilder.makeHTML(snapshot: snapshot)
        #expect(html.contains("default-src 'none'"))
        #expect(html.contains("connect-src 'none'"))
        #expect(!html.contains("https://cdn"))
        #expect(WebNavigationPolicy.isInternalPageURL(URL(fileURLWithPath: "/tmp/document.md")))
        #expect(!WebNavigationPolicy.isInternalPageURL(URL(string: "https://example.com/tracker")!))
    }
}
