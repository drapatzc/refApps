import SwiftUI
import SwiftData

/// Home dashboard — a vertically flowing feed of sections.
///
/// **UX departure from the reference app**
/// - No photo hero. A warm gradient band provides mood without overpowering.
/// - A condensed status card replaces a large hero image: insurance number,
///   actively insured badge, and member name at a glance.
/// - The 6-widget grid is replaced by a horizontal "Aktionen" rail at the top
///   plus a compact "Service" rail further down — fewer decisions above the fold.
/// - A live bonus-progress strip is promoted to the dashboard, so users can see
///   their program status without navigating to a dedicated tab.
/// - Deep search lives behind a toolbar icon to keep the first viewport calm.
struct HomeView: View {

    // MARK: - Navigation

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
    }

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var path = NavigationPath()
    @State private var searchText = ""
    @State private var profileVM = ProfileViewModel()
    @State private var bonusVM = BonusProgramViewModel()

    private var allSearchable: [SearchEntry] { SearchEntry.catalog }
    private var filteredSearch: [SearchEntry] {
        guard !searchText.isEmpty else { return [] }
        let needle = searchText.lowercased()
        return allSearchable.filter {
            $0.title.lowercased().contains(needle) ||
            $0.subtitle.lowercased().contains(needle)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spaceL) {
                    greetingHeader
                    statusCard
                    actionRail
                    bonusStrip
                    serviceRail
                    helpSection
                }
                .padding(.vertical, AppTheme.spaceL)
            }
            .background(AppTheme.canvas.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: Text(String(localized: "home_search_placeholder"))
            )
            .overlay(alignment: .top) { searchResultsOverlay }
            .toolbar { toolbarContent }
            .task {
                profileVM.loadPerson(context: modelContext)
            }
            .navigationDestination(for: Destination.self) { dest in
                destinationView(for: dest)
            }
        }
    }

    // MARK: - Header

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceXS) {
            Text(greetingForTimeOfDay())
                .font(.callout)
                .foregroundStyle(.secondary)
            Text(profileVM.person?.firstName ?? "Willkommen")
                .font(.system(.largeTitle, design: .serif, weight: .semibold))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.spaceL)
    }

    // MARK: - Status card

    private var statusCard: some View {
        HStack(spacing: AppTheme.spaceM) {
            ZStack {
                Circle()
                    .fill(AppTheme.heroGradient)
                    .frame(width: 56, height: 56)
                Image(systemName: "checkmark.shield.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "insurance_status_valid"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.success)
                if let person = profileVM.person {
                    Text(person.fullName)
                        .font(.headline)
                    Text(String(localized: "insurance_number") + ": " + person.insuranceNumber)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(AppTheme.spaceM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous)
                .strokeBorder(AppTheme.peach.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: AppTheme.primaryDeep.opacity(0.08), radius: 14, x: 0, y: 6)
        .padding(.horizontal, AppTheme.spaceL)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("status_card")
    }

    // MARK: - Action rail

    private var actionRail: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(
                title: String(localized: "home_section_services"),
                icon: "sparkles"
            )
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.spaceM) {
                    heroAction(
                        icon: "doc.text.viewfinder",
                        title: String(localized: "widget_sick_note_title"),
                        subtitle: String(localized: "widget_sick_note_subtitle"),
                        tint: AppTheme.primary
                    ) { path.append(Destination.sickNote) }

                    heroAction(
                        icon: "tray.full.fill",
                        title: String(localized: "widget_applications_title"),
                        subtitle: String(localized: "widget_applications_subtitle"),
                        tint: AppTheme.accent
                    ) { path.append(Destination.applications) }

                    heroAction(
                        icon: "creditcard.fill",
                        title: String(localized: "widget_health_card_title"),
                        subtitle: String(localized: "widget_health_card_subtitle"),
                        tint: AppTheme.primaryDeep
                    ) { path.append(Destination.healthCard) }

                    heroAction(
                        icon: "eurosign.bank.building.fill",
                        title: String(localized: "widget_sick_pay_title"),
                        subtitle: String(localized: "widget_sick_pay_subtitle"),
                        tint: AppTheme.primary
                    ) { path.append(Destination.sickPay) }
                }
                .padding(.horizontal, AppTheme.spaceL)
            }
        }
    }

    private func heroAction(
        icon: String,
        title: String,
        subtitle: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: AppTheme.spaceS) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(.white)
                }
                Spacer(minLength: AppTheme.spaceM)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(2)
            }
            .padding(AppTheme.spaceM)
            .frame(width: 200, height: 160, alignment: .topLeading)
            .background(
                LinearGradient(
                    colors: [tint, tint.opacity(0.72)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
            .shadow(color: tint.opacity(0.35), radius: 14, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bonus strip

    private var bonusStrip: some View {
        Button { path.append(Destination.bonus) } label: {
            VStack(alignment: .leading, spacing: AppTheme.spaceS) {
                HStack(spacing: AppTheme.spaceS) {
                    Image(systemName: "star.leadinghalf.filled")
                        .foregroundStyle(AppTheme.primary)
                    Text(String(localized: "widget_bonus_title"))
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    Spacer()
                    Text(bonusVM.formattedCurrent + " / " + bonusVM.formattedGoal)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                ProgressView(value: bonusVM.progress)
                    .progressViewStyle(.linear)
                    .tint(AppTheme.primary)
                Text(String(localized: "bonus_info_hint"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(AppTheme.spaceM)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.softGradient)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous)
                    .strokeBorder(AppTheme.primary.opacity(0.18), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppTheme.spaceL)
    }

    // MARK: - Service rail

    private var serviceRail: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(
                title: String(localized: "home_section_service_hotline"),
                icon: "phone.bubble.fill"
            )

            VStack(spacing: 0) {
                serviceRow(
                    icon: "stethoscope",
                    title: String(localized: "home_hotline_doctor_title"),
                    subtitle: String(localized: "home_hotline_doctor_subtitle")
                ) { path.append(Destination.hotlineDoctor) }

                Divider().padding(.leading, 72)

                serviceRow(
                    icon: "waveform.path.ecg",
                    title: String(localized: "home_hotline_medical_title"),
                    subtitle: String(localized: "home_hotline_medical_subtitle")
                ) { path.append(Destination.hotlineMedical) }

                Divider().padding(.leading, 72)

                serviceRow(
                    icon: "cross.case.fill",
                    title: String(localized: "service_egk_lost_title"),
                    subtitle: String(localized: "service_egk_lost_subtitle")
                ) { path.append(Destination.egkLost) }
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
            .shadow(color: AppTheme.primaryDeep.opacity(0.05), radius: 10, x: 0, y: 4)
            .padding(.horizontal, AppTheme.spaceL)
        }
    }

    private func serviceRow(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: AppTheme.spaceM) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppTheme.peach.opacity(0.5))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(AppTheme.primary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.ink)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, AppTheme.spaceM)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Help section

    private var helpSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(
                title: String(localized: "home_section_help"),
                icon: "questionmark.circle.fill"
            )
            HStack(spacing: AppTheme.spaceM) {
                helpTile(
                    icon: "envelope.fill",
                    title: String(localized: "home_help_contact"),
                    subtitle: String(localized: "home_help_contact_subtitle")
                ) { path.append(Destination.contact) }
                helpTile(
                    icon: "text.book.closed.fill",
                    title: String(localized: "home_help_faq"),
                    subtitle: String(localized: "home_help_faq_subtitle")
                ) { path.append(Destination.faq) }
            }
            .padding(.horizontal, AppTheme.spaceL)
        }
    }

    private func helpTile(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: AppTheme.spaceS) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(AppTheme.primary)
                    .padding(.bottom, AppTheme.spaceXS)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(AppTheme.spaceM)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
            .shadow(color: AppTheme.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack(spacing: AppTheme.spaceS) {
                Circle()
                    .fill(AppTheme.heroGradient)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "heart.text.square.fill")
                            .font(.caption2)
                            .foregroundStyle(.white)
                    )
                Text("Orano")
                    .font(.system(.headline, design: .serif, weight: .semibold))
            }
        }
    }

    // MARK: - Search overlay

    @ViewBuilder
    private var searchResultsOverlay: some View {
        if !searchText.isEmpty {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if filteredSearch.isEmpty {
                        OranoEmptyState(
                            icon: "magnifyingglass",
                            title: String(localized: "home_search_no_results"),
                            subtitle: String(localized: "home_search_no_results_subtitle")
                        )
                    } else {
                        ForEach(filteredSearch) { entry in
                            Button {
                                searchText = ""
                                path.append(entry.destination)
                            } label: {
                                HStack(spacing: AppTheme.spaceM) {
                                    Image(systemName: entry.icon)
                                        .foregroundStyle(AppTheme.primary)
                                    VStack(alignment: .leading) {
                                        Text(entry.title).font(.subheadline.weight(.semibold))
                                        Text(entry.subtitle).font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, AppTheme.spaceL)
                                .padding(.vertical, AppTheme.spaceM)
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                }
            }
            .background(AppTheme.canvas)
            .transition(.opacity)
        }
    }

    // MARK: - Destination factory

    @ViewBuilder
    private func destinationView(for destination: Destination) -> some View {
        switch destination {
        case .sickNote:
            SickNoteFlowView()
        case .applications:
            ApplicationsView()
        case .sickPay:
            SickPayView()
        case .bonus:
            BonusView()
        case .healthCard:
            OranoPlaceholder(icon: "creditcard.fill", title: String(localized: "placeholder_health_card_title"))
        case .contact:
            ContactSheetView()
        case .faq:
            FAQWebView()
        case .hotlineDoctor:
            OranoPlaceholder(icon: "stethoscope", title: String(localized: "home_hotline_doctor_title"))
        case .hotlineMedical:
            OranoPlaceholder(icon: "waveform.path.ecg", title: String(localized: "home_hotline_medical_title"))
        case .egkMissing:
            OranoPlaceholder(icon: "creditcard", title: String(localized: "service_egk_missing_title"))
        case .egkLost:
            OranoPlaceholder(icon: "cross.case.fill", title: String(localized: "service_egk_lost_title"))
        case .certificates:
            OranoPlaceholder(icon: "doc.badge.plus", title: String(localized: "service_request_certificates_title"))
        }
    }

    // MARK: - Helpers

    private func greetingForTimeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
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
        )
    ]
}

// MARK: - Bonus view model (kept here to match pbxproj file listing of BonusView.swift)

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

#Preview {
    HomeView()
        .environment(AppState())
}
