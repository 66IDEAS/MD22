import SwiftUI

struct ExportToolbarControl: View {
    let format: ExportFormat
    let theme: DisplayTheme
    let isExporting: Bool
    let errorMessage: String?
    let onExport: (ExportFormat, DisplayTheme) -> Void
    let onRetry: () -> Void
    let onDismissError: () -> Void

    var body: some View {
        ControlGroup {
            Button {
                onExport(format, theme)
            } label: {
                if isExporting {
                    ProgressView()
                        .controlSize(.mini)
                        .accessibilityLabel("Exporting…")
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .imageScale(.medium)
                        .accessibilityLabel("Export as \(format.title)")
                }
            }
            .accessibilityIdentifier("export.primary")

            Menu {
                Text("Current: \(format.title) · \(theme.title)")
                Divider()
                Section("Format") {
                    ForEach(ExportFormat.allCases) { candidate in
                        Button {
                            onExport(candidate, theme)
                        } label: {
                            selectionLabel(candidate.title, selected: candidate == format)
                        }
                    }
                }
                Section("Theme") {
                    ForEach(DisplayTheme.allCases) { candidate in
                        Button {
                            onExport(format, candidate)
                        } label: {
                            selectionLabel(candidate.title, selected: candidate == theme)
                        }
                    }
                }
            } label: {
                Label("Export Options", systemImage: "chevron.down")
            }
            .menuIndicator(.hidden)
        }
        .controlGroupStyle(.compactMenu)
        .disabled(isExporting)
        .help("Export \(format.title) using the \(theme.title) theme (Command-E)")
        .accessibilityElement(children: .contain)
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
