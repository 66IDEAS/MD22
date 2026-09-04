import SwiftUI

struct WelcomeView: View {
    @Environment(AppEnvironment.self) private var environment
    var isDropTargeted = false

    var body: some View {
        VStack(spacing: 14) {
            BrandLogo()
                .frame(width: 190, height: 60)
            Text("A focused Markdown reader")
                .foregroundStyle(.secondary)
            Label("Drop a Markdown file here", systemImage: "arrow.down.doc")
                .font(.headline)
                .padding(.top, 8)
            Button("Open Markdown…", systemImage: "folder") {
                NotificationCenter.default.post(name: .md22OpenDocument, object: nil)
            }
            .buttonStyle(.glassProminent)
            .keyboardShortcut("o", modifiers: .command)
            Text("Files stay in place and are never imported.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .liquidGlassCard()
        .scaleEffect(isDropTargeted ? 1.025 : 1)
        .animation(environment.accessibility.reduceMotion ? nil : .snappy, value: isDropTargeted)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("MD22 welcome")
        .accessibilityIdentifier("welcome.view")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background.secondary)
    }
}
