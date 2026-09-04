import Foundation

struct RenderedDocument: Sendable {
    let html: String
    let baseURL: URL
    let pipelineVersion: String
}

enum RendererHTMLBuilder {
    static let pipelineVersion = "md22-renderer-1"

    static func build(
        snapshot: DocumentSnapshot,
        themeID: String = DisplayTheme.light.rawValue,
        themeCSS: String = "",
        mermaidTheme: String = "neutral",
        reduceMotion: Bool = false,
        bundle: Bundle = .main
    ) throws -> RenderedDocument {
        RenderedDocument(
            html: try makeHTML(
                snapshot: snapshot,
                themeID: themeID,
                themeCSS: themeCSS,
                mermaidTheme: mermaidTheme,
                reduceMotion: reduceMotion,
                bundle: bundle
            ),
            baseURL: snapshot.url.deletingLastPathComponent(),
            pipelineVersion: pipelineVersion
        )
    }

    static func makeHTML(
        snapshot: DocumentSnapshot,
        themeID: String = DisplayTheme.light.rawValue,
        themeCSS: String = "",
        mermaidTheme: String = "neutral",
        reduceMotion: Bool = false,
        bundle: Bundle = .main
    ) throws -> String {
        let script = try resource(named: "renderer-entry", extension: "js", bundle: bundle)
        let mermaidScript = snapshot.markdown.contains("```mermaid")
            ? try resource(named: "mermaid-entry", extension: "js", bundle: bundle)
            : ""
        let baseCSS = try resource(named: "base", extension: "css", bundle: bundle)
        let nonce = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let bootstrap: [String: Any] = [
            "markdown": snapshot.markdown,
            "documentURL": snapshot.url.absoluteString,
            "themeID": themeID,
            "mermaidTheme": mermaidTheme,
            "reduceMotion": reduceMotion,
            "missingReferences": LocalReferenceScanner.missingReferences(
                in: snapshot.markdown,
                documentURL: snapshot.url
            )
        ]
        let data = try JSONSerialization.data(withJSONObject: bootstrap, options: [.sortedKeys])
        guard var bootstrapJSON = String(data: data, encoding: .utf8) else {
            throw MD22Error.rendererUnavailable
        }
        bootstrapJSON = bootstrapJSON.replacingOccurrences(of: "</", with: "<\\/")
        let title = escaped(snapshot.url.deletingPathExtension().lastPathComponent)

        return """
        <!doctype html>
        <html lang="en" data-theme="\(escaped(themeID))">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width,initial-scale=1">
          <meta name="generator" content="MD22 \(pipelineVersion)">
          <meta http-equiv="Content-Security-Policy" content="default-src 'none'; base-uri 'none'; form-action 'none'; frame-src 'none'; object-src 'none'; script-src 'nonce-\(nonce)'; style-src 'nonce-\(nonce)'; img-src data: file: https:; media-src data: file: https:; font-src data:; connect-src 'none'">
          <title>\(title)</title>
          <style nonce="\(nonce)">\(baseCSS)\n\(themeCSS)</style>
        </head>
        <body>
          <main id="document-root" aria-label="Markdown document"></main>
          <script nonce="\(nonce)">window.__MD22_ERROR__=null;window.addEventListener('error',event=>{window.__MD22_ERROR__=event.message+' @ '+event.filename+':'+event.lineno});window.addEventListener('unhandledrejection',event=>{window.__MD22_ERROR__=String(event.reason)});window.__MD22_BOOTSTRAP__=\(bootstrapJSON);</script>
          <script nonce="\(nonce)">\(mermaidScript)</script>
          <script nonce="\(nonce)">\(script)</script>
        </body>
        </html>
        """
    }

    private static func resource(named name: String, extension fileExtension: String, bundle: Bundle) throws -> String {
        let candidate = bundle.url(forResource: name, withExtension: fileExtension, subdirectory: "Renderer")
            ?? bundle.url(forResource: name, withExtension: fileExtension)
        guard let url = candidate,
              let value = try? String(contentsOf: url, encoding: .utf8) else {
            throw MD22Error.rendererUnavailable
        }
        return value
    }

    private static func escaped(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}

enum LocalReferenceScanner {
    static func missingReferences(in markdown: String, documentURL: URL) -> [String] {
        guard let expression = try? NSRegularExpression(
            pattern: #"(?<!!)\[[^\]]*\]\(([^\s\)]+)"#
        ) else { return [] }
        let range = NSRange(markdown.startIndex..., in: markdown)
        return expression.matches(in: markdown, range: range).compactMap { match in
            guard let valueRange = Range(match.range(at: 1), in: markdown) else { return nil }
            let reference = String(markdown[valueRange])
            guard !reference.hasPrefix("#"),
                  let url = ResourceResolver.resolve(reference, relativeTo: documentURL),
                  url.isFileURL,
                  !FileManager.default.fileExists(atPath: url.path) else { return nil }
            return reference
        }
    }
}
