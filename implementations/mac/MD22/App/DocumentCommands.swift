import SwiftUI

struct FocusedDocumentActions {
    let canNavigateBack: Bool
    let canNavigateForward: Bool
    let canExport: Bool
    let open: () -> Void
    let export: () -> Void
    let addBookmark: () -> Void
    let navigateBack: () -> Void
    let navigateForward: () -> Void
    let find: () -> Void
    let toggleHistory: () -> Void
    let toggleInspector: () -> Void
    let toggleDistractionFree: () -> Void
    let focusHistory: () -> Void
    let focusDocument: () -> Void
    let focusInspector: () -> Void
    let focusStatusBar: () -> Void
}

private struct FocusedDocumentActionsKey: FocusedValueKey {
    typealias Value = FocusedDocumentActions
}

extension FocusedValues {
    var md22DocumentActions: FocusedDocumentActions? {
        get { self[FocusedDocumentActionsKey.self] }
        set { self[FocusedDocumentActionsKey.self] = newValue }
    }
}

struct DocumentCommands: Commands {
    @FocusedValue(\.md22DocumentActions) private var actions
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Window") {
                openWindow(id: "reader")
            }
            .keyboardShortcut("n", modifiers: .command)

            Button("Open Markdown…") { actions?.open() }
                .keyboardShortcut("o", modifiers: .command)
                .disabled(actions == nil)

            Divider()

            Button("Export Document") { actions?.export() }
                .keyboardShortcut("e", modifiers: .command)
                .disabled(actions?.canExport != true)
            Button("Add Bookmark") { actions?.addBookmark() }
                .keyboardShortcut("d", modifiers: .command)
                .disabled(actions?.canExport != true)
        }
        CommandGroup(replacing: .saveItem) { }
        CommandMenu("Navigate") {
            Button("Back") { actions?.navigateBack() }
                .keyboardShortcut(.leftArrow, modifiers: .command)
                .disabled(actions?.canNavigateBack != true)
            Button("Forward") { actions?.navigateForward() }
                .keyboardShortcut(.rightArrow, modifiers: .command)
                .disabled(actions?.canNavigateForward != true)
            Divider()
            Button("Find in Document") { actions?.find() }
                .keyboardShortcut("f", modifiers: .command)
                .disabled(actions?.canExport != true)
            Divider()
            Button("Focus History") { actions?.focusHistory() }
                .keyboardShortcut("1", modifiers: .control)
            Button("Focus Document") { actions?.focusDocument() }
                .keyboardShortcut("2", modifiers: .control)
            Button("Focus Inspector") { actions?.focusInspector() }
                .keyboardShortcut("3", modifiers: .control)
            Button("Focus Status Bar") { actions?.focusStatusBar() }
                .keyboardShortcut("4", modifiers: .control)
        }
        CommandMenu("Reading") {
            Button("Toggle History") { actions?.toggleHistory() }
                .keyboardShortcut("1", modifiers: [.command, .option])
            Button("Toggle Inspector") { actions?.toggleInspector() }
                .keyboardShortcut("2", modifiers: [.command, .option])
            Divider()
            Button("Distraction-Free Reading") { actions?.toggleDistractionFree() }
                .keyboardShortcut("d", modifiers: [.command, .control])
        }
    }
}

struct UpdateCommands: Commands {
    let updateService: UpdateService

    var body: some Commands {
        CommandGroup(after: .appInfo) {
            Button("Check for Updates…") {
                updateService.checkForUpdates()
            }
            .disabled(!updateService.canCheckForUpdates)
        }
    }
}

struct AboutCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About MD22") {
                openWindow(id: "about")
            }
        }
    }
}
