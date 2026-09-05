import Foundation
import Testing
@testable import MD22

@MainActor
@Suite("Read-only source guarantee")
struct ReadOnlyGuaranteeTests {
    @Test("Opening a document never changes its source bytes")
    func openingPreservesSource() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appending(path: "immutable.md")
        try "# Immutable\n\n- [ ] task".write(to: file, atomically: true, encoding: .utf8)
        let before = try ReadOnlyPolicy.sourceFingerprint(at: file)

        let persistence = try PersistenceController(isStoredInMemoryOnly: true)
        let session = DocumentSession(environment: AppEnvironment(persistence: persistence))
        session.open(file)
        for _ in 0..<100 where session.snapshot == nil && session.errorMessage == nil {
            try await Task.sleep(for: .milliseconds(10))
        }

        #expect(ReadOnlyPolicy.supportsSourceEditing == false)
        #expect(ReadOnlyPolicy.supportsSourceSaving == false)
        #expect(try ReadOnlyPolicy.sourceFingerprint(at: file) == before)
    }
}

