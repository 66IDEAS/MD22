import Foundation
import Testing
import WebKit
@testable import MD22

enum PerformanceFixture {
    static let small = "# Small\n\nA concise document with **formatting** and a [link](notes.md)."

    static let rich = """
    # Rich performance document

    > [!NOTE] Local rendering remains responsive.

    | Feature | Result |
    | --- | --- |
    | Search | Needle |

    ```swift
    let answer = 42
    ```

    Formula: $x^2 + y^2 = z^2$.[^1]

    [^1]: A local footnote.

    ```mermaid
    graph LR
      A[Markdown] --> B[MD22]
    ```
    """

    static func document(approximately byteCount: Int) -> String {
        let unit = "## Chapter\n\nNeedle paragraph with readable words, `code`, and [local link](notes.md).\n\n"
        let repetitions = max(1, byteCount / unit.utf8.count)
        return String(repeating: unit, count: repetitions)
    }
}

private enum PerformanceBudget {
    static let smallAnalysis = Duration.milliseconds(100)
    static let oneMegabyteAnalysis = Duration.seconds(2)
    static let tenMegabyteAnalysis = Duration.seconds(12)
    static let richRendering = Duration.seconds(8)
    static let interactiveOperation = Duration.seconds(2)
    static let htmlPreparation = Duration.seconds(4)
}

@Suite("Responsiveness budgets", .serialized)
struct PerformanceTests {
    @Test("small, 1 MB, and 10 MB analysis remains within explicit budgets")
    func analysisBudgets() async throws {
        let cases: [(String, Duration)] = [
            (PerformanceFixture.small, PerformanceBudget.smallAnalysis),
            (PerformanceFixture.document(approximately: 1_000_000), PerformanceBudget.oneMegabyteAnalysis),
            (PerformanceFixture.document(approximately: 10_000_000), PerformanceBudget.tenMegabyteAnalysis)
        ]

        for (markdown, budget) in cases {
            let start = ContinuousClock.now
            let analysis = try await MarkdownAnalysis.analyzeAsync(markdown)
            let elapsed = start.duration(to: .now)
            #expect(!analysis.headings.isEmpty)
            #expect(analysis.wordCount > 0)
            #expect(elapsed < budget, "Analysis took \(elapsed), budget \(budget)")
        }
    }

    @MainActor
    @Test("rich rendering, scrolling, search, and HTML preparation remain responsive")
    func richDocumentFlows() async throws {
        let markdown = String(repeating: PerformanceFixture.rich + "\n\n", count: 80)
        let snapshot = DocumentSnapshot(
            url: URL(fileURLWithPath: "/tmp/Performance.md"),
            markdown: markdown,
            modificationDate: nil,
            fileIdentifier: nil
        )
        let renderer = WebDocumentRenderer()

        var start = ContinuousClock.now
        try await renderer.render(snapshot: snapshot, themeID: DisplayTheme.light.rawValue)
        #expect(start.duration(to: .now) < PerformanceBudget.richRendering)

        start = .now
        _ = try await renderer.page.callJavaScript(
            "window.scrollTo(0, document.documentElement.scrollHeight); return window.scrollY",
            contentWorld: .page
        )
        #expect(start.duration(to: .now) < PerformanceBudget.interactiveOperation)

        start = .now
        let search = await renderer.search("Needle")
        #expect(search.matchCount == 80)
        #expect(start.duration(to: .now) < PerformanceBudget.interactiveOperation)

        start = .now
        let html = try await renderer.exportHTML(themeID: DisplayTheme.light.rawValue)
        #expect(html.hasPrefix("<!doctype html>"))
        #expect(start.duration(to: .now) < PerformanceBudget.htmlPreparation)
    }

    @MainActor
    @Test("a newer document request cancels and supersedes obsolete work")
    func obsoleteLoadsAreSuperseded() async throws {
        let access = DelayedFixtureAccess()
        let persistence = try PersistenceController(isStoredInMemoryOnly: true)
        let defaults = try #require(UserDefaults(suiteName: UUID().uuidString))
        let environment = AppEnvironment(fileAccess: access, persistence: persistence, defaults: defaults)
        let session = DocumentSession(environment: environment)
        let slowURL = URL(fileURLWithPath: "/tmp/slow.md")
        let currentURL = URL(fileURLWithPath: "/tmp/current.md")

        session.open(slowURL)
        session.open(currentURL)
        for _ in 0..<200 where session.snapshot?.url != currentURL {
            try await Task.sleep(for: .milliseconds(5))
        }

        #expect(session.snapshot?.url == currentURL)
        #expect(session.snapshot?.markdown == "# Current")
        session.cancel()
    }
}

private actor DelayedFixtureAccess: FileAccessing {
    func read(_ url: URL) async throws -> DocumentSnapshot {
        if url.lastPathComponent == "slow.md" {
            try await Task.sleep(for: .milliseconds(250))
        }
        return DocumentSnapshot(
            url: url,
            markdown: url.lastPathComponent == "slow.md" ? "# Obsolete" : "# Current",
            modificationDate: nil,
            fileIdentifier: nil
        )
    }

    func isAvailable(_ url: URL) async -> Bool { true }
}
