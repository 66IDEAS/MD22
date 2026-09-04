import SwiftUI

struct ReadOnlyDocumentView: View {
    let snapshot: DocumentSnapshot

    var body: some View {
        ScrollView {
            Text(snapshot.markdown)
                .font(.system(.body, design: .serif))
                .textSelection(.enabled)
                .frame(maxWidth: 760, alignment: .leading)
                .padding(.horizontal, 48)
                .padding(.vertical, 42)
                .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(.background)
        .accessibilityLabel("Read-only Markdown document")
    }
}
