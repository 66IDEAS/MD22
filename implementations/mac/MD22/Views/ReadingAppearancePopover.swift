import SwiftUI

struct ReadingAppearancePopover: View {
    let preferences: PreferencesStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reading Appearance")
                .font(.headline)

            HStack {
                Text("Text Size")
                Spacer()
                Button("Smaller Text", systemImage: "textformat.size.smaller") {
                    update { $0.fontScale -= 0.05 }
                }
                .labelStyle(.iconOnly)
                Text("\(Int(preferences.readingSettings.fontScale * 100))%")
                    .monospacedDigit()
                    .frame(width: 44)
                Button("Larger Text", systemImage: "textformat.size.larger") {
                    update { $0.fontScale += 0.05 }
                }
                .labelStyle(.iconOnly)
            }

            LabeledContent("Line Spacing") {
                Slider(value: lineSpacing, in: 1.25...2.2)
                    .frame(width: 150)
                    .accessibilityValue(String(format: "%.2f", preferences.readingSettings.lineSpacing))
            }

            LabeledContent("Content Width") {
                Slider(value: contentWidth, in: 520...1_080, step: 20)
                    .frame(width: 150)
                    .accessibilityValue("\(Int(preferences.readingSettings.contentWidth)) points")
            }

            Toggle("High Contrast", isOn: highContrast)
            Toggle("Reduce Motion", isOn: reduceMotion)

            Divider()
            Button("Reset Reading Settings") {
                preferences.resetReadingSettings()
            }
            .buttonStyle(.link)
            .disabled(preferences.readingSettings == .default)
        }
        .padding(18)
        .frame(width: 330)
    }

    private var lineSpacing: Binding<Double> {
        settingBinding(\.lineSpacing)
    }

    private var contentWidth: Binding<Double> {
        settingBinding(\.contentWidth)
    }

    private var highContrast: Binding<Bool> {
        settingBinding(\.highContrast)
    }

    private var reduceMotion: Binding<Bool> {
        settingBinding(\.reduceMotion)
    }

    private func settingBinding<Value>(_ keyPath: WritableKeyPath<ReadingSettings, Value>) -> Binding<Value> {
        Binding(
            get: { preferences.readingSettings[keyPath: keyPath] },
            set: { value in
                update { $0[keyPath: keyPath] = value }
            }
        )
    }

    private func update(_ change: (inout ReadingSettings) -> Void) {
        var settings = preferences.readingSettings
        change(&settings)
        preferences.readingSettings = settings.normalized
    }
}
