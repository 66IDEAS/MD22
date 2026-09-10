import AppKit
import UniformTypeIdentifiers

// Run after installing/registering MD22. Launch Services needs actual files,
// so use disposable fixtures; never open them or change the default application.
let appURL = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "/Applications/MD22.app")
let extensions = ["md", "markdown", "mdown", "mkd", "mkdn"]
let fixtureDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("md22-associations-\(UUID())")
try FileManager.default.createDirectory(at: fixtureDirectory, withIntermediateDirectories: false)
defer { try? FileManager.default.removeItem(at: fixtureDirectory) }
var failures = 0
for ext in extensions {
    let url = fixtureDirectory.appendingPathComponent("MD22 Association Check.\(ext)")
    try "# Markdown association check\n".write(to: url, atomically: true, encoding: .utf8)
    let handlers = NSWorkspace.shared.urlsForApplications(toOpen: url)
    let registered = handlers.contains { $0.standardizedFileURL == appURL.standardizedFileURL }
    let type = UTType(filenameExtension: ext)?.identifier ?? "unknown"
    print("\(registered ? "PASS" : "FAIL") .\(ext): \(type), MD22 available in Open With: \(registered)")
    if !registered { failures += 1 }
}
if failures > 0 {
    try FileManager.default.removeItem(at: fixtureDirectory)
    exit(EXIT_FAILURE)
}
