import SwiftUI
import SwiftData

/// Home — v2 redesign.
///
/// Evolution from v1:
/// - Search is promoted from a toolbar-hidden entry to a prominent search
///   field right under the status card. Typing filters the Discover feed
///   immediately (Google-style, not a drawer).
/// - A **Discover** feed of image cards replaces the action rail of
///   gradient tiles. Each card carries a full-width illustration with an
///   eyebrow chip — warmer, more human, more modern.
/// - Quick actions remain as a horizontal chip row, but lighter-weight
///   (icon + label only) so they don't compete with Discover for attention.
/// - A bonus progress strip is retained as a subtle, full-width card at the
///   bottom.
/// - MVVM: all catalogue and filtering logic moves into `HomeViewModel`.
struct HomeView: View {

    enum Destination: Hashable {
        case sickNote
        case applications
        case sickPay
        case bonus
        case healthCard
        case contact
        case faq
        case hotlineDoctor
        case hotlineMedical
        case egkMissing
        case egkLost
        case certificates
        case preventiveCare
    }

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var path = NavigationPath()
    @State private var viewModel = HomeViewModel()
    @State private var profileVM = ProfileViewModel()

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spaceXL) {
                    greetingHeader
                    statusCard
                    searchField
                    if !viewModel.searchText.isEmpty {
                        searchResults
                    } else {
                        filterRow
                        quickActionsRow
                        discoverFeed
                        bonusStrip
                    }
                }
                .padding(.vertical, AppTheme.spaceL)
            }
            .background(AppTheme.canvas.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task {
                profileVM.loadPerson(context: modelContext)
            }
            .navigationDestination(for: Destination.self) { dest in
                destinationView(for: dest)
            }
        }
    }

    // MARK: - Greeting

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.greetingForTimeOfDay())
                .font(.callout)
                .foregroundStyle(.secondary)
            Text(profileVM.person?.firstName ?? "Willkommen")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)
            Text(String(localized: "home_v2_tagline"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.spaceL)
    }

    // MARK: - Status card

    private var statusCard: some View {
        HStack(spacing: AppTheme.spaceM) {
            ZStack {
                Circle()
                    .fill(AppTheme.actionGradient)
                    .frame(width: 52, height: 52)
                Image(systemName: "checkmark.shield.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(String(localized: "home_v2_status_card_title"))
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.success)
                if let person = profileVM.person {
                    Text(person.fullName)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(AppTheme.ink)
                    Text(person.insuranceNumber)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(AppTheme.spaceM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous)
                .strokeBorder(AppTheme.primarySoft, lineWidth: 1)
        )
        .shadow(color: AppTheme.ink.opacity(0.08), radius: 10, y: 3)
        .padding(.horizontal, AppTheme.spaceL)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("status_card")
    }

    // MARK: - Search (prominent, always visible)

    private var searchField: some View {
        HStack(spacing: AppTheme.spaceS) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(
                String(localized: "home_v2_search_placeholder"),
                text: $viewModel.searchText
            )
            .textFieldStyle(.plain)
            .autocorrectionDisabled()
            .accessibilityIdentifier("home_search_field")
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppTheme.spaceM)
        .padding(.vertical, 12)
        .background(AppTheme.surface)
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(AppTheme.primary.opacity(0.12), lineWidth: 1)
        )
        .padding(.horizontal, AppTheme.spaceL)
    }

    // MARK: - Filter chips

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spaceS) {
                ForEach(HomeViewModel.Filter.allCases) { filter in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.activeFilter = filter
                        }
                    } label: {
                        OranoChip(
                            text: filter.label,
                            icon: filter.icon,
                            filled: viewModel.activeFilter == filter
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.spaceL)
        }
    }

    // MARK: - Quick actions row

    private var quickActionsRow: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceM) {
            OranoSectionHeader(
                title: String(localized: "home_v2_quickactions_title"),
                icon: "bolt.fill"
            )
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.spaceM) {
                    ForEach(viewModel.quickActions) { action in
                        quickTile(action)
                    }
                }
                .padding(.horizontal, AppTheme.spaceL)
            }
        }
    }

    private func quickTile(_ action: HomeViewModel.QuickAction) -> some View {
        Button {
            path.append(action.destination)
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(action.tint.opacity(0.14))
                        .frame(width: 54, height: 54)
                    Image(systemName: action.icon)
                        .font(.title3)
                        .foregroundStyle(action.tint)
                }
                Text(action.title)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 84)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Discover feed

    private var discoverFeed: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceM) {
            OranoSectionHeader(
                title: String(localized: "home_v2_discover_title"),
                icon: "sparkles",
                trailing: AnyView(
                    Text(String(localized: "home_v2_discover_subtitle"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                )
            )
            VStack(spacing: AppTheme.spaceM) {
                ForEach(viewModel.filteredDiscoverCards) { card in
                    OranoFeedCard(
                        imageName: card.imageName,
                        eyebrow: card.eyebrow,
                        title: card.title,
                        subtitle: card.subtitle,
                        tint: card.tint
                    ) {
                        path.append(card.destination)
                    }
                }
            }
            .padding(.horizontal, AppTheme.spaceL)
        }
    }

    // MARK: - Bonus strip

    private var bonusStrip: some View {
        Button { path.append(Destination.bonus) } label: {
            HStack(spacing: AppTheme.spaceM) {
                ZStack {
                    Circle()
                        .fill(AppTheme.warmGradient)
                        .frame(width: 48, height: 48)
                    Image(systemName: "star.fill")
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(String(localized: "widget_bonus_title"))
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundStyle(AppTheme.ink)
                        Spacer()
                        Text(viewModel.bonusVM.formattedCurrent + " / " + viewModel.bonusVM.formattedGoal)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: viewModel.bonusVM.progress)
                        .progressViewStyle(.linear)
                        .tint(AppTheme.accent)
                }
            }
            .padding(AppTheme.spaceM)
            .frame(maxWidth: .infinity, alignment: .leading)
            .oranoCardFlat()
            .padding(.horizontal, AppTheme.spaceL)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Search results

    @ViewBuilder
    private var searchResults: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.searchResults.isEmpty {
                OranoEmptyState(
                    icon: "magnifyingglass",
                    title: String(localized: "home_search_no_results"),
                    subtitle: String(localized: "home_search_no_results_subtitle")
                )
            } else {
                ForEach(viewModel.searchResults) { entry in
                    Button {
                        viewModel.searchText = ""
                        path.append(entry.destination)
                    } label: {
                        HStack(spacing: AppTheme.spaceM) {
                            Image(systemName: entry.icon)
                                .frame(width: 36, height: 36)
                                .foregroundStyle(AppTheme.primary)
                                .background(AppTheme.primarySoft)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.title).font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.ink)
                                Text(entry.subtitle).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, AppTheme.spaceL)
                        .padding(.vertical, AppTheme.spaceM)
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 72)
                }
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(AppTheme.heroGradient)
                        .frame(width: 28, height: 28)
                    Text("O")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
                Text("Orano")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.ink)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                // No-op visual anchor — future notifications inbox lives here.
            } label: {
                Image(systemName: "bell")
                    .foregroundStyle(AppTheme.primary)
            }
            .accessibilityLabel("Benachrichtigungen")
        }
    }

    // MARK: - Destination factory

    @ViewBuilder
    private func destinationView(for destination: Destination) -> some View {
        switch destination {
        case .sickNote:        SickNoteFlowView()
        case .applications:    ApplicationsView()
        case .sickPay:         SickPayView()
        case .bonus:           BonusView()
        case .healthCard:      OranoPlaceholder(icon: "creditcard.fill", title: String(localized: "placeholder_health_card_title"))
        case .contact:         ContactSheetView()
        case .faq:             FAQWebView()
        case .hotlineDoctor:   OranoPlaceholder(icon: "stethoscope", title: String(localized: "home_hotline_doctor_title"))
        case .hotlineMedical:  OranoPlaceholder(icon: "waveform.path.ecg", title: String(localized: "home_hotline_medical_title"))
        case .egkMissing:      OranoPlaceholder(icon: "creditcard", title: String(localized: "service_egk_missing_title"))
        case .egkLost:         OranoPlaceholder(icon: "cross.case.fill", title: String(localized: "service_egk_lost_title"))
        case .certificates:    OranoPlaceholder(icon: "doc.badge.plus", title: String(localized: "service_request_certificates_title"))
        case .preventiveCare:  OranoPlaceholder(icon: "stethoscope", title: String(localized: "discover_prevention_title"))
        }
    }
}

