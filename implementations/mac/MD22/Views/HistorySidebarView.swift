import SwiftUI

struct HistorySidebarView: View {
    let history: HistoryRepository
    @Binding var selection: String?
    var onOpen: (HistoryRecord) -> Void = { _ in }
    var onOpenInNewWindow: (HistoryRecord) -> Void = { _ in }
    var onReveal: (HistoryRecord) -> Void = { _ in }

    @State private var operationError: String?

    var body: some View {
        List(selection: $selection) {
            if !history.pinnedRecords.isEmpty {
                Section("Pinned") {
                    ForEach(history.pinnedRecords) { record in
                        historyRow(record)
                    }
                    .onMove(perform: movePins)
                }
            }

            Section("Recent") {
                if history.recentRecords.isEmpty {
                    ContentUnavailableView(
                        "No History",
                        systemImage: "clock",
                        description: Text("Opened Markdown files appear here.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(history.recentRecords) { record in
                        historyRow(record)
                    }
                    .onDelete(perform: removeRecent)
                }
            }
        }
        .navigationTitle("History")
        .listStyle(.sidebar)
        .accessibilityLabel("Document history")
        .accessibilityIdentifier("history.sidebar")
        .safeAreaInset(edge: .bottom) {
            historyFooter
        }
        .alert("History Could Not Be Updated", isPresented: errorPresented) {
            Button("OK", role: .cancel) { operationError = nil }
        } message: {
            Text(operationError ?? "")
        }
    }

    private func historyRow(_ record: HistoryRecord) -> some View {
        HistoryRow(record: record) {
            perform { try history.setPinned(!record.isPinned, for: record) }
        }
            .tag(record.canonicalPath)
            .contextMenu {
                Button("Open") { onOpen(record) }
                    .disabled(!record.isAvailable)
                Button("Open in New Window") { onOpenInNewWindow(record) }
                    .disabled(!record.isAvailable)
                Button(record.isPinned ? "Unpin" : "Pin") {
                    perform { try history.setPinned(!record.isPinned, for: record) }
                }
                Button("Show in Finder") { onReveal(record) }
                    .disabled(!record.isAvailable)
                Divider()
                Button("Remove from History", role: .destructive) {
                    perform { try history.remove(record) }
                }
            }
            .accessibilityAction(named: "Open") { onOpen(record) }
    }

    private var historyFooter: some View {
        HStack {
            Spacer()
            Menu {
                Button("Clear Recent History", role: .destructive) {
                    perform { try history.clearUnpinnedHistory() }
                }
                .disabled(history.recentRecords.isEmpty)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .accessibilityLabel("History actions")
            }
            .menuStyle(.borderlessButton)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(.bar)
    }

    private var errorPresented: Binding<Bool> {
        Binding(
            get: { operationError != nil },
            set: { if !$0 { operationError = nil } }
        )
    }

    private func removeRecent(at offsets: IndexSet) {
        let records = offsets.compactMap { index in
            history.recentRecords.indices.contains(index) ? history.recentRecords[index] : nil
        }
        perform {
            for record in records { try history.remove(record) }
        }
    }

    private func movePins(from offsets: IndexSet, to destination: Int) {
        perform { try history.reorderPinned(fromOffsets: offsets, toOffset: destination) }
    }

    private func perform(_ operation: () throws -> Void) {
        do {
            try operation()
        } catch {
            operationError = error.localizedDescription
        }
    }
}

private struct HistoryRow: View {
    let record: HistoryRecord
    let onTogglePin: () -> Void
    @State private var isHovering = false
    @FocusState private var pinFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: record.isAvailable ? "doc.text" : "doc.badge.ellipsis")
                .foregroundStyle(record.isAvailable ? Color.secondary : Color.red)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 1) {
                Text(record.displayName)
                    .font(.body)
                    .lineLimit(1)
                Text(record.isAvailable ? abbreviatedParentPath : "Unavailable — \(abbreviatedParentPath)")
                    .font(.caption)
                    .foregroundStyle(record.isAvailable ? Color.secondary : Color.red)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer(minLength: 0)
            Button(action: onTogglePin) {
                Image(systemName: record.isPinned ? "pin.fill" : "pin")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .focused($pinFocused)
            .foregroundStyle(record.isPinned ? Color.accentColor : Color.secondary)
            .opacity(record.isPinned || isHovering || pinFocused ? 1 : 0)
            .help(record.isPinned ? "Unpin" : "Pin")
            .accessibilityLabel(record.isPinned ? "Unpin \(record.displayName)" : "Pin \(record.displayName)")
        }
        .onHover { isHovering = $0 }
        .help(record.canonicalPath)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityValue(record.isPinned ? "Pinned" : "Not pinned")
    }

    private var abbreviatedParentPath: String {
        NSString(string: record.parentPath).abbreviatingWithTildeInPath
    }

    private var accessibilityDescription: String {
        if record.isAvailable {
            return "\(record.displayName), in \(abbreviatedParentPath)"
        }
        return "\(record.displayName), unavailable, formerly in \(abbreviatedParentPath)"
    }
}
