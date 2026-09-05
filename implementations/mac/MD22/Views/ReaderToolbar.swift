import SwiftUI

struct ReaderToolbar: ToolbarContent {
    @Binding var inspectorPresented: Bool
    @Binding var searchPresented: Bool
    @Binding var searchQuery: String
    var isDistractionFree = false
    var onToggleInspector: () -> Void = {}
    var onToggleDistractionFree: () -> Void = {}
    var onOpen: () -> Void = {}
    var onNavigateBack: () -> Void = {}
    var onNavigateForward: () -> Void = {}
    var onSearch: () -> Void = {}
    var searchState = DocumentSearchState()
    var onPreviousSearchResult: () -> Void = {}
    var onNextSearchResult: () -> Void = {}
    var onCloseSearch: () -> Void = {}
    var documentTitle: String?
    var canNavigateBack = false
    var canNavigateForward = false
    var canExport = false
    var exportFormat = ExportFormat.pdf
    var exportTheme = DisplayTheme.light
    var isExporting = false
    var exportError: String?
    var onExport: (ExportFormat, DisplayTheme) -> Void = { _, _ in }
    var onRetryExport: () -> Void = {}
    var onDismissExportError: () -> Void = {}

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            Button("Back", systemImage: "chevron.left") {
                onNavigateBack()
            }
            .labelStyle(.iconOnly)
            .disabled(!canNavigateBack)
            .help("Go Back (Command-[)")

            Button("Forward", systemImage: "chevron.right") {
                onNavigateForward()
            }
            .labelStyle(.iconOnly)
            .disabled(!canNavigateForward)
            .help("Go Forward (Command-])")
        }
        .sharedBackgroundVisibility(.hidden)

        ToolbarItem(placement: .principal) {
            Text(documentTitle ?? "MD22")
                .font(.headline)
                .lineLimit(1)
                .accessibilityLabel(documentTitle.map { "Current document: \($0)" } ?? "MD22")
        }

        ToolbarItemGroup(placement: .automatic) {
            Button("Open", systemImage: "folder") {
                onOpen()
            }
            .keyboardShortcut("o", modifiers: .command)
            .help("Open Markdown…")

            ExportToolbarControl(
                format: exportFormat,
                theme: exportTheme,
                isExporting: isExporting,
                errorMessage: exportError,
                onExport: onExport,
                onRetry: onRetryExport,
                onDismissError: onDismissExportError
            )
            .disabled(!canExport)
        }
        .sharedBackgroundVisibility(.hidden)

        ToolbarItemGroup(placement: .primaryAction) {
            if searchPresented {
                SearchToolbarView(
                    query: $searchQuery,
                    state: searchState,
                    onPrevious: onPreviousSearchResult,
                    onNext: onNextSearchResult,
                    onClose: onCloseSearch
                )
            } else {
                Button("Search", systemImage: "magnifyingglass") {
                    onSearch()
                }
                .labelStyle(.iconOnly)
                .keyboardShortcut("f", modifiers: .command)
                .help("Find in Document (Command-F)")
            }

            Button("Toggle Inspector", systemImage: "sidebar.right") {
                onToggleInspector()
            }
            .labelStyle(.iconOnly)
            .help("Show or hide Outline and Bookmarks (Option-Command-2)")

            Button(
                isDistractionFree ? "Exit Distraction-Free Reading" : "Enter Distraction-Free Reading",
                systemImage: isDistractionFree
                    ? "arrow.down.right.and.arrow.up.left"
                    : "arrow.up.left.and.arrow.down.right"
            ) {
                onToggleDistractionFree()
            }
            .labelStyle(.iconOnly)
            .help(isDistractionFree ? "Exit Distraction-Free Reading (Control-Command-D)" : "Enter Distraction-Free Reading (Control-Command-D)")
            .accessibilityIdentifier("distraction.toggle")
        }
        .sharedBackgroundVisibility(.hidden)
    }
}
