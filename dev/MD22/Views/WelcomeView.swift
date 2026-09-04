import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 14) {
            BrandLogo()
                .frame(width: 190, height: 60)
            Text("A focused Markdown reader")
                .foregroundStyle(.secondary)
            Label("Drop a Markdown file here", systemImage: "arrow.down.doc")
                .font(.headline)
                .padding(.top, 8)
            Text("or choose Open from the toolbar")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .liquidGlassCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("MD22 welcome")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background.secondary)
    }
}

