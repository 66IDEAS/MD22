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
        let suite = try #require(UserDefaults(suiteName: UUID().uuidString))
        let environment = AppEnvironment(persistence: persistence, defaults: suite)
        let session = DocumentSession(environment: environment)
        session.open(file)

        for _ in 0..<100 where session.snapshot == nil && session.errorMessage == nil {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(session.snapshot?.markdown.contains("Hello") == true)
        #expect(environment.history.recentRecords.first?.canonicalPath == file.path)
    }

    @Test("A saved file refreshes without discarding the current document")
    func refresh() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appending(path: "README.md")
        try "# Before".write(to: file, atomically: true, encoding: .utf8)

        let persistence = try PersistenceController(isStoredInMemoryOnly: true)
        let suite = try #require(UserDefaults(suiteName: UUID().uuidString))
        let environment = AppEnvironment(persistence: persistence, defaults: suite)
        let session = DocumentSession(environment: environment)
        session.open(file)
        for _ in 0..<100 where session.snapshot == nil {
            try await Task.sleep(for: .milliseconds(10))
        }

        try "# After".write(to: file, atomically: true, encoding: .utf8)
        session.refreshAfterExternalChange(debounce: .zero)
        for _ in 0..<100 where session.snapshot?.markdown != "# After" {
            try await Task.sleep(for: .milliseconds(10))
        }

        #expect(session.snapshot?.markdown == "# After")
        #expect(session.transientMessage == "Refreshed")
        session.cancel()
    }

    @Test("Reading positions survive reopening and history removal")
    func readingContinuity() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appending(path: "Long.md")
        try "# Start\n\n# Chapter".write(to: file, atomically: true, encoding: .utf8)

        let persistence = try PersistenceController(isStoredInMemoryOnly: true)
        let suite = try #require(UserDefaults(suiteName: UUID().uuidString))
        let environment = AppEnvironment(persistence: persistence, defaults: suite)
        let location = ReadingLocation(headingID: "chapter", progress: 0.7, verticalOffset: 900)
        try environment.history.saveReadingLocation(location, for: file)
        let session = DocumentSession(environment: environment)
        session.open(file)
        for _ in 0..<100 where session.snapshot == nil {
            try await Task.sleep(for: .milliseconds(10))
        }

        #expect(session.readingLocation == location)
        #expect(environment.history.lastDocumentURL == file)
        let record = try #require(environment.history.recentRecords.first)
        try environment.history.remove(record)
        #expect(try environment.history.readingLocation(for: file) == location)
        session.cancel()
    }
}
