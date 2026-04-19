import SwiftUI

/// Service hub — v2 redesign.
///
/// Evolution: v1 had a slim "eGK + certificates" detail view plus a separate
/// Health tab. v2 promotes Service to a top-level tab and folds the old Health
/// content into it as the first section. Content is presented as a grid of
/// Material-style tiles instead of full-width rows, so the screen reads at a
/// glance and scales well on larger devices.
struct ServiceView: View {

    enum Destination: Hashable {
        case sickNote
        case bonus
        case sickPay
        case applications
        case egkLost
        case egkMissing
        case certificates
        case preventiveCare
        case hotlineDoctor
        case hotlineMedical
        case contact
        case faq
    }

    @State private var path = NavigationPath()
    @State private var viewModel = ServiceHubViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.spaceM),
        GridItem(.flexible(), spacing: AppTheme.spaceM)
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spaceXL) {
                    header
                    section(
                        title: String(localized: "service_v2_section_health"),
                        icon: "heart.text.square.fill",
                        tiles: viewModel.healthTiles
                    )
                    section(
                        title: String(localized: "service_v2_section_documents"),
                        icon: "doc.text.fill",
                        tiles: viewModel.documentTiles
                    )
                    section(
                        title: String(localized: "service_v2_section_contact"),
                        icon: "phone.bubble.fill",
                        tiles: viewModel.contactTiles
                    )
                }
                .padding(.vertical, AppTheme.spaceL)
            }
            .background(AppTheme.canvas.ignoresSafeArea())
            .navigationTitle(String(localized: "service_v2_title"))
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Destination.self) { dest in
                destinationView(for: dest)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "service_v2_intro"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, AppTheme.spaceL)
        }
    }

    // MARK: - Section

    private func section(title: String, icon: String, tiles: [ServiceHubViewModel.Tile]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceM) {
            OranoSectionHeader(title: title, icon: icon)
            LazyVGrid(columns: columns, spacing: AppTheme.spaceM) {
                ForEach(tiles) { tile in
                    OranoServiceTile(
                        icon: tile.icon,
                        title: tile.title,
                        subtitle: tile.subtitle,
                        tint: tile.tint
                    ) {
                        path.append(tile.destination)
                    }
                }
            }
            .padding(.horizontal, AppTheme.spaceL)
        }
    }

    // MARK: - Destinations

    @ViewBuilder
    private func destinationView(for destination: Destination) -> some View {
        switch destination {
        case .sickNote:        SickNoteFlowView()
        case .bonus:           BonusView()
        case .sickPay:         SickPayView()
        case .applications:    ApplicationsView()
        case .egkLost:         OranoPlaceholder(icon: "cross.case.fill", title: String(localized: "service_egk_lost_title"))
        case .egkMissing:      OranoPlaceholder(icon: "creditcard", title: String(localized: "service_egk_missing_title"))
        case .certificates:    OranoPlaceholder(icon: "doc.badge.plus", title: String(localized: "service_request_certificates_title"))
        case .preventiveCare:  OranoPlaceholder(icon: "stethoscope", title: String(localized: "discover_prevention_title"))
        case .hotlineDoctor:   OranoPlaceholder(icon: "stethoscope", title: String(localized: "home_hotline_doctor_title"))
        case .hotlineMedical:  OranoPlaceholder(icon: "waveform.path.ecg", title: String(localized: "home_hotline_medical_title"))
        case .contact:         ContactSheetView()
        case .faq:             FAQWebView()
        }
    }
}

/// View model backing the Service hub grid. Extracted so the view stays thin
/// and the tile catalogue can be unit-tested without rendering SwiftUI.
@Observable
final class ServiceHubViewModel {

    struct Tile: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let subtitle: String
        let tint: Color
        let destination: ServiceView.Destination
    }

    var healthTiles: [Tile] {
        [
            Tile(icon: "stethoscope",
                 title: String(localized: "discover_prevention_title"),
                 subtitle: String(localized: "discover_prevention_subtitle"),
                 tint: AppTheme.primary,
                 destination: .preventiveCare),
            Tile(icon: "star.circle.fill",
                 title: String(localized: "widget_bonus_title"),
                 subtitle: String(localized: "widget_bonus_subtitle"),
                 tint: AppTheme.accent,
                 destination: .bonus),
            Tile(icon: "doc.text.viewfinder",
                 title: String(localized: "widget_sick_note_title"),
                 subtitle: String(localized: "widget_sick_note_subtitle"),
                 tint: AppTheme.primary,
                 destination: .sickNote),
            Tile(icon: "eurosign.bank.building.fill",
                 title: String(localized: "widget_sick_pay_title"),
                 subtitle: String(localized: "widget_sick_pay_subtitle"),
                 tint: AppTheme.primaryDeep,
                 destination: .sickPay)
        ]
    }

    var documentTiles: [Tile] {
        [
            Tile(icon: "tray.full.fill",
                 title: String(localized: "widget_applications_title"),
                 subtitle: String(localized: "widget_applications_subtitle"),
                 tint: AppTheme.primary,
                 destination: .applications),
            Tile(icon: "doc.badge.plus",
                 title: String(localized: "service_request_certificates_title"),
                 subtitle: String(localized: "service_request_certificates_subtitle"),
                 tint: AppTheme.accent,
                 destination: .certificates),
            Tile(icon: "cross.case.fill",
                 title: String(localized: "service_egk_lost_title"),
                 subtitle: String(localized: "service_egk_lost_subtitle"),
                 tint: AppTheme.danger,
                 destination: .egkLost),
            Tile(icon: "creditcard.fill",
                 title: String(localized: "service_egk_missing_title"),
                 subtitle: String(localized: "service_egk_missing_subtitle"),
                 tint: AppTheme.primary,
                 destination: .egkMissing)
        ]
    }

    var contactTiles: [Tile] {
        [
            Tile(icon: "stethoscope",
                 title: String(localized: "home_hotline_doctor_title"),
                 subtitle: String(localized: "home_hotline_doctor_subtitle"),
                 tint: AppTheme.primary,
                 destination: .hotlineDoctor),
            Tile(icon: "waveform.path.ecg",
                 title: String(localized: "home_hotline_medical_title"),
                 subtitle: String(localized: "home_hotline_medical_subtitle"),
                 tint: AppTheme.accent,
                 destination: .hotlineMedical),
            Tile(icon: "envelope.fill",
                 title: String(localized: "home_help_contact"),
                 subtitle: String(localized: "home_help_contact_subtitle"),
                 tint: AppTheme.primary,
                 destination: .contact),
            Tile(icon: "text.book.closed.fill",
                 title: String(localized: "home_help_faq"),
                 subtitle: String(localized: "home_help_faq_subtitle"),
                 tint: AppTheme.primaryDeep,
                 destination: .faq)
        ]
    }

    /// Flat tile list — convenient for tests and counts.
    var allTiles: [Tile] { healthTiles + documentTiles + contactTiles }
}
