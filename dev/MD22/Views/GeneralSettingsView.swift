import AppKit
import SwiftUI

struct GeneralSettingsView: View {
    let environment: AppEnvironment
    @State private var diagnosticStatus: String?

    var body: some View {
        @Bindable var preferences = environment.preferences

        Form {
            Section("Appearance") {
                Picker("Application appearance", selection: $preferences.appAppearance) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Text(appearance.title).tag(appearance)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityHint("Changes the application interface without changing the document theme")
            }

            Section("Updates") {
                Toggle("Automatically check for updates", isOn: automaticUpdatesBinding)

                HStack {
                    updateStatus
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Check Now") {
                        environment.updateService.checkForUpdates()
                    }
                    .disabled(!environment.updateService.canCheckForUpdates)
                }
            }

            Section("Support") {
                Text("Diagnostic packages contain only app configuration and privacy-redacted MD22 logs. Nothing is sent automatically.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    if let diagnosticStatus {
                        Text(diagnosticStatus)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Create Diagnostic Package…") {
                        createDiagnosticPackage()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, 8)
    }

    private var automaticUpdatesBinding: Binding<Bool> {
        Binding(
            get: { environment.updateService.automaticallyChecksForUpdates },
            set: { environment.updateService.automaticallyChecksForUpdates = $0 }
        )
    }

    private func createDiagnosticPackage() {
        let panel = NSOpenPanel()
        panel.title = "Choose a Location for MD22 Diagnostics"
        panel.message = "MD22 will create an inspectable package containing the four files described above."
        panel.prompt = "Create Package"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let directory = panel.url else { return }

        diagnosticStatus = "Creating…"
        Task {
            do {
                let packageURL = try await environment.diagnosticService.createPackage(in: directory)
                diagnosticStatus = "Created \(packageURL.lastPathComponent)"
                NSWorkspace.shared.activateFileViewerSelecting([packageURL])
            } catch {
                diagnosticStatus = "The diagnostic package could not be created."
            }
        }
    }

    @ViewBuilder
    private var updateStatus: some View {
        if let date = environment.updateService.lastUpdateCheckDate {
            Text("Last checked \(date, format: .relative(presentation: .named))")
        } else {
            Text("Updates are delivered securely through Sparkle.")
        }
    }
}

#Preview {
    GeneralSettingsView(
        environment: AppEnvironment(persistence: try! PersistenceController(isStoredInMemoryOnly: true))
    )
}
