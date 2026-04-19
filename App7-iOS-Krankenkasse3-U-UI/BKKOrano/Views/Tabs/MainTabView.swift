import SwiftUI

/// Top-level tab shell — v2 redesign.
///
/// Evolution from v1:
/// - Drops the "Health" tab. The preventive/health content from v1 is folded
///   into the promoted **Service** tab, which has grown from a secondary rail
///   on Home into a first-class destination.
/// - Switches tab icons from semi-outline to a mix of filled/outlined
///   symbols that flip on selection — closer to Google Material's convention.
/// - Keeps Profile as a full tab (carried over from v1 — it worked well).
struct MainTabView: View {

    @State private var selection: Tab = .home

    enum Tab: Hashable {
        case home, service, messages, profile
    }

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Label(
                        String(localized: "tab_v2_start"),
                        systemImage: selection == .home ? "house.fill" : "house"
                    )
                }
                .tag(Tab.home)

            ServiceView()
                .tabItem {
                    Label(
                        String(localized: "tab_v2_service"),
                        systemImage: selection == .service ? "square.grid.2x2.fill" : "square.grid.2x2"
                    )
                }
                .tag(Tab.service)

            PostfachView()
                .tabItem {
                    Label(
                        String(localized: "tab_postfach"),
                        systemImage: selection == .messages ? "tray.fill" : "tray"
                    )
                }
                .tag(Tab.messages)

            ProfileView()
                .tabItem {
                    Label(
                        String(localized: "tab_profile"),
                        systemImage: selection == .profile ? "person.crop.circle.fill" : "person.crop.circle"
                    )
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
