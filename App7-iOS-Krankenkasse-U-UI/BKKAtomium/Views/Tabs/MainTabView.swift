import SwiftUI

/// The root tab bar view shown after a successful login.
///
/// `MainTabView` hosts five tabs — Home, Service, Health, Bonus, and Postfach —
/// and applies the app's primary tint color to the tab bar.
struct MainTabView: View {
    @Environment(AppState.self) private var appState

    /// The currently selected tab.
    @State private var selection: Tab = .home

    /// The available tab destinations.
    enum Tab: Hashable {
        /// The home dashboard tab.
        case home
        /// The service (eGK / certificates) tab.
        case service
        /// The health information tab.
        case health
        /// The bonus programme tab.
        case bonus
        /// The message inbox tab.
        case postfach

        var stringValue: String {
            switch self {
            case .home: return "home"
            case .service: return "service"
            case .health: return "health"
            case .bonus: return "bonus"
            case .postfach: return "postfach"
            }
        }

        init(stringValue: String) {
            switch stringValue {
            case "service": self = .service
            case "health": self = .health
            case "bonus": self = .bonus
            case "postfach": self = .postfach
            default: self = .home
            }
        }
    }

    /// Renders the `TabView` with all five tab items.
    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Label(String(localized: "tab_home"), systemImage: "house.fill")
                }
                .tag(Tab.home)

            ServiceView()
                .tabItem {
                    Label(String(localized: "tab_service"), systemImage: "headphones")
                }
                .tag(Tab.service)

            HealthView()
                .tabItem {
                    Label(String(localized: "tab_health"), systemImage: "heart.fill")
                }
                .tag(Tab.health)

            BonusView()
                .tabItem {
                    Label(String(localized: "tab_bonus"), systemImage: "star.fill")
                }
                .tag(Tab.bonus)

            PostfachView()
                .tabItem {
                    Label(String(localized: "tab_postfach"), systemImage: "tray.fill")
                }
                .tag(Tab.postfach)
        }
        .tint(AppTheme.primary)
        .onChange(of: selection) { _, newValue in
            appState.selectedTab = newValue.stringValue
        }
        .onChange(of: appState.selectedTab) { _, newValue in
            selection = Tab(stringValue: newValue)
        }
        .onAppear {
            selection = Tab(stringValue: appState.selectedTab)
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
