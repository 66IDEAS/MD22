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

@MainActor
@Observable
final class PreferencesStore {
    private enum Key {
        static let appAppearance = "appAppearance"
    }

    private let defaults: UserDefaults

    var appAppearance: AppAppearance {
        didSet { defaults.set(appAppearance.rawValue, forKey: Key.appAppearance) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        appAppearance = AppAppearance(rawValue: defaults.string(forKey: Key.appAppearance) ?? "") ?? .system
    }
}

