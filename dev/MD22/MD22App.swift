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
        .defaultLaunchBehavior(.presented)
        .commands {
            DocumentCommands()
            AboutCommands()
            UpdateCommands(updateService: environment.updateService)
        }

        WindowGroup("Markdown Document", for: DocumentWindowRequest.self) { request in
            ContentView(initialRequest: request.wrappedValue)
                .environment(environment)
        }
        .defaultSize(width: 1_240, height: 800)

        Settings {
            GeneralSettingsView(environment: environment)
                .preferredColorScheme(environment.preferences.appAppearance.colorScheme)
        }

        Window("About MD22", id: "about") {
            AboutView()
                .preferredColorScheme(environment.preferences.appAppearance.colorScheme)
        }
        .windowResizability(.contentSize)
    }
}
