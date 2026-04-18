import SwiftUI

/// The root tab bar view shown after a successful login.
///
/// `MainTabView` hosts five tabs — Home, Service, Health, Bonus, and Postfach —
/// and applies the app's primary tint color to the tab bar.
struct MainTabView: View {

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
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
