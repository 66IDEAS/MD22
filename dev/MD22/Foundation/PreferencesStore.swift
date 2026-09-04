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

@MainActor
@Observable
final class PreferencesStore {
    private enum Key {
        static let appAppearance = "appAppearance"
        static let displayTheme = "displayTheme"
    }

    private let defaults: UserDefaults

    var appAppearance: AppAppearance {
        didSet { defaults.set(appAppearance.rawValue, forKey: Key.appAppearance) }
    }

    var displayTheme: DisplayTheme {
        didSet { defaults.set(displayTheme.rawValue, forKey: Key.displayTheme) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        appAppearance = AppAppearance(rawValue: defaults.string(forKey: Key.appAppearance) ?? "") ?? .system
        displayTheme = DisplayTheme(rawValue: defaults.string(forKey: Key.displayTheme) ?? "") ?? .light
    }
}
