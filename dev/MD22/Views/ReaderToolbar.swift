import SwiftUI

struct ReaderToolbar: ToolbarContent {
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @Binding var inspectorPresented: Bool
    @Binding var searchPresented: Bool
    var documentTitle: String?
    var canNavigateBack = false
    var canNavigateForward = false
    var canExport = false

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            Button("Toggle History", systemImage: "sidebar.left") {
                columnVisibility = columnVisibility == .detailOnly ? .all : .detailOnly
            }
            .labelStyle(.iconOnly)
            .help("Show or hide History")

            Button("Back", systemImage: "chevron.left") {
                NotificationCenter.default.post(name: .md22NavigateBack, object: nil)
            }
            .labelStyle(.iconOnly)
            .disabled(!canNavigateBack)
            .help("Go Back")

            Button("Forward", systemImage: "chevron.right") {
                NotificationCenter.default.post(name: .md22NavigateForward, object: nil)
            }
            .labelStyle(.iconOnly)
            .disabled(!canNavigateForward)
            .help("Go Forward")
        }

        ToolbarItem(placement: .principal) {
            Text(documentTitle ?? "MD22")
                .font(.headline)
                .lineLimit(1)
                .accessibilityLabel(documentTitle.map { "Current document: \($0)" } ?? "MD22")
        }

        ToolbarItemGroup(placement: .automatic) {
            Button("Open", systemImage: "folder") {
                NotificationCenter.default.post(name: .md22OpenDocument, object: nil)
            }
            .keyboardShortcut("o", modifiers: .command)
            .help("Open Markdown…")

            Button("Export", systemImage: "square.and.arrow.up") {
                NotificationCenter.default.post(name: .md22ExportDocument, object: nil)
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
            .disabled(!canExport)
            .help("Export Document")
        }

        ToolbarItemGroup(placement: .primaryAction) {
            Button("Search", systemImage: "magnifyingglass") {
                searchPresented.toggle()
                NotificationCenter.default.post(name: .md22ToggleSearch, object: nil)
            }
            .labelStyle(.iconOnly)
            .keyboardShortcut("f", modifiers: .command)
            .help("Find in Document")

            Button("Toggle Inspector", systemImage: "sidebar.right") {
                inspectorPresented.toggle()
            }
            .labelStyle(.iconOnly)
            .help("Show or hide Outline and Bookmarks")
        }
    }
}

