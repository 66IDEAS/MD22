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
    }
}