#Preview {
    HomeView()
        .environment(AppState())
}

// MARK: - Home view model

/// State and catalogues backing the redesigned Home screen.
/// Kept in this file (mirrors v1's inline `BonusProgramViewModel`) so the
/// pbxproj target membership stays unchanged — an intentional simplification
/// that keeps v2 a drop-in replacement of v1's target layout.
@Observable
final class HomeViewModel {

    // MARK: Filter

    enum Filter: String, CaseIterable, Identifiable {
        case all, prevention, bonus, service
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all:        return String(localized: "home_v2_filter_all")
            case .prevention: return String(localized: "home_v2_filter_prevention")
            case .bonus:      return String(localized: "home_v2_filter_bonus")
            case .service:    return String(localized: "home_v2_filter_service")
            }
        }
        var icon: String? {
            switch self {
            case .all:        return "circle.grid.2x2"
            case .prevention: return "leaf"
            case .bonus:      return "star"
            case .service:    return "stethoscope"
            }
        }
    }

    // MARK: QuickAction

    struct QuickAction: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let tint: Color
        let destination: HomeView.Destination
    }

    // MARK: DiscoverCard

    struct DiscoverCard: Identifiable {
        let id = UUID()
        let imageName: String
        let eyebrow: String
        let title: String
        let subtitle: String
        let tint: Color
        let destination: HomeView.Destination
        let filter: Filter
    }

    // MARK: State

    var searchText: String = ""
    var activeFilter: Filter = .all
    var bonusVM: BonusProgramViewModel = .init()

    // MARK: Quick actions

    var quickActions: [QuickAction] {
        [
            QuickAction(icon: "doc.text.viewfinder",
                        title: String(localized: "widget_sick_note_title"),
                        tint: AppTheme.primary,
                        destination: .sickNote),
            QuickAction(icon: "tray.full.fill",
                        title: String(localized: "widget_applications_title"),
                        tint: AppTheme.accent,
                        destination: .applications),
            QuickAction(icon: "creditcard.fill",
                        title: String(localized: "widget_health_card_title"),
                        tint: AppTheme.primaryDeep,
                        destination: .healthCard),
            QuickAction(icon: "eurosign.bank.building.fill",
                        title: String(localized: "widget_sick_pay_title"),
                        tint: AppTheme.primary,
                        destination: .sickPay),
            QuickAction(icon: "phone.bubble.fill",
                        title: String(localized: "home_help_contact"),
                        tint: AppTheme.accent,
                        destination: .contact),
            QuickAction(icon: "questionmark.bubble.fill",
                        title: String(localized: "home_help_faq"),
                        tint: AppTheme.primaryDeep,
                        destination: .faq)
        ]
    }

    // MARK: Discover cards

    var discoverCards: [DiscoverCard] {
        [
            DiscoverCard(imageName: "discover-vorsorge",
                         eyebrow: String(localized: "discover_prevention_eyebrow"),
                         title: String(localized: "discover_prevention_title"),
                         subtitle: String(localized: "discover_prevention_subtitle"),
                         tint: AppTheme.primary,
                         destination: .preventiveCare,
                         filter: .prevention),
            DiscoverCard(imageName: "discover-bonus",
                         eyebrow: String(localized: "discover_bonus_eyebrow"),
                         title: String(localized: "discover_bonus_title"),
                         subtitle: String(localized: "discover_bonus_subtitle"),
                         tint: AppTheme.accent,
                         destination: .bonus,
                         filter: .bonus),
            DiscoverCard(imageName: "discover-service",
                         eyebrow: String(localized: "discover_service_eyebrow"),
                         title: String(localized: "discover_service_title"),
                         subtitle: String(localized: "discover_service_subtitle"),
                         tint: AppTheme.primaryDeep,
                         destination: .hotlineDoctor,
                         filter: .service),
            DiscoverCard(imageName: "hero-family",
                         eyebrow: String(localized: "discover_family_eyebrow"),
                         title: String(localized: "discover_family_title"),
                         subtitle: String(localized: "discover_family_subtitle"),
                         tint: AppTheme.accent,
                         destination: .applications,
                         filter: .service)
        ]
    }

    var filteredDiscoverCards: [DiscoverCard] {
        guard activeFilter != .all else { return discoverCards }
        return discoverCards.filter { $0.filter == activeFilter }
    }

    // MARK: Search

    var searchResults: [SearchEntry] {
        guard !searchText.isEmpty else { return [] }
        let needle = searchText.lowercased()
        return SearchEntry.catalog.filter {
            $0.title.lowercased().contains(needle) ||
            $0.subtitle.lowercased().contains(needle)
        }
    }

    // MARK: Greeting

    func greetingForTimeOfDay(now: Date = Date()) -> String {
        let hour = Calendar.current.component(.hour, from: now)
        switch hour {
        case 5..<11:  return String(localized: "greeting_morning")
        case 11..<17: return String(localized: "greeting_afternoon")
        case 17..<22: return String(localized: "greeting_evening")
        default:      return String(localized: "greeting_night")
        }
    }
}

