import SwiftUI

struct ContentView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var inspectorPresented = true
    @State private var searchPresented = false

    var body: some View {
        VStack(spacing: 0) {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                HistorySidebarView()
            } detail: {
                WelcomeView()
            }
            .inspector(isPresented: $inspectorPresented) {
                DocumentInspectorView()
            }

            Divider()
            ReadingStatusBar()
        }
        .frame(minWidth: 760, minHeight: 520)
        .preferredColorScheme(environment.preferences.appAppearance.colorScheme)
        .toolbar {
            ReaderToolbar(
                columnVisibility: $columnVisibility,
                inspectorPresented: $inspectorPresented,
                searchPresented: $searchPresented,
                documentTitle: nil
            )
        }
    }
}

#Preview {
    ContentView()
}
