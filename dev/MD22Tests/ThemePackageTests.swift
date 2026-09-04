import Foundation
import Testing
@testable import MD22

@Suite("Declarative theme packages")
struct ThemePackageTests {
    private let manifest = ThemeManifest(
        schemaVersion: 1,
        id: "sample",
        name: "Sample",
        version: "1.0.0",
        author: "MD22",
        mermaidTheme: "neutral",
        tokens: ThemeTokens(
            page: "#fff", ink: "#111", muted: "#666", accent: "#06c",
            bodyFont: "serif", headingFont: "sans-serif", codeFont: "monospace"
        )
    )

    @Test("A scoped static package is accepted")
    func validPackage() throws {
        let package = ThemePackage(
            manifest: manifest,
            scopedCSS: ":root[data-theme=\"sample\"] { --page: #fff; }",
            staticAssets: ["fonts/readme.txt": Data()]
        )
        try ThemePackageValidator.validate(package)
    }

    @Test("Remote styles and executable assets are rejected")
    func unsafePackage() {
        let package = ThemePackage(
            manifest: manifest,
            scopedCSS: ":root[data-theme=\"sample\"] { background: url(https://tracker.invalid); }",
            staticAssets: ["theme.js": Data()]
        )
        #expect(throws: ThemePackageError.self) { try ThemePackageValidator.validate(package) }
    }

    @Test("The five built-in themes have complete distinct manifests")
    func builtInThemes() {
        #expect(BuiltInThemeCatalog.manifests.map(\.id) == ["light", "dark", "sci-fi", "blueprint", "8-bit"])
        #expect(Set(BuiltInThemeCatalog.manifests.map(\.tokens.page)).count == 5)
        #expect(BuiltInThemeCatalog.manifests.allSatisfy { $0.schemaVersion == 1 })
    }
}
