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

    @Test("Reader and export adapters share one versioned pipeline")
    func canonicalPipeline() throws {
        let snapshot = DocumentSnapshot(
            url: URL(fileURLWithPath: "/tmp/Canonical.md"),
            markdown: "# Stable heading\n\n| A | B |\n| - | - |\n| 1 | 2 |",
            modificationDate: nil,
            fileIdentifier: nil
        )
        let artifact = try RendererHTMLBuilder.build(snapshot: snapshot)
        #expect(artifact.pipelineVersion == RendererHTMLBuilder.pipelineVersion)
        #expect(artifact.html.contains("MD22 md22-renderer-1"))
        #expect(artifact.baseURL == snapshot.url.deletingLastPathComponent())
    }

    @Test("Rich Markdown constructs produce sanitized semantic HTML")
    func richMarkdown() async throws {
        let markdown = """
        # Rich

        - [x] Read-only task

        | Feature | Works |
        | --- | --- |
        | Table | Yes |

        ```swift
        let answer = 42
        ```

        Formula: $x^2$.[^1]

        [^1]: A footnote.

        > [!NOTE] Local
        > A callout.

        <script>window.evil = true</script>
        """
        let snapshot = DocumentSnapshot(
            url: URL(fileURLWithPath: "/tmp/Rich.md"),
            markdown: markdown,
            modificationDate: nil,
            fileIdentifier: nil
        )
        let renderer = WebDocumentRenderer()
        try await renderer.render(snapshot: snapshot, themeID: "light")
        let html = try #require(await renderer.semanticHTML())

        #expect(html.contains("task-list-item"))
        #expect(html.contains("<table>"))
        #expect(html.contains("language-swift"))
        #expect(html.contains("class=\"katex\""))
        #expect(html.contains("footnote"))
        #expect(html.contains("callout-note"))
        #expect(!html.contains("<script"))
    }
}
