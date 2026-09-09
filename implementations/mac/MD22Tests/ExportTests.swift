import AppKit
import PDFKit
import Testing
@testable import MD22

@MainActor
@Suite("Document export")
struct ExportTests {
    @Test("HTML export is static, themed, adjacent, and never overwrites")
    func htmlExport() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let source = directory.appending(path: "Guide.md")
        try "# Guide\n\nNeedle and **structure**.".write(to: source, atomically: true, encoding: .utf8)
        try "existing".write(
            to: directory.appending(path: "Guide.html"),
            atomically: true,
            encoding: .utf8
        )
        let snapshot = DocumentSnapshot(
            url: source,
            markdown: try String(contentsOf: source, encoding: .utf8),
            modificationDate: nil,
            fileIdentifier: nil
        )
        let renderer = WebDocumentRenderer()
        try await renderer.render(snapshot: snapshot, themeID: DisplayTheme.dark.rawValue)
        _ = await renderer.search("Needle")

        let output = try await DocumentExportService().exportHTML(
            snapshot: snapshot,
            renderer: renderer,
            themeID: DisplayTheme.blueprint.rawValue
        )
        let html = try String(contentsOf: output, encoding: .utf8)
        let readerTheme = try await renderer.page.callJavaScript(
            "return document.documentElement.dataset.theme",
            contentWorld: .page
        ) as? String
        let readerSearchCount = try await renderer.page.callJavaScript(
            "return window.MD22.state().searchCount",
            contentWorld: .page
        ) as? NSNumber

        #expect(output.lastPathComponent == "Guide 2.html")
        #expect(html.contains("data-theme=\"blueprint\""))
        #expect(html.contains("<h1 id=\"guide\""))
        #expect(!html.contains("<script"))
        #expect(!html.contains("class=\"bookmark-heading\""))
        #expect(!html.contains("class=\"copy-code\""))
        #expect(!html.contains("class=\"search-match"))
        #expect(readerTheme == DisplayTheme.dark.rawValue)
        #expect(readerSearchCount?.intValue == 1)
        #expect(try String(contentsOf: directory.appending(path: "Guide.html"), encoding: .utf8) == "existing")
    }

    @Test("PDF export paginates long publications on A4", arguments: ["light", "dark", "blueprint", "sci-fi", "8-bit"])
    func pdfExport(themeID: String) async throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let source = directory.appending(path: "Publication.md")
        let markdown = "# Publication\n\n" + (1...80).map {
            "Paragraph\($0) has readable text that must survive pagination."
        }.joined(separator: "\n\n") + "\n\n[Website](https://example.com/reading)\n\n```swift\nlet finalCodeMarker = 42\n```\n\n| Column | Value |\n| --- | --- |\n| FinalTableMarker | 123 |"
        try markdown.write(to: source, atomically: true, encoding: .utf8)
        let snapshot = DocumentSnapshot(
            url: source,
            markdown: markdown,
            modificationDate: nil,
            fileIdentifier: nil
        )

        let output = try await DocumentExportService().exportPDF(
            snapshot: snapshot,
            themeID: themeID
        )
        let document = try #require(PDFDocument(url: output))

        Attachment.record(try Data(contentsOf: output), named: "publication-\(themeID).pdf")

        #expect(output.lastPathComponent == "Publication.pdf")
        #expect(document.pageCount > 1)
        try assertA4Pages(document)
        #expect(document.string?.localizedCaseInsensitiveContains("Publication") == true)
        for index in 1...80 {
            #expect(document.string?.contains("Paragraph\(index) ") == true)
        }
        #expect(document.string?.contains("finalCodeMarker") == true)
        #expect(document.string?.contains("\nCopy\n") == false)
        #expect(document.string?.contains("FinalTableMarker") == true)
        let firstPage = try #require(document.page(at: 0))
        let attributed = try #require(firstPage.attributedString)
        let bodyRange = (attributed.string as NSString).range(of: "Paragraph1")
        #expect(bodyRange.location != NSNotFound)
        let font = try #require(attributed.attribute(.font, at: bodyRange.location, effectiveRange: nil) as? NSFont)
        // WebKit's native print shrink factor slightly adjusts CSS point sizes.
        #expect(abs(font.pointSize - 10.5) < 1)
        let links = (0..<document.pageCount).flatMap { document.page(at: $0)?.annotations ?? [] }
        #expect(links.contains { ($0.action as? PDFActionURL)?.url?.absoluteString == "https://example.com/reading" })
        let preview = firstPage.thumbnail(of: NSSize(width: 300, height: 425), for: .mediaBox)
        let tiff = try #require(preview.tiffRepresentation)
        let bitmap = try #require(NSBitmapImageRep(data: tiff))
        let corner = try #require(bitmap.colorAt(x: 2, y: 2)?.usingColorSpace(.sRGB))
        if themeID == "light" {
            #expect(corner.redComponent > 0.95 && corner.greenComponent > 0.95 && corner.blueComponent > 0.95)
        } else {
            #expect(corner.redComponent < 0.25 && corner.greenComponent < 0.4)
        }
        #expect(try String(contentsOf: source, encoding: .utf8) == markdown)
    }

    @Test("Short PDF publications use one A4 page and never overwrite")
    func shortPDFExport() async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let source = directory.appending(path: "Short.md")
        let existing = directory.appending(path: "Short.pdf")
        try Data("existing".utf8).write(to: existing)
        let snapshot = DocumentSnapshot(
            url: source, markdown: "# Short\n\nOne A4 page.", modificationDate: nil, fileIdentifier: nil
        )
        let output = try await DocumentExportService().exportPDF(snapshot: snapshot, themeID: "light")
        let document = try #require(PDFDocument(url: output))
        #expect(output.lastPathComponent == "Short 2.pdf")
        #expect(try Data(contentsOf: existing) == Data("existing".utf8))
        #expect(document.pageCount == 1)
        #expect(document.string?.contains("One A4 page.") == true)
        try assertA4Pages(document)
    }

    private func assertA4Pages(_ document: PDFDocument) throws {
        for index in 0..<document.pageCount {
            let page = try #require(document.page(at: index))
            let bounds = page.bounds(for: .mediaBox)
            #expect(abs(bounds.width - 210 * 72 / 25.4) < 1)
            #expect(abs(bounds.height - 297 * 72 / 25.4) < 1)
            #expect(page.string?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        }
    }
}
