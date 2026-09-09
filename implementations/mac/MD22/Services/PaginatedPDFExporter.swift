import AppKit
import WebKit

/// Prints the canonical, static export HTML; it never parses Markdown itself.
@MainActor
final class PaginatedPDFExporter: NSObject, WKNavigationDelegate {
    private var navigation: CheckedContinuation<Void, any Error>?
    private var printing: CheckedContinuation<Void, any Error>?
    private static var isPrinting = false
    private static var printWaiters: [CheckedContinuation<Void, Never>] = []

    func export(html: String, baseURL: URL) async throws -> Data {
        let pointsPerMillimetre = 72.0 / 25.4
        let paperSize = NSSize(width: 210 * pointsPerMillimetre, height: 297 * pointsPerMillimetre)
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        let webView = WKWebView(
            frame: NSRect(origin: .zero, size: paperSize),
            configuration: configuration
        )
        webView.navigationDelegate = self
        defer { webView.navigationDelegate = nil }
        try await withCheckedThrowingContinuation { continuation in
            navigation = continuation
            webView.loadHTMLString(html, baseURL: baseURL)
        }
        try Task.checkCancellation()
        // Static HTML can still contain web fonts and project-relative images.
        _ = try await webView.callAsyncJavaScript("""
            await document.fonts.ready;
            await Promise.race([
                Promise.all([...document.images].filter(image => !image.complete).map(image =>
                    new Promise(resolve => {
                        image.addEventListener('load', resolve, {once: true});
                        image.addEventListener('error', resolve, {once: true});
                    })
                )),
                new Promise(resolve => setTimeout(resolve, 3000))
            ]);
            """, arguments: [:], in: nil, contentWorld: .page)

        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let destination = directory.appending(path: "publication.pdf")
        let info = NSPrintInfo(dictionary: [:])
        info.paperSize = paperSize
        info.orientation = .portrait
        info.leftMargin = 16 * pointsPerMillimetre
        info.rightMargin = 16 * pointsPerMillimetre
        info.topMargin = 18 * pointsPerMillimetre
        info.bottomMargin = 20 * pointsPerMillimetre
        info.horizontalPagination = .fit
        info.verticalPagination = .automatic
        info.isHorizontallyCentered = false
        info.isVerticallyCentered = false
        info.jobDisposition = .save
        info.dictionary()[NSPrintInfo.AttributeKey.jobSavingURL] = destination
        info.dictionary()[NSPrintInfo.AttributeKey.headerAndFooter] = false
        await Self.acquirePrintSlot()
        defer { Self.releasePrintSlot() }
        try Task.checkCancellation()
        let operation = webView.printOperation(with: info)
        // WebKit computes its page range asynchronously on the printing thread.
        // Main-thread printing treats the unknown range as a preview placeholder.
        operation.canSpawnSeparateThread = true
        operation.showsPrintPanel = false
        operation.showsProgressPanel = false
        // An invisible host lets AppKit run its asynchronous print lifecycle
        // without blocking the reader or presenting a print/save panel.
        let host = NSWindow(contentRect: webView.frame, styleMask: [], backing: .buffered, defer: false)
        host.isReleasedWhenClosed = false
        host.contentView = webView
        defer { host.close() }
        try await withCheckedThrowingContinuation { continuation in
            printing = continuation
            operation.runModal(
                for: host,
                delegate: self,
                didRun: #selector(printOperationDidRun(_:success:contextInfo:)),
                contextInfo: nil
            )
        }
        try Task.checkCancellation()
        return try Data(contentsOf: destination)
    }

    @objc nonisolated private func printOperationDidRun(_ operation: NSPrintOperation, success: Bool, contextInfo: UnsafeMutableRawPointer?) {
        // AppKit invokes this selector on its printing thread, not the main actor.
        Task { @MainActor in
            let continuation = printing
            printing = nil
            if success {
                continuation?.resume()
            } else {
                continuation?.resume(throwing: MD22Error.exportFailed)
            }
        }
    }

    private static func acquirePrintSlot() async {
        if isPrinting {
            await withCheckedContinuation { printWaiters.append($0) }
        } else {
            isPrinting = true
        }
    }

    private static func releasePrintSlot() {
        if printWaiters.isEmpty {
            isPrinting = false
        } else {
            printWaiters.removeFirst().resume()
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        finishLoading()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        finishLoading(error: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        finishLoading(error: error)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        finishLoading(error: MD22Error.exportFailed)
    }

    private func finishLoading(error: (any Error)? = nil) {
        let continuation = navigation
        navigation = nil
        if let error {
            continuation?.resume(throwing: error)
        } else {
            continuation?.resume()
        }
    }
}
