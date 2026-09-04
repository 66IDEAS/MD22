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
            DocumentCommands()
            UpdateCommands(updateService: environment.updateService)
        }
    }
}
