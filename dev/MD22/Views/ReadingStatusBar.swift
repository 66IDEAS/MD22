import SwiftUI

struct ReadingStatusBar: View {
    var body: some View {
        HStack(spacing: 14) {
            Label("Ready", systemImage: "checkmark.circle")
            Spacer(minLength: 12)
            Text("No document")
                .foregroundStyle(.secondary)
            Divider().frame(height: 12)
            Button("Light", systemImage: "circle.lefthalf.filled") {}
                .buttonStyle(.borderless)
                .disabled(true)
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .frame(height: 28)
        .background(.bar)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Reading status")
    }
}

