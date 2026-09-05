import Foundation
import Testing
@testable import MD22

@Suite("Markdown drag and drop")
struct DocumentDropTests {
    @Test("The first supported Markdown item is selected")
    func supportedDrop() {
        let urls = [URL(fileURLWithPath: "/tmp/image.png"), URL(fileURLWithPath: "/tmp/README.md")]
        #expect(DocumentDropHandler.firstMarkdownURL(in: urls)?.lastPathComponent == "README.md")
    }

    @Test("Invalid drops do not produce a document route")
    func invalidDrop() {
        #expect(DocumentDropHandler.firstMarkdownURL(in: [URL(fileURLWithPath: "/tmp/image.png")]) == nil)
    }
}

