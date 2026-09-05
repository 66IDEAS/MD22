import Foundation
import Observation
import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum DisplayTheme: String, CaseIterable, Identifiable, Sendable, Codable {
    case light
    case dark
    case sciFi = "sci-fi"
    case blueprint
    case eightBit = "8-bit"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        case .sciFi: "Sci-Fi"
        case .blueprint: "Blueprint"
        case .eightBit: "8-Bit"
        }
    }
}

struct ReadingSettings: Codable, Sendable, Equatable {
    var fontScale: Double
    var lineSpacing: Double
    var contentWidth: Double
    var highContrast: Bool
    var reduceMotion: Bool

    static let `default` = ReadingSettings(
        fontScale: 1,
        lineSpacing: 1.68,
        contentWidth: 760,
        highContrast: false,
        reduceMotion: false
    )

    var normalized: ReadingSettings {
        ReadingSettings(
            fontScale: min(max(fontScale, 0.8), 1.6),
            lineSpacing: min(max(lineSpacing, 1.25), 2.2),
            contentWidth: min(max(contentWidth, 520), 1_080),
            highContrast: highContrast,
            reduceMotion: reduceMotion
        )
    }
}

@MainActor
@Observable
final class PreferencesStore {
    private enum Key {
        static let appAppearance = "appAppearance"
        static let displayTheme = "displayTheme"
        static let readingSettings = "readingSettings"
        static let showsHistory = "showsHistory"
        static let showsInspector = "showsInspector"
        static let exportFormat = "exportFormat"
        static let exportTheme = "exportTheme"
    }

    private let defaults: UserDefaults

    var appAppearance: AppAppearance {
        didSet { defaults.set(appAppearance.rawValue, forKey: Key.appAppearance) }
    }

    var displayTheme: DisplayTheme {
        didSet { defaults.set(displayTheme.rawValue, forKey: Key.displayTheme) }
    }

    var readingSettings: ReadingSettings {
        didSet {
            if let data = try? JSONEncoder().encode(readingSettings.normalized) {
                defaults.set(data, forKey: Key.readingSettings)
            }
        }
    }

    var showsHistory: Bool {
        didSet { defaults.set(showsHistory, forKey: Key.showsHistory) }
    }
    var showsInspector: Bool {
        didSet { defaults.set(showsInspector, forKey: Key.showsInspector) }
    }

    var exportFormat: ExportFormat {
        didSet { defaults.set(exportFormat.rawValue, forKey: Key.exportFormat) }
    }

    var exportTheme: DisplayTheme {
        didSet { defaults.set(exportTheme.rawValue, forKey: Key.exportTheme) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        appAppearance = AppAppearance(rawValue: defaults.string(forKey: Key.appAppearance) ?? "") ?? .system
        displayTheme = DisplayTheme(rawValue: defaults.string(forKey: Key.displayTheme) ?? "") ?? .light
        if let data = defaults.data(forKey: Key.readingSettings),
           let decoded = try? JSONDecoder().decode(ReadingSettings.self, from: data) {
            readingSettings = decoded.normalized
        } else {
            readingSettings = .default
        }
        showsHistory = defaults.object(forKey: Key.showsHistory) as? Bool ?? true
        showsInspector = defaults.object(forKey: Key.showsInspector) as? Bool ?? true
        exportFormat = ExportFormat(rawValue: defaults.string(forKey: Key.exportFormat) ?? "") ?? .pdf
        exportTheme = DisplayTheme(rawValue: defaults.string(forKey: Key.exportTheme) ?? "") ?? .light
    }

    func resetReadingSettings() {
        readingSettings = .default
    }
}
