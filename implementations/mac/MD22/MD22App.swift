import SwiftUI

@main
struct MD22App: App {
    @State private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup(id: "reader") {
            ContentView()
                .environment(environment)
                .handlesExternalEvents(preferring: ["*"], allowing: ["*"])
        }
        .defaultSize(width: 1_240, height: 800)
        .defaultLaunchBehavior(.presented)
        .handlesExternalEvents(matching: ["*"])
        .commands {
            DocumentCommands()
            AboutCommands()
            UpdateCommands(updateService: environment.updateService)
        }

        WindowGroup("Markdown Document", for: DocumentWindowRequest.self) { request in
            ContentView(initialRequest: request.wrappedValue)
                .environment(environment)
                .handlesExternalEvents(preferring: [], allowing: [])
        }
        .defaultSize(width: 1_240, height: 800)
        .handlesExternalEvents(matching: [])

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
