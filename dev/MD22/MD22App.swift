import SwiftUI

@main
struct MD22App: App {
    @State private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup(for: DocumentWindowRequest.self) { request in
            ContentView(initialRequest: request.wrappedValue)
                .environment(environment)
        }
        .defaultSize(width: 1_240, height: 800)
        .commands {
            CommandGroup(after: .saveItem) {
                Button("Add Bookmark") {
                    NotificationCenter.default.post(name: .md22AddBookmark, object: nil)
                }
                .keyboardShortcut("d", modifiers: .command)
            }
            CommandMenu("Navigate") {
                Button("Back") {
                    NotificationCenter.default.post(name: .md22NavigateBack, object: nil)
                }
                .keyboardShortcut("[", modifiers: .command)
                Button("Forward") {
                    NotificationCenter.default.post(name: .md22NavigateForward, object: nil)
                }
                .keyboardShortcut("]", modifiers: .command)
                Divider()
                Button("Find in Document") {
                    NotificationCenter.default.post(name: .md22ToggleSearch, object: nil)
                }
                .keyboardShortcut("f", modifiers: .command)
                Divider()
                Button("Focus History") {
                    NotificationCenter.default.post(name: .md22FocusHistory, object: nil)
                }
                .keyboardShortcut("1", modifiers: .control)
                Button("Focus Document") {
                    NotificationCenter.default.post(name: .md22FocusDocument, object: nil)
                }
                .keyboardShortcut("2", modifiers: .control)
                Button("Focus Inspector") {
                    NotificationCenter.default.post(name: .md22FocusInspector, object: nil)
                }
                .keyboardShortcut("3", modifiers: .control)
                Button("Focus Status Bar") {
                    NotificationCenter.default.post(name: .md22FocusStatusBar, object: nil)
                }
                .keyboardShortcut("4", modifiers: .control)
            }
            CommandMenu("Reading") {
                Button("Toggle History") {
                    NotificationCenter.default.post(name: .md22ToggleHistory, object: nil)
                }
                .keyboardShortcut("1", modifiers: [.command, .option])
                Button("Toggle Inspector") {
                    NotificationCenter.default.post(name: .md22ToggleInspector, object: nil)
                }
                .keyboardShortcut("2", modifiers: [.command, .option])
                Button("Toggle Status Bar") {
                    NotificationCenter.default.post(name: .md22ToggleStatusBar, object: nil)
                }
                .keyboardShortcut("3", modifiers: [.command, .option])
                Divider()
                Button("Distraction-Free Reading") {
                    NotificationCenter.default.post(name: .md22ToggleDistractionFree, object: nil)
                }
                .keyboardShortcut("d", modifiers: [.command, .control])
            }
        }
    }
}
