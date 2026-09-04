import SwiftUI

struct ReadingStatusBar: View {
    let session: DocumentSession
    @Environment(AppEnvironment.self) private var environment
    @State private var readingPopoverPresented = false

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: geometry.size.width * session.readingLocation.progress)
                    .animation(environment.accessibility.reduceMotion ? nil : .smooth(duration: 0.18), value: session.readingLocation.progress)
            }
            .frame(height: 2)
            .background(Color.secondary.opacity(0.14))
            .accessibilityHidden(true)

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
                if session.isExporting {
                    HStack(spacing: 6) {
                        ProgressView().controlSize(.mini)
                        Text("Exporting…")
                    }
                    .foregroundStyle(.secondary)
                } else if let message = session.transientMessage {
                    HStack(spacing: 8) {
                        Text(message)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        if let url = session.transientActionURL {
                            Button("Reveal in Finder") {
                                environment.platform.revealInFinder(url)
                            }
                            .buttonStyle(.link)
                        }
                    }
                    .transition(.opacity)
                } else {
                    ViewThatFits(in: .horizontal) {
                        fullMetrics
                        compactMetrics
                    }
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
            .padding(.horizontal, 12)
            .frame(height: 28)
        }
        .font(.caption)
        .background(.bar)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Reading status, \(session.progressPercentage) percent")
        .accessibilityValue(accessibilitySummary)
    }

    @ViewBuilder
    private var fullMetrics: some View {
        if let analysis = session.analysis {
            HStack(spacing: 10) {
                progressLabel
                Divider().frame(height: 12)
                Text("\(analysis.wordCount.formatted()) words").foregroundStyle(.secondary)
                Divider().frame(height: 12)
                Text("\(analysis.estimatedReadingMinutes) min read").foregroundStyle(.secondary)
            }
        } else {
            Text("No document").foregroundStyle(.secondary)
        }
    }

    private var compactMetrics: some View {
        progressLabel
    }

    private var progressLabel: some View {
        Text("\(session.progressPercentage)%")
            .monospacedDigit()
            .accessibilityLabel("Reading progress \(session.progressPercentage) percent")
    }

    private var displayThemeBinding: Binding<DisplayTheme> {
        Binding(
            get: { environment.preferences.displayTheme },
            set: { environment.preferences.displayTheme = $0 }
        )
    }

    private var accessibilitySummary: String {
        guard let analysis = session.analysis else { return "No document" }
        let section = session.currentSection.map { ", current section \($0)" } ?? ""
        return "\(analysis.wordCount) words, \(analysis.estimatedReadingMinutes) minute read\(section)"
    }
}
