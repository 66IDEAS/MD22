import Foundation
import Testing
@testable import MD22

@Suite("Privacy-safe diagnostics")
struct DiagnosticServiceTests {
    @Test("package is inspectable, complete, unique, and content-free")
    func packageContents() async throws {
        let root = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let service = DiagnosticService()
        let first = try await service.createPackage(in: root)
        let second = try await service.createPackage(in: root)

        #expect(first != second)
        let names = try Set(FileManager.default.contentsOfDirectory(atPath: first.path))
        #expect(names == Set(DiagnosticService.includedFiles))

        let manifestData = try Data(contentsOf: first.appending(path: "manifest.json"))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let manifest = try decoder.decode(DiagnosticPackageManifest.self, from: manifestData)
        #expect(manifest.formatVersion == 1)
        #expect(manifest.architecture == "arm64")
        #expect(!manifest.privacyStatement.isEmpty)

        let combined = try DiagnosticService.includedFiles
            .map { try String(contentsOf: first.appending(path: $0), encoding: .utf8) }
            .joined(separator: "\n")
        #expect(!combined.contains(root.path))
    }

    @Test("error identifiers exclude localized user-derived descriptions")
    func errorIdentifier() {
        let error = NSError(domain: "example", code: 42, userInfo: [NSLocalizedDescriptionKey: "/secret/file.md"])
        let identifier = MD22Log.identifier(for: error)
        #expect(identifier.contains("example:42"))
        #expect(!identifier.contains("secret"))
    }
}
