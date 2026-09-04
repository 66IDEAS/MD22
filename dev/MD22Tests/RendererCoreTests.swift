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

    @Test("Relative resources resolve beside the document")
    func relativeResources() {
        let document = URL(fileURLWithPath: "/tmp/project/docs/readme.md")
        #expect(ResourceResolver.resolve("../images/diagram.png", relativeTo: document)?.path == "/tmp/project/images/diagram.png")
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

