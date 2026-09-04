import Foundation

enum RendererHTMLBuilder {
    static func makeHTML(
        snapshot: DocumentSnapshot,
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
            "mermaidTheme": mermaidTheme,
            "reduceMotion": reduceMotion
        ]
        let data = try JSONSerialization.data(withJSONObject: bootstrap, options: [.sortedKeys])
        guard var bootstrapJSON = String(data: data, encoding: .utf8) else {
            throw MD22Error.rendererUnavailable
        }
        bootstrapJSON = bootstrapJSON.replacingOccurrences(of: "</", with: "<\\/")
        let title = escaped(snapshot.url.deletingPathExtension().lastPathComponent)

        return """
        <!doctype html>
        <html lang="en" data-theme="light">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width,initial-scale=1">
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
