import SwiftUI

struct DocumentInspectorView: View {
    @State private var selection = InspectorSection.outline

    var body: some View {
        VStack(spacing: 0) {
            Picker("Inspector", selection: $selection) {
                ForEach(InspectorSection.allCases) { section in
                    Text(section.title).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(12)

            Divider()

            ContentUnavailableView(
                selection == .outline ? "No Outline" : "No Bookmarks",
                systemImage: selection == .outline ? "list.bullet.indent" : "bookmark",
                description: Text(selection == .outline ? "Open a document to see its headings." : "Bookmarks appear here.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .inspectorColumnWidth(min: 200, ideal: 246, max: 320)
        .accessibilityLabel("Document inspector")
    }
}

private enum InspectorSection: String, CaseIterable, Identifiable {
    case outline
    case bookmarks

    var id: String { rawValue }
    var title: LocalizedStringKey { self == .outline ? "Outline" : "Bookmarks" }
}

