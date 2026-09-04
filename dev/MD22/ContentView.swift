import SwiftUI

struct ContentView: View {
    @Environment(AppEnvironment.self) private var environment
    let initialRequest: DocumentWindowRequest?

    init(initialRequest: DocumentWindowRequest? = nil) {
        self.initialRequest = initialRequest
    }

    var body: some View {
        DocumentWindowView(environment: environment, initialRequest: initialRequest)
    }
}

#Preview {
    ContentView()
        .environment(AppEnvironment(persistence: try! PersistenceController(isStoredInMemoryOnly: true)))
}
