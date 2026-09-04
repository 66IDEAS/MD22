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
        }
    }
}
