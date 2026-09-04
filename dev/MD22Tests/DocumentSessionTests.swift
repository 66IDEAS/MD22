import Foundation
import Testing
@testable import MD22

@MainActor
@Suite("Direct document opening")
struct DocumentSessionTests {
    @Test("Opening reads and records a Markdown file")
    func opening() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appending(path: "README.md")
        try "# Hello\n\nRead me.".write(to: file, atomically: true, encoding: .utf8)

        let persistence = try PersistenceController(isStoredInMemoryOnly: true)
        let environment = AppEnvironment(persistence: persistence)
        let session = DocumentSession(environment: environment)
        session.open(file)

        for _ in 0..<100 where session.snapshot == nil && session.errorMessage == nil {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(session.snapshot?.markdown.contains("Hello") == true)
        #expect(environment.history.recentRecords.first?.canonicalPath == file.path)
    }
}

