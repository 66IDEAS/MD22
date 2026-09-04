import SwiftUI

struct HistorySidebarView: View {
    var body: some View {
        List {
            Section("Pinned") {
                ContentUnavailableView(
                    "No Pins",
                    systemImage: "pin",
                    description: Text("Pin frequently read files to keep them close.")
                )
            }
            Section("Recent") {
                ContentUnavailableView(
                    "No History",
                    systemImage: "clock",
                    description: Text("Opened Markdown files appear here.")
                )
            }
        }
        .navigationTitle("History")
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 190, ideal: 238, max: 310)
        .accessibilityLabel("Document history")
    }
}

