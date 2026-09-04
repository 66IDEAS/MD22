import SwiftUI

struct SearchToolbarView: View {
    @Binding var query: String
    let state: DocumentSearchState
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onClose: () -> Void
    @FocusState private var fieldFocused: Bool

    var body: some View {
        HStack(spacing: 5) {
            TextField("Find", text: $query)
                .textFieldStyle(.plain)
                .frame(width: 150)
                .focused($fieldFocused)
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
        .task { fieldFocused = true }
        .onExitCommand(perform: onClose)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Document search")
    }
}