// MARK: - Search catalog

struct SearchEntry: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let destination: HomeView.Destination

    static let catalog: [SearchEntry] = [
        SearchEntry(
            title: String(localized: "widget_sick_note_title"),
            subtitle: String(localized: "widget_sick_note_subtitle"),
            icon: "doc.text.viewfinder",
            destination: .sickNote
        ),
        SearchEntry(
            title: String(localized: "widget_applications_title"),
            subtitle: String(localized: "widget_applications_subtitle"),
            icon: "tray.full.fill",
            destination: .applications
        ),
        SearchEntry(
            title: String(localized: "widget_sick_pay_title"),
            subtitle: String(localized: "widget_sick_pay_subtitle"),
            icon: "eurosign.bank.building.fill",
            destination: .sickPay
        ),
        SearchEntry(
            title: String(localized: "widget_health_card_title"),
            subtitle: String(localized: "widget_health_card_subtitle"),
            icon: "creditcard.fill",
            destination: .healthCard
        ),
        SearchEntry(
            title: String(localized: "widget_bonus_title"),
            subtitle: String(localized: "widget_bonus_subtitle"),
            icon: "star.fill",
            destination: .bonus
        ),
        SearchEntry(
            title: String(localized: "home_help_contact"),
            subtitle: String(localized: "home_help_contact_subtitle"),
            icon: "envelope.fill",
            destination: .contact
        ),
        SearchEntry(
            title: String(localized: "discover_prevention_title"),
            subtitle: String(localized: "discover_prevention_subtitle"),
            icon: "stethoscope",
            destination: .preventiveCare
        )
    ]
}

