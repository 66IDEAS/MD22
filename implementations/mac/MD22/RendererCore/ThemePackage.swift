import Foundation

struct ThemeTokens: Codable, Sendable, Equatable {
    let page: String
    let ink: String
    let muted: String
    let accent: String
    let bodyFont: String
    let headingFont: String
    let codeFont: String
}

struct ThemeManifest: Codable, Sendable, Identifiable, Equatable {
    let schemaVersion: Int
    let id: String
    let name: String
    let version: String
    let author: String
    let mermaidTheme: String
    let tokens: ThemeTokens
}

struct ThemePackage: Sendable, Equatable {
    let manifest: ThemeManifest
    let scopedCSS: String
    let staticAssets: [String: Data]
}

enum ThemePackageError: LocalizedError, Equatable {
    case unsupportedSchema
    case invalidIdentifier
    case unsafeCSS
    case unsafeAssetPath
    case packageTooLarge

    var errorDescription: String? {
        switch self {
        case .unsupportedSchema: "The theme uses an unsupported format."
        case .invalidIdentifier: "The theme identifier is invalid."
        case .unsafeCSS: "The theme contains styles that are not permitted."
        case .unsafeAssetPath: "The theme contains an unsafe asset path."
        case .packageTooLarge: "The theme is too large."
        }
    }
}

enum ThemePackageValidator {
    static let currentSchemaVersion = 1
    static let maximumPackageBytes = 2 * 1_024 * 1_024

    static func validate(_ package: ThemePackage) throws {
        guard package.manifest.schemaVersion == currentSchemaVersion else {
            throw ThemePackageError.unsupportedSchema
        }
        let identifier = package.manifest.id
        guard identifier.range(of: #"^[a-z0-9][a-z0-9-]{0,63}$"#, options: .regularExpression) != nil else {
            throw ThemePackageError.invalidIdentifier
        }
        let loweredCSS = package.scopedCSS.lowercased()
        let prohibitedCSS = ["@import", "javascript:", "expression(", "url(http:", "url(https:", "behavior:"]
        guard prohibitedCSS.allSatisfy({ !loweredCSS.contains($0) }) else {
            throw ThemePackageError.unsafeCSS
        }
        let requiredScope = #":root[data-theme="\#(identifier)"]"#
        guard package.scopedCSS.contains(requiredScope) else {
            throw ThemePackageError.unsafeCSS
        }
        guard package.staticAssets.keys.allSatisfy({ path in
            !path.hasPrefix("/") && !path.contains("..") && URL(fileURLWithPath: path).pathExtension.lowercased() != "js"
        }) else {
            throw ThemePackageError.unsafeAssetPath
        }
        let packageSize = package.scopedCSS.utf8.count + package.staticAssets.values.reduce(0) { $0 + $1.count }
        guard packageSize <= maximumPackageBytes else { throw ThemePackageError.packageTooLarge }
    }
}
