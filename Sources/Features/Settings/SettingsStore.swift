import Combine
import Foundation

@MainActor
final class SettingsStore: ObservableObject {
    private let defaults: UserDefaults
    private static let key = "piko.preferences.v1"
    @Published var preferences: PikoPreferences {
        didSet {
            if let data = try? JSONEncoder().encode(preferences) {
                defaults.set(data, forKey: Self.key)
            }
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        var restored = defaults.data(forKey: Self.key)
            .flatMap { try? JSONDecoder().decode(PikoPreferences.self, from: $0) }
            ?? PikoPreferences()
        restored.postFontPercent = restored.postFontPercent.isFinite
            ? min(160, max(80, restored.postFontPercent)) : 100
        preferences = restored
    }

    func resetRules() {
        let toolbar = preferences.hideNativeToolbar
        preferences = PikoPreferences()
        preferences.hideNativeToolbar = toolbar
    }
}