// MARK: - Bonus view model (kept here so we don't alter pbxproj file layout)

@Observable
final class BonusProgramViewModel {
    var goalEuro: Double = 200.0
    var currentEuro: Double = 90.0
    var year: Int = Calendar.current.component(.year, from: Date())
    var measures: [BonusMeasure] = {
        let calendar = Calendar.current
        let today = Date()
        return [
            BonusMeasure(
                id: UUID(),
                titleKey: "bonus_measure_checkup",
                icon: "stethoscope",
                euroAmount: 30,
                date: calendar.date(byAdding: .day, value: -10, to: today)!
            ),
            BonusMeasure(
                id: UUID(),
                titleKey: "bonus_measure_dental",
                icon: "mouth.fill",
                euroAmount: 30,
                date: calendar.date(byAdding: .day, value: -35, to: today)!
            ),
            BonusMeasure(
                id: UUID(),
                titleKey: "bonus_measure_sport",
                icon: "figure.run",
                euroAmount: 30,
                date: calendar.date(byAdding: .day, value: -60, to: today)!
            )
        ]
    }()

    var completedCount: Int { measures.count }
    var progress: Double { min(currentEuro / goalEuro, 1.0) }
    var formattedCurrent: String { formatEuro(currentEuro) }
    var formattedGoal: String { formatEuro(goalEuro) }

    func formatEuro(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

struct BonusMeasure: Identifiable {
    let id: UUID
    let titleKey: String
    let icon: String
    let euroAmount: Double
    let date: Date
}
