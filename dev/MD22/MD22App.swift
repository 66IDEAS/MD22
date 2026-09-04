import SwiftUI

@main
struct MD22App: App {
    @State private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            ContentView()
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
