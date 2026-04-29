import SwiftUI

/// The root tab bar view shown after a successful login.
///
/// `MainTabView` hosts five tabs — Home, Service, Health, Bonus, and Postfach —
/// and applies the app's primary tint color to the tab bar.
struct MainTabView: View {
    @Environment(AppState.self) private var appState

    /// The currently selected tab.
    @State private var selection: Tab = .home

    /// Steuert das Onboarding (einmalig beim ersten Start nach dem Login).
    @State private var showOnboarding = false

    /// Steuert das „Was ist neu?"-Sheet (einmalig pro App-Version).
    @State private var showWhatsNew = false

    private static let onboardingKey = "hasSeenOnboarding_v1"
    private static let whatsNewKey   = "hasSeenWhatsNew_v1_2"

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
                .badge(3)
        }
        .tint(AppTheme.primary)
        .sensoryFeedback(.selection, trigger: selection)
        .onChange(of: selection) { _, newValue in
            appState.selectedTab = newValue.stringValue
        }
        .onChange(of: appState.selectedTab) { _, newValue in
            selection = Tab(stringValue: newValue)
        }
        .onAppear {
            selection = Tab(stringValue: appState.selectedTab)
            // Im UI-Test-Modus keine modalen Sheets anzeigen
            guard !CommandLine.arguments.contains("--uitesting") else { return }
            // Delay > Login-Transition (0.35 s), sonst verwirft UIKit das fullScreenCover lautlos
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let hasOnboarding = UserDefaults.standard.bool(forKey: Self.onboardingKey)
                let hasWhatsNew   = UserDefaults.standard.bool(forKey: Self.whatsNewKey)
                if !hasOnboarding {
                    showOnboarding = true
                } else if !hasWhatsNew {
                    showWhatsNew = true
                }
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                UserDefaults.standard.set(true, forKey: Self.onboardingKey)
                showOnboarding = false
                // „Was ist neu?" direkt im Anschluss ans Onboarding anzeigen
                if !UserDefaults.standard.bool(forKey: Self.whatsNewKey) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showWhatsNew = true
                    }
                }
            }
        }
        .sheet(isPresented: $showWhatsNew) {
            WhatsNewView {
                UserDefaults.standard.set(true, forKey: Self.whatsNewKey)
                showWhatsNew = false
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
