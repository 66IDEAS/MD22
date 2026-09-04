import SwiftUI

struct DocumentInspectorView: View {
    let session: DocumentSession
    let renderer: WebDocumentRenderer
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

            if selection == .outline {
                outlineContent
            } else {
                ContentUnavailableView(
                    "No Bookmarks",
                    systemImage: "bookmark",
                    description: Text("Bookmarks appear here.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .inspectorColumnWidth(min: 200, ideal: 246, max: 320)
        .accessibilityLabel("Document inspector")
    }

    @ViewBuilder
    private var outlineContent: some View {
        let nodes = OutlineNode.makeTree(from: session.analysis?.headings ?? [])
        if nodes.isEmpty {
            ContentUnavailableView(
                "No Outline",
                systemImage: "list.bullet.indent",
                description: Text("Open a document with headings to see its outline.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                OutlineGroup(nodes, children: \.children) { node in
                    Button {
                        Task { await renderer.navigate(to: node.id) }
                    } label: {
                        Text(node.title)
                            .lineLimit(2)
                            .foregroundStyle(session.readingLocation.headingID == node.id ? Color.accentColor : Color.primary)
                            .fontWeight(session.readingLocation.headingID == node.id ? .semibold : .regular)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Go to \(node.title), heading level \(node.level)")
                }
            }
            .listStyle(.sidebar)
            .accessibilityLabel("Document outline")
        }
    }
}

private struct OutlineNode: Identifiable {
    let id: String
    let level: Int
    let title: String
    let children: [OutlineNode]?

    static func makeTree(from headings: [Heading]) -> [OutlineNode] {
        parse(headings, from: 0, parentLevel: 0).nodes
    }

    private static func parse(
        _ headings: [Heading],
        from start: Int,
        parentLevel: Int
    ) -> (nodes: [OutlineNode], next: Int) {
        var nodes: [OutlineNode] = []
        var index = start
        while index < headings.count {
            let heading = headings[index]
            if heading.level <= parentLevel { break }
            index += 1
            let nested = parse(headings, from: index, parentLevel: heading.level)
            index = nested.next
            nodes.append(OutlineNode(
                id: heading.id,
                level: heading.level,
                title: heading.title,
                children: nested.nodes.isEmpty ? nil : nested.nodes
            ))
        }
        return (nodes, index)
    }
}

private enum InspectorSection: String, CaseIterable, Identifiable {
    case outline
    case bookmarks

    var id: String { rawValue }
    var title: LocalizedStringKey { self == .outline ? "Outline" : "Bookmarks" }
}
