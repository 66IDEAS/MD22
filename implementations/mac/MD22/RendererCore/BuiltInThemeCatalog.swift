import Foundation

enum BuiltInThemeCatalog {
    static let manifests: [ThemeManifest] = [
        manifest("light", "Light", page: "#f7f1e3", ink: "#28251f", muted: "#716a5f", accent: "#1e6689", body: "Charter", heading: "Avenir Next"),
        manifest("dark", "Dark", page: "#17191d", ink: "#e9e8e3", muted: "#a5a8af", accent: "#7cc6e8", body: "Charter", heading: "Avenir Next", mermaid: "dark"),
        manifest("sci-fi", "Sci-Fi", page: "#07131d", ink: "#d8f2f2", muted: "#82a5aa", accent: "#37e3e0", body: "Avenir Next", heading: "Futura", mermaid: "dark"),
        manifest("blueprint", "Blueprint", page: "#064b94", ink: "#eefaff", muted: "#b9dced", accent: "#8be8ff", body: "SF Mono", heading: "SF Mono", mermaid: "dark"),
        manifest("8-bit", "8-Bit", page: "#1a1530", ink: "#fff7d6", muted: "#c4b9d9", accent: "#5ce1e6", body: "Avenir Next", heading: "SF Mono", mermaid: "dark")
    ]

    static func manifest(for id: String) -> ThemeManifest {
        manifests.first { $0.id == id } ?? manifests[0]
    }

    private static func manifest(
        _ id: String,
        _ name: String,
        page: String,
        ink: String,
        muted: String,
        accent: String,
        body: String,
        heading: String,
        mermaid: String = "neutral"
    ) -> ThemeManifest {
        ThemeManifest(
            schemaVersion: 1,
            id: id,
            name: name,
            version: "1.0.0",
            author: "MD22",
            mermaidTheme: mermaid,
            tokens: ThemeTokens(
                page: page,
                ink: ink,
                muted: muted,
                accent: accent,
                bodyFont: body,
                headingFont: heading,
                codeFont: "SF Mono"
            )
        )
    }
}
