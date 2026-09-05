import Foundation
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

    @Test("PDF export produces a valid adjacent publication")
    func pdfExport() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let source = directory.appending(path: "Publication.md")
        let markdown = "# Publication\n\n" + Array(repeating: "Polished paragraph text.", count: 80).joined(separator: "\n\n")
        try markdown.write(to: source, atomically: true, encoding: .utf8)
        let snapshot = DocumentSnapshot(
            url: source,
            markdown: markdown,
            modificationDate: nil,
            fileIdentifier: nil
        )

        let output = try await DocumentExportService().exportPDF(
            snapshot: snapshot,
            themeID: DisplayTheme.light.rawValue
        )
        let document = try #require(PDFDocument(url: output))

        #expect(output.lastPathComponent == "Publication.pdf")
        #expect(document.pageCount >= 1)
        #expect(document.string?.contains("Publication") == true)
    }
}
