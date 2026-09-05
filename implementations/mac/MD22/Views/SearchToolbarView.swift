import AppKit
import SwiftUI

struct SearchToolbarView: View {
    @Binding var query: String
    let state: DocumentSearchState
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 5) {
            AutoFocusedSearchField(text: $query)
                .frame(width: 150)
                .accessibilityLabel("Find in document")

            if query.isEmpty {
                Text("Find")
                    .foregroundStyle(.secondary)
            } else if state.matchCount == 0 {
                Text("No matches")
                    .foregroundStyle(.secondary)
            } else {
                Text("\(state.activeIndex + 1) of \(state.matchCount)")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Match \(state.activeIndex + 1) of \(state.matchCount)")
            }

            if !state.section.isEmpty {
                Text(state.section)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .frame(maxWidth: 86)
                    .transition(.opacity)
            }

            Button("Previous Match", systemImage: "chevron.up", action: onPrevious)
                .labelStyle(.iconOnly)
                .disabled(state.matchCount == 0)
                .keyboardShortcut(.return, modifiers: [.shift])
            Button("Next Match", systemImage: "chevron.down", action: onNext)
                .labelStyle(.iconOnly)
                .disabled(state.matchCount == 0)
                .keyboardShortcut(.return, modifiers: [])
            Button("Close Search", systemImage: "xmark", action: onClose)
                .labelStyle(.iconOnly)
                .keyboardShortcut(.escape, modifiers: [])
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .glassEffect(.regular, in: .capsule)
        .onExitCommand(perform: onClose)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Document search")
    }
}

private struct AutoFocusedSearchField: NSViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeNSView(context: Context) -> InitialFocusTextField {
        let field = InitialFocusTextField()
        field.delegate = context.coordinator
        field.isBordered = false
        field.isBezeled = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.controlSize = .small
        field.font = .systemFont(ofSize: NSFont.systemFontSize(for: .small))
        field.lineBreakMode = .byClipping
        field.setAccessibilityLabel("Find in document")
        return field
    }

    func updateNSView(_ field: InitialFocusTextField, context: Context) {
        if field.stringValue != text {
            field.stringValue = text
        }
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        private var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func controlTextDidChange(_ notification: Notification) {
            guard let field = notification.object as? NSTextField else { return }
            text.wrappedValue = field.stringValue
        }
    }
}

private final class InitialFocusTextField: NSTextField {
    private var hasRequestedInitialFocus = false

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard window != nil, !hasRequestedInitialFocus else { return }
        hasRequestedInitialFocus = true
        DispatchQueue.main.async { [weak self] in
            guard let self, let window = self.window else { return }
            window.makeFirstResponder(self)
        }
    }
}
