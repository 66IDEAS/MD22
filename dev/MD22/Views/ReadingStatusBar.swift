import SwiftUI

struct ReadingStatusBar: View {
    let session: DocumentSession

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
