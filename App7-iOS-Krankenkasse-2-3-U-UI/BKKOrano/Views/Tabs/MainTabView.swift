import SwiftUI

/// Top-level tab shell — four tabs: Home, Health, Messages, Profile.
///
/// Compared to the reference app this drops the Service and Bonus tabs; their
/// entry points now live inside the Home dashboard and the Health tab. Profile
/// is promoted from modal sheet to a full tab for a flatter information
/// architecture, matching Apple's own Health and Wallet apps.
struct MainTabView: View {

    @State private var selection: Tab = .home

    enum Tab: Hashable {
        case home, health, messages, profile
    }

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Label(String(localized: "tab_home"), systemImage: "square.grid.2x2.fill")
                }
                .tag(Tab.home)

            HealthView()
                .tabItem {
                    Label(String(localized: "tab_health"), systemImage: "heart.text.square.fill")
                }
                .tag(Tab.health)

            PostfachView()
                .tabItem {
                    Label(String(localized: "tab_postfach"), systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(Tab.messages)

            ProfileView()
                .tabItem {
                    Label(String(localized: "tab_profile"), systemImage: "person.crop.circle.fill")
                }
                .tag(Tab.profile)
        }
        .tint(AppTheme.primary)
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
