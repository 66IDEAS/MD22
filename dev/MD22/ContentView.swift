import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            BrandLogo()
                .frame(width: 190, height: 60)
            Text("A focused Markdown reader")
                .foregroundStyle(.secondary)
        }
        .liquidGlassCard()
        .frame(minWidth: 760, minHeight: 520)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("MD22 welcome")
    }
}

#Preview {
    ContentView()
}
