import CoreGraphics
import Foundation
import PDFKit

/// Extends the publication's paper color through WebKit's unpainted print margins.
/// The original page content stays vector-based and its annotations are retained.
enum PDFPublicationBackground {
    static func apply(to data: Data, color: CGColor) throws -> Data {
        guard let original = PDFDocument(data: data), original.pageCount > 0 else {
            throw MD22Error.exportFailed
        }
        let buffer = NSMutableData()
        guard let consumer = CGDataConsumer(data: buffer as CFMutableData),
              let context = CGContext(consumer: consumer, mediaBox: nil, nil) else {
            throw MD22Error.exportFailed
        }
        for index in 0..<original.pageCount {
            guard let page = original.page(at: index), let reference = page.pageRef else {
                throw MD22Error.exportFailed
            }
            var bounds = page.bounds(for: .mediaBox)
            let box = Data(bytes: &bounds, count: MemoryLayout<CGRect>.size)
            context.beginPDFPage([kCGPDFContextMediaBox: box] as CFDictionary)
            context.setFillColor(color)
            context.fill(bounds)
            context.drawPDFPage(reference)
            context.endPDFPage()
        }
        context.closePDF()
        guard let result = PDFDocument(data: buffer as Data) else { throw MD22Error.exportFailed }
        result.documentAttributes = original.documentAttributes
        // Core Graphics draws content streams but not link annotations. Copy
        // annotations separately and remap internal destinations to the new pages.
        for index in 0..<original.pageCount {
            guard let source = original.page(at: index), let target = result.page(at: index) else {
                throw MD22Error.exportFailed
            }
            for annotation in source.annotations {
                guard let copy = annotation.copy() as? PDFAnnotation else { continue }
                if let destination = annotation.destination, let sourcePage = destination.page,
                   let targetPage = result.page(at: original.index(for: sourcePage)) {
                    let mapped = PDFDestination(page: targetPage, at: destination.point)
                    mapped.zoom = destination.zoom
                    copy.destination = mapped
                }
                target.addAnnotation(copy)
            }
        }
        guard let output = result.dataRepresentation() else { throw MD22Error.exportFailed }
        return output
    }
}
