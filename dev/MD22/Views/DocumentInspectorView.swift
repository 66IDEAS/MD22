import SwiftUI

struct DocumentInspectorView: View {
    let session: DocumentSession
    let renderer: WebDocumentRenderer
    var onOpenBookmark: (BookmarkRecord) -> Void = { _ in }
    var onOpenBookmarkInNewWindow: (BookmarkRecord) -> Void = { _ in }
    @Environment(AppEnvironment.self) private var environment
    @State private var selection = InspectorSection.outline
    @State private var bookmarkScope = BookmarkScope.currentDocument
    @State private var expandedOutlineIDs: Set<String> = []
    @State private var operationError: String?

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
                bookmarksContent
            }
        }
        .inspectorColumnWidth(min: 200, ideal: 246, max: 320)
        .accessibilityLabel("Document inspector")
        .accessibilityIdentifier("document.inspector")
        .onChange(of: session.analysis?.headings, initial: true) { _, headings in
            expandEntireOutline(headings ?? [])
        }
        .onChange(of: selection) { _, section in
            guard section == .outline else { return }
            expandEntireOutline(session.analysis?.headings ?? [])
        }
        .alert("Bookmarks Could Not Be Updated", isPresented: errorPresented) {
            Button("OK", role: .cancel) { operationError = nil }
        } message: {
            Text(operationError ?? "")
        }
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
                ForEach(nodes) { node in
                    OutlineTreeRow(
                        node: node,
                        currentHeadingID: session.readingLocation.headingID,
                        expandedIDs: $expandedOutlineIDs,
                        onNavigate: { headingID in
                            Task { await renderer.navigate(to: headingID) }
                        }
                    )
                }
            }
            .listStyle(.sidebar)
            .accessibilityLabel("Document outline")
        }
    }

    @ViewBuilder
    private var bookmarksContent: some View {
        let records = bookmarkScope == .currentDocument
            ? environment.bookmarks.records(for: session.snapshot?.url)
            : environment.bookmarks.records
        VStack(spacing: 0) {
            Picker("Bookmark Scope", selection: $bookmarkScope) {
                ForEach(BookmarkScope.allCases) { scope in
                    Text(scope.title).tag(scope)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            if records.isEmpty {
                ContentUnavailableView(
                    "No Bookmarks",
                    systemImage: "star",
                    description: Text(bookmarkScope == .currentDocument ? "Bookmark a place in this document to return later." : "Bookmarks from every document appear here.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(records) { record in
                    BookmarkRow(
                        record: record,
                        showsFilename: bookmarkScope == .allDocuments,
                        onOpen: { onOpenBookmark(record) },
                        onRemove: { perform { try environment.bookmarks.remove(record) } }
                    )
                    .contextMenu {
                        Button("Open") { onOpenBookmark(record) }
                            .disabled(!FileManager.default.isReadableFile(atPath: record.canonicalPath))
                        Button("Open in New Window") { onOpenBookmarkInNewWindow(record) }
                            .disabled(!FileManager.default.isReadableFile(atPath: record.canonicalPath))
                        Button("Show in Finder") {
                            environment.platform.revealInFinder(URL(fileURLWithPath: record.canonicalPath))
                        }
                        .disabled(!FileManager.default.isReadableFile(atPath: record.canonicalPath))
                        Divider()
                        Button("Remove Bookmark", role: .destructive) {
                            perform { try environment.bookmarks.remove(record) }
                        }
                    }
                }
                .listStyle(.sidebar)
            }
        }
    }

    private var errorPresented: Binding<Bool> {
        Binding(get: { operationError != nil }, set: { if !$0 { operationError = nil } })
    }

    private func perform(_ action: () throws -> Void) {
        do { try action() } catch { operationError = error.localizedDescription }
    }

    private func expandEntireOutline(_ headings: [Heading]) {
        expandedOutlineIDs = OutlineNode.expandableIDs(
            in: OutlineNode.makeTree(from: headings)
        )
    }
}

private struct OutlineTreeRow: View {
    let node: OutlineNode
    let currentHeadingID: String?
    @Binding var expandedIDs: Set<String>
    let onNavigate: (String) -> Void

    var body: some View {
        if let children = node.children {
            DisclosureGroup(isExpanded: isExpanded) {
                ForEach(children) { child in
                    OutlineTreeRow(
                        node: child,
                        currentHeadingID: currentHeadingID,
                        expandedIDs: $expandedIDs,
                        onNavigate: onNavigate
                    )
                }
            } label: {
                outlineButton
            }
        } else {
            outlineButton
        }
    }

    private var outlineButton: some View {
        Button {
            onNavigate(node.id)
        } label: {
            Text(node.title)
                .lineLimit(2)
                .foregroundStyle(currentHeadingID == node.id ? Color.accentColor : Color.primary)
                .fontWeight(currentHeadingID == node.id ? .semibold : .regular)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Go to \(node.title), heading level \(node.level)")
    }

    private var isExpanded: Binding<Bool> {
        Binding(
            get: { expandedIDs.contains(node.id) },
            set: { expanded in
                if expanded {
                    expandedIDs.insert(node.id)
                } else {
                    expandedIDs.remove(node.id)
                }
            }
        )
    }
}

private struct BookmarkRow: View {
    let record: BookmarkRecord
    let showsFilename: Bool
    let onOpen: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Button("Remove Bookmark", systemImage: "star.fill", action: onRemove)
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
                .help("Remove Bookmark")
                .accessibilityLabel("Remove bookmark \(record.title)")
                .accessibilityIdentifier("bookmark.remove.\(record.id.uuidString)")

            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.title).lineLimit(2)
                    if let excerpt = record.excerpt, excerpt != record.title {
                        Text(excerpt).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                    }
                    if showsFilename || !isAvailable {
                        Text(isAvailable ? record.fileDisplayName : "Unavailable — \(record.fileDisplayName)")
                            .font(.caption2)
                            .foregroundStyle(isAvailable ? Color.secondary : Color.red)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(!isAvailable)
            .accessibilityLabel(accessibilityDescription)
        }
        .accessibilityElement(children: .contain)
    }

    private var isAvailable: Bool { FileManager.default.isReadableFile(atPath: record.canonicalPath) }
    private var accessibilityDescription: String {
        let kindDescription: String
        switch record.kind {
        case .heading: kindDescription = "Heading bookmark"
        case .passage: kindDescription = "Passage bookmark"
        case .position: kindDescription = "Reading position bookmark"
        }
        let availability = isAvailable ? "available" : "unavailable"
        return "\(kindDescription), \(record.title), \(record.fileDisplayName), \(availability)"
    }
}

private enum BookmarkScope: String, CaseIterable, Identifiable {
    case currentDocument
    case allDocuments
    var id: String { rawValue }
    var title: String { self == .currentDocument ? "Current" : "All Files" }
}

private struct OutlineNode: Identifiable {
    let id: String
    let level: Int
    let title: String
    let children: [OutlineNode]?

    static func makeTree(from headings: [Heading]) -> [OutlineNode] {
        parse(headings, from: 0, parentLevel: 0).nodes
    }

    static func expandableIDs(in nodes: [OutlineNode]) -> Set<String> {
        var identifiers: Set<String> = []
        for node in nodes {
            guard let children = node.children else { continue }
            identifiers.insert(node.id)
            identifiers.formUnion(expandableIDs(in: children))
        }
        return identifiers
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
