import AppKit
import SwiftUI

struct AboutView: View {
    private enum Page: String, CaseIterable, Identifiable {
        case about = "About"
        case license = "License"
        case acknowledgements = "Acknowledgements"

        var id: String { rawValue }
    }

    @State private var page = Page.about

    var body: some View {
        VStack(spacing: 18) {
            BrandLogo()
                .frame(width: 136, height: 48)

            VStack(spacing: 4) {
                Text("MD22")
                    .font(.title2.bold())
                Text(versionDescription)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("about.version")
                Text("A focused, read-only Markdown reader for macOS.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Picker("Information", selection: $page) {
                ForEach(Page.allCases) { page in
                    Text(page.rawValue).tag(page)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)

            Group {
                switch page {
                case .about:
                    aboutPage
                case .license:
                    LegalTextView(resource: "LICENSE", fallback: "MD22 is released under the MIT License.")
                case .acknowledgements:
                    LegalTextView(
                        resource: "THIRD_PARTY_LICENSES",
                        fallback: "Third-party notices are unavailable in this build."
                    )
                }
            }
            .frame(height: 230)
        }
        .padding(28)
        .frame(width: 560)
    }

    private var aboutPage: some View {
        VStack(spacing: 14) {
            Spacer()
            Link(destination: URL(string: "https://github.com/alexanderilg/MD22")!) {
                Label("MD22 on GitHub", systemImage: "link")
            }
            .accessibilityIdentifier("about.github")
            Text("Copyright © 2026 Alexander Ilg")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Markdown stays on this Mac. MD22 includes no accounts, analytics, or telemetry.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var versionDescription: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }
}

private struct LegalTextView: View {
    let resource: String
    let fallback: String

    var body: some View {
        ScrollView {
            Text(text)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
        }
        .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 10))
        .accessibilityLabel(resource == "LICENSE" ? "MIT License" : "Third-party acknowledgements")
    }

    private var text: String {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "txt"),
              let value = try? String(contentsOf: url, encoding: .utf8) else {
            return fallback
        }
        return value
    }
}
