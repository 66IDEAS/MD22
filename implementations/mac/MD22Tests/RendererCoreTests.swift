import Foundation
import Testing
@testable import MD22

@Suite("Reusable renderer core")
struct RendererCoreTests {
    @Test("Analysis creates stable unique heading anchors")
    func headingAnchors() {
        let result = MarkdownAnalysis.analyze("# Résumé\n## Details\n## Details\n```\n# ignored\n```")
        #expect(result.headings.map(\.id) == ["resume", "details", "details-1"])
    }

    @Test("Analysis provides reading metrics for the status bar")
    func readingMetrics() {
        let words = Array(repeating: "word", count: 440).joined(separator: " ")
        let result = MarkdownAnalysis.analyze("# Chapter\n\n\(words)")
        #expect(result.wordCount == 441)
        #expect(result.estimatedReadingMinutes == 3)
        #expect(result.headings.first?.title == "Chapter")
    }

    @Test("Relative resources resolve beside the document")
    func relativeResources() {
        let document = URL(fileURLWithPath: "/tmp/project/docs/readme.md")
        #expect(ResourceResolver.resolve("../images/diagram.png", relativeTo: document)?.path == "/tmp/project/images/diagram.png")
        let linked = ResourceResolver.resolve("chapter.md#details", relativeTo: document)
        #expect(linked?.path == "/tmp/project/docs/chapter.md")
        #expect(linked?.fragment == "details")
    }

    @Test("Missing project links are identified without indexing the project")
    func missingReferences() {
        let document = URL(fileURLWithPath: "/tmp/project/readme.md")
        let missing = LocalReferenceScanner.missingReferences(
            in: "[Missing](docs/unknown.md) [Web](https://example.com)",
            documentURL: document
        )
        #expect(missing == ["docs/unknown.md"])
    }

    @Test("A missing heading falls back to bounded reading progress")
    func bookmarkFallback() {
        let target = BookmarkTarget(
            kind: .heading,
            headingID: "removed",
            excerpt: nil,
            location: ReadingLocation(headingID: "removed", progress: 2, verticalOffset: -4)
        )
        let location = BookmarkLocator.bestLocation(
            for: target,
            in: DocumentAnalysis(headings: [], wordCount: 0, estimatedReadingMinutes: 1)
        )
        #expect(location == ReadingLocation(headingID: nil, progress: 1, verticalOffset: 0))
    }
}
