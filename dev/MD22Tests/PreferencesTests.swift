import Foundation
import Testing
@testable import MD22

@MainActor
@Suite("Reader preferences")
struct PreferencesTests {
    @Test("Global reading settings persist, normalize, and reset")
    func readingSettings() throws {
        let suiteName = UUID().uuidString
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let preferences = PreferencesStore(defaults: defaults)
        preferences.readingSettings = ReadingSettings(
            fontScale: 9,
            lineSpacing: 1.5,
            contentWidth: 900,
            highContrast: true,
            reduceMotion: true
        )

        let restored = PreferencesStore(defaults: defaults)
        #expect(restored.readingSettings.fontScale == 1.6)
        #expect(restored.readingSettings.lineSpacing == 1.5)
        #expect(restored.readingSettings.contentWidth == 900)
        #expect(restored.readingSettings.highContrast)
        #expect(restored.readingSettings.reduceMotion)

        restored.resetReadingSettings()
        #expect(restored.readingSettings == .default)

        preferences.showsHistory = false
        preferences.showsInspector = false
        preferences.showsStatusBar = false
        let layoutRestored = PreferencesStore(defaults: defaults)
        #expect(!layoutRestored.showsHistory)
        #expect(!layoutRestored.showsInspector)
        #expect(!layoutRestored.showsStatusBar)
    }
}
