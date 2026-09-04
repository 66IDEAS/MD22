import Foundation

@MainActor
final class DocumentExportService {
    private let writer: ExportFileWriter

    init(writer: ExportFileWriter = ExportFileWriter()) {
        self.writer = writer
    }

    func exportHTML(
        snapshot: DocumentSnapshot,
        renderer: WebDocumentRenderer,
        themeID: String
    ) async throws -> URL {
        MD22Log.export.notice("HTML export started")
        MD22Log.record(category: "export", code: "html.started")
        let html = try await renderer.exportHTML(themeID: themeID)
        guard let data = html.data(using: .utf8) else { throw MD22Error.exportFailed }
        let url = try await writer.write(data, beside: snapshot.url, pathExtension: "html")
        MD22Log.export.notice("HTML export completed; bytes=\(data.count, privacy: .public)")
        MD22Log.record(category: "export", code: "html.completed")
        return url
    }

    func exportPDF(snapshot: DocumentSnapshot, themeID: String) async throws -> URL {
        MD22Log.export.notice("PDF export started")
        MD22Log.record(category: "export", code: "pdf.started")
        let exportRenderer = WebDocumentRenderer()
        try await exportRenderer.render(snapshot: snapshot, themeID: themeID)
        try await exportRenderer.prepareForExport(themeID: themeID)
        let data = try await exportRenderer.page.exported(
            as: .pdf(region: .contents, allowTransparentBackground: false)
        )
        guard data.starts(with: Data("%PDF".utf8)) else { throw MD22Error.exportFailed }
        let url = try await writer.write(data, beside: snapshot.url, pathExtension: "pdf")
        MD22Log.export.notice("PDF export completed; bytes=\(data.count, privacy: .public)")
        MD22Log.record(category: "export", code: "pdf.completed")
        return url
    }
}

actor ExportFileWriter {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func write(_ data: Data, beside sourceURL: URL, pathExtension: String) throws -> URL {
        for copyNumber in 1...10_000 {
            let destination = Self.destination(
                beside: sourceURL,
                pathExtension: pathExtension,
                copyNumber: copyNumber
            )
            do {
                try data.write(to: destination, options: .withoutOverwriting)
                return destination
            } catch let error as CocoaError where error.code == .fileWriteFileExists {
                continue
            } catch {
                throw MD22Error.exportFailed
            }
        }
        throw MD22Error.exportFailed
    }

    nonisolated static func destination(
        beside sourceURL: URL,
        pathExtension: String,
        copyNumber: Int
    ) -> URL {
        let stem = sourceURL.deletingPathExtension().lastPathComponent
        let filename = copyNumber == 1 ? stem : "\(stem) \(copyNumber)"
        return sourceURL.deletingLastPathComponent()
            .appending(path: filename)
            .appendingPathExtension(pathExtension)
    }
}
