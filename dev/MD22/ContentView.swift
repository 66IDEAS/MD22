import SwiftUI

struct ContentView: View {
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        DocumentWindowView(environment: environment)
        .onOpenURL { url in
            try? environment.router.route(url, source: .finder)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppEnvironment(persistence: try! PersistenceController(isStoredInMemoryOnly: true)))
}
