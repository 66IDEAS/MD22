import Foundation

struct DiagnosticPackageManifest: Codable, Equatable {
    let formatVersion: Int
    let createdAt: Date
    let appVersion: String
    let appBuild: String
    let operatingSystem: String
    let architecture: String
    let includedFiles: [String]
    let privacyStatement: String
}

actor DiagnosticService {
    static let packageExtension = "md22diagnostics"
    static let includedFiles = ["README.txt", "manifest.json", "configuration.json", "recent.log"]

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func createPackage(in parentDirectory: URL) throws -> URL {
        let destination = availableDestination(in: parentDirectory)
        MD22Log.diagnostics.notice("Creating explicit diagnostic package")
        MD22Log.record(category: "diagnostics", code: "package.create.started")
        do {
            try fileManager.createDirectory(at: destination, withIntermediateDirectories: false)

            let manifest = makeManifest()
            try encode(manifest).write(
                to: destination.appending(path: "manifest.json"),
                options: .withoutOverwriting
            )
            try encode(makeConfiguration()).write(
                to: destination.appending(path: "configuration.json"),
                options: .withoutOverwriting
            )
            try Self.readme.write(
                to: destination.appending(path: "README.txt"),
                atomically: true,
                encoding: .utf8
            )
            try recentLogs().write(
                to: destination.appending(path: "recent.log"),
                atomically: true,
                encoding: .utf8
            )
            MD22Log.diagnostics.notice("Diagnostic package created")
            MD22Log.record(category: "diagnostics", code: "package.create.completed")
            return destination
        } catch {
            MD22Log.diagnostics.error("Diagnostic package failed: \(MD22Log.identifier(for: error), privacy: .public)")
            MD22Log.record(category: "diagnostics", code: "package.create.failed")
            throw error
        }
    }

    private func makeManifest() -> DiagnosticPackageManifest {
        let info = Bundle.main.infoDictionary
        return DiagnosticPackageManifest(
            formatVersion: 1,
            createdAt: .now,
            appVersion: info?["CFBundleShortVersionString"] as? String ?? "unknown",
            appBuild: info?["CFBundleVersion"] as? String ?? "unknown",
            operatingSystem: ProcessInfo.processInfo.operatingSystemVersionString,
            architecture: "arm64",
            includedFiles: Self.includedFiles,
            privacyStatement: "No document content, document names, filesystem paths, account data, or telemetry identifiers are included."
        )
    }

    private func makeConfiguration() -> [String: String] {
        [
            "applicationAppearance": UserDefaults.standard.string(forKey: "appAppearance") ?? "system",
            "displayTheme": UserDefaults.standard.string(forKey: "displayTheme") ?? "light",
            "automaticUpdateChecks": String(UserDefaults.standard.bool(forKey: "SUEnableAutomaticChecks")),
            "sandboxed": "false",
            "rendererAssetsPresent": String(Bundle.main.url(forResource: "renderer-entry", withExtension: "js") != nil)
        ]
    }

    private func recentLogs() -> String {
        let formatter = ISO8601DateFormatter()
        let lines = MD22Log.recentEvents().map { event in
            "\(formatter.string(from: event.date)) [\(event.category)] \(event.code)"
        }
        return lines.isEmpty ? "No MD22 diagnostic events were recorded in this process.\n" : lines.joined(separator: "\n") + "\n"
    }

    private func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(value)
    }

    private func availableDestination(in parentDirectory: URL) -> URL {
        for copyNumber in 1...10_000 {
            let name = copyNumber == 1 ? "MD22 Diagnostics" : "MD22 Diagnostics \(copyNumber)"
            let candidate = parentDirectory
                .appending(path: name, directoryHint: .isDirectory)
                .appendingPathExtension(Self.packageExtension)
            if !fileManager.fileExists(atPath: candidate.path) { return candidate }
        }
        return parentDirectory.appending(path: UUID().uuidString).appendingPathExtension(Self.packageExtension)
    }

    private static let readme = """
    MD22 Diagnostic Package
    =======================

    This package was created only because you selected Create Diagnostic Package.
    It is not uploaded or transmitted automatically. You can inspect every file
    with a text editor before sharing it.

    Contents:
    - manifest.json: app, build, operating-system, and package format information
    - configuration.json: non-sensitive appearance, update, and renderer state
    - recent.log: bounded privacy-safe event codes mirrored from MD22 Unified Logging

    Excluded by design:
    - Markdown content and rendered output
    - filenames and filesystem paths
    - history, bookmarks, and search terms
    - account, analytics, telemetry, and hardware identifiers
    """
}
