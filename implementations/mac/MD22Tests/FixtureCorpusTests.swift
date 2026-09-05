import Foundation
import Testing
@testable import MD22

@MainActor
@Suite("Markdown fixture corpus", .serialized)
struct FixtureCorpusTests {
    @Test("basic fixture has stable semantic structure")
    func basicSemantics() throws {
        let markdown = try fixture(named: "basic")
        let analysis = MarkdownAnalysis.analyze(markdown)
        #expect(analysis.headings.map(\.id) == ["fixture-document", "section-one", "section-two"])
        #expect(analysis.wordCount > 20)
    }

    @Test("rich fixture renders through every built-in theme")
    func richThemeRegression() async throws {
        let markdown = try fixture(named: "rich")
        for theme in DisplayTheme.allCases {
            let renderer = WebDocumentRenderer()
            let snapshot = DocumentSnapshot(
                url: fixtureURL(named: "rich"),
                markdown: markdown,
                modificationDate: nil,
                fileIdentifier: nil
            )
            try await renderer.render(snapshot: snapshot, themeID: theme.rawValue)
            let html = try #require(await renderer.semanticHTML())
            #expect(html.contains("<table>"), "Table missing in \(theme.rawValue)")
            #expect(html.contains("class=\"katex\""), "Math missing in \(theme.rawValue)")
            #expect(html.contains("callout-tip"), "Callout missing in \(theme.rawValue)")
            let activeTheme = try await renderer.page.callJavaScript(
                "return document.documentElement.dataset.theme",
                contentWorld: .page
            ) as? String
            #expect(activeTheme == theme.rawValue)
        }
    }

    @Test("hostile fixture is sanitized without losing readable content")
    func hostileHTML() async throws {
        let markdown = try fixture(named: "hostile")
        let renderer = WebDocumentRenderer()
        try await renderer.render(
            snapshot: DocumentSnapshot(
                url: fixtureURL(named: "hostile"),
                markdown: markdown,
                modificationDate: nil,
                fileIdentifier: nil
            ),
            themeID: DisplayTheme.light.rawValue
        )
        let html = try #require(await renderer.semanticHTML())
        #expect(html.contains("Readable text remains"))
        #expect(!html.contains("<script"))
        #expect(!html.contains("onerror="))
        #expect(!html.contains("href=\"javascript:"))
    }

    private func fixture(named name: String) throws -> String {
        try String(contentsOf: fixtureURL(named: name), encoding: .utf8)
    }

    private func fixtureURL(named name: String) -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appending(path: "Fixtures", directoryHint: .isDirectory)
            .appending(path: name)
            .appendingPathExtension("md")
    }
}
