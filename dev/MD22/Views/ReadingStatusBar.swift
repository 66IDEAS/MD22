import SwiftUI

struct ReadingStatusBar: View {
    let session: DocumentSession
    @Environment(AppEnvironment.self) private var environment
    @State private var readingPopoverPresented = false

    var body: some View {
        HStack(spacing: 14) {
            if let destination = session.hoveredLinkDestination {
                Label(destination, systemImage: "link")
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .help(destination)
            } else {
                Text(session.currentSection ?? session.title ?? "Ready")
                    .lineLimit(1)
            }
            Spacer(minLength: 12)
            if let analysis = session.analysis {
                Text("\(session.progressPercentage)%")
                    .monospacedDigit()
                    .accessibilityLabel("Reading progress \(session.progressPercentage) percent")
                Divider().frame(height: 12)
                Text("\(analysis.wordCount.formatted()) words")
                    .foregroundStyle(.secondary)
                Divider().frame(height: 12)
                Text("\(analysis.estimatedReadingMinutes) min read")
                    .foregroundStyle(.secondary)
            } else {
                Text("No document")
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 12)
            Menu {
                Picker("Document Theme", selection: displayThemeBinding) {
                    ForEach(DisplayTheme.allCases) { theme in
                        Text(theme.title).tag(theme)
                    }
                }
            } label: {
                Label(environment.preferences.displayTheme.title, systemImage: "paintpalette")
            }
            .menuStyle(.borderlessButton)
            .help("Choose Document Theme")
            Button("Reading Appearance", systemImage: "textformat.size") {
                readingPopoverPresented.toggle()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .help("Reading Appearance")
            .popover(isPresented: $readingPopoverPresented, arrowEdge: .bottom) {
                ReadingAppearancePopover(preferences: environment.preferences)
            }
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .frame(height: 28)
        .background(.bar)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Reading status")
    }

    private var displayThemeBinding: Binding<DisplayTheme> {
        Binding(
            get: { environment.preferences.displayTheme },
            set: { environment.preferences.displayTheme = $0 }
        )
    }
}
