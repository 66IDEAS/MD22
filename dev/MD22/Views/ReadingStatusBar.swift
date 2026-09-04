import SwiftUI

struct ReadingStatusBar: View {
    let session: DocumentSession
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        HStack(spacing: 14) {
            if let destination = session.hoveredLinkDestination {
                Label(destination, systemImage: "link")
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .help(destination)
            } else {
                Label("Ready", systemImage: "checkmark.circle")
            }
            Spacer(minLength: 12)
            Text(session.snapshot?.url.lastPathComponent ?? "No document")
                .foregroundStyle(.secondary)
            Divider().frame(height: 12)
            Menu {
                Picker("Document Theme", selection: displayThemeBinding) {
                    ForEach(DisplayTheme.allCases) { theme in
                        Text(theme.title).tag(theme)
                    }
                }
            } label: {
                Label(environment.preferences.displayTheme.title, systemImage: "paintpalette")
            }
            .menuStyle(.borderlessButton)
            .help("Choose Document Theme")
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .frame(height: 28)
        .background(.bar)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Reading status")
    }

    private var displayThemeBinding: Binding<DisplayTheme> {
        Binding(
            get: { environment.preferences.displayTheme },
            set: { environment.preferences.displayTheme = $0 }
        )
    }
}
