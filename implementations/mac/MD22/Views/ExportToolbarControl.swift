import SwiftUI

struct ExportToolbarControl: View {
    let theme: DisplayTheme
    let isExporting: Bool
    let errorMessage: String?
    let onExport: (ExportFormat, DisplayTheme) -> Void
    let onSelectTheme: (DisplayTheme) -> Void
    let onRetry: () -> Void
    let onDismissError: () -> Void

    var body: some View {
        Menu {
            Button("Export as HTML") {
                onExport(.html, theme)
            }
            Button("Export as PDF") {
                onExport(.pdf, theme)
            }
            Divider()
            Menu("Theme") {
                ForEach(DisplayTheme.allCases) { candidate in
                    Button {
                        onSelectTheme(candidate)
                    } label: {
                        selectionLabel(candidate.title, selected: candidate == theme)
                    }
                }
            }
        } label: {
            Label(isExporting ? "Exporting…" : "Export", systemImage: "square.and.arrow.up")
                .labelStyle(.iconOnly)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .disabled(isExporting)
        .help("Export as HTML or PDF · \(theme.title) theme (Command-E repeats the last export)")
        .accessibilityIdentifier("export.menu")
        .popover(isPresented: errorPresented, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Export Failed", systemImage: "exclamationmark.triangle")
                    .font(.headline)
                Text(errorMessage ?? "The document could not be exported.")
                    .foregroundStyle(.secondary)
                HStack {
                    Button("Dismiss", role: .cancel, action: onDismissError)
                    Spacer()
                    Button("Retry", action: onRetry)
                        .keyboardShortcut(.defaultAction)
                }
            }
            .padding(16)
            .frame(width: 310)
        }
    }

    @ViewBuilder
    private func selectionLabel(_ title: String, selected: Bool) -> some View {
        if selected {
            Label(title, systemImage: "checkmark")
                .labelStyle(.titleAndIcon)
        } else {
            Text(title)
        }
    }

    private var errorPresented: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { onDismissError() } }
        )
    }
}
