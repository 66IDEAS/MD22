import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 48, weight: .light))
                .accessibilityHidden(true)
            Text("MD22")
                .font(.largeTitle)
            Text("A focused Markdown reader")
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 760, minHeight: 520)
    }
}

#Preview {
    ContentView()
}

