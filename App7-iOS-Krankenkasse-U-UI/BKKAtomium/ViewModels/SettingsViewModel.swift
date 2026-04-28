import SwiftUI
import Observation

@Observable final class SettingsViewModel {
    var pushEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "notif.push") }
        set { UserDefaults.standard.set(newValue, forKey: "notif.push") }
    }

    var bonusReminders: Bool {
        get { UserDefaults.standard.bool(forKey: "notif.bonus") }
        set { UserDefaults.standard.set(newValue, forKey: "notif.bonus") }
    }

    var preventionAlerts: Bool {
        get { UserDefaults.standard.bool(forKey: "notif.prevention") }
        set { UserDefaults.standard.set(newValue, forKey: "notif.prevention") }
    }

    var appearanceIndex: Int {
        get { UserDefaults.standard.integer(forKey: "appearance.index") }
        set {
            UserDefaults.standard.set(newValue, forKey: "appearance.index")
            updateColorScheme(newValue)
        }
    }

    private weak var appState: AppState?

    init() {
        setupDefaults()
    }

    private func setupDefaults() {
        let defaults: [String: Any] = [
            "notif.push": true,
            "notif.bonus": true,
            "notif.prevention": true,
            "appearance.index": 0
        ]
        UserDefaults.standard.register(defaults: defaults)
    }

    func setup(appState: AppState) {
        self.appState = appState
        updateColorScheme(appearanceIndex)
    }

    private func updateColorScheme(_ index: Int) {
        switch index {
        case 1:
            appState?.colorSchemeOverride = .light
        case 2:
            appState?.colorSchemeOverride = .dark
        default:
            appState?.colorSchemeOverride = nil
        }
    }
}
