import SwiftUI
import SwiftData

/// Profile tab — personal header, data cards, legal section, logout.
///
/// Replaces the modal sheet in the reference app. As a full tab this view now
/// owns its own navigation stack with typed destinations.
struct ProfileView: View {

    enum Destination: Hashable {
        case address, phone, bank, email, insurance
        case settings, help
        case privacy, terms, imprint
    }

    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @State private var viewModel = ProfileViewModel()
    @State private var path = NavigationPath()
    @State private var showLogoutConfirm = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                headerSection
                myDataSection
                moreSection
                legalSection
                logoutSection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppTheme.canvas.ignoresSafeArea())
            .navigationTitle(String(localized: "profile_title"))
            .navigationBarTitleDisplayMode(.large)
            .task {
                viewModel.loadPerson(context: modelContext)
            }
            .navigationDestination(for: Destination.self) { dest in
                destination(for: dest)
            }
            .confirmationDialog(
                String(localized: "profile_logout_confirm_title"),
                isPresented: $showLogoutConfirm,
                titleVisibility: .visible
            ) {
                Button(String(localized: "profile_logout"), role: .destructive) {
                    withAnimation { appState.logout() }
                }
                Button(String(localized: "common_cancel"), role: .cancel) { }
            } message: {
                Text(String(localized: "profile_logout_confirm_message"))
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        Section {
            VStack(spacing: AppTheme.spaceM) {
                avatar
                if let person = viewModel.person {
                    Text(person.fullName)
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                        .foregroundStyle(AppTheme.ink)
                    HStack(spacing: AppTheme.spaceS) {
                        OranoChip(
                            text: String(localized: "insurance_status_valid"),
                            icon: "checkmark.seal.fill"
                        )
                        OranoChip(
                            text: person.insuranceNumber,
                            icon: "number",
                            filled: false
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spaceM)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(AppTheme.heroGradient)
                .frame(width: 92, height: 92)
            Text(initials(for: viewModel.person))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .shadow(color: AppTheme.primaryDeep.opacity(0.3), radius: 10, x: 0, y: 6)
    }

    private var myDataSection: some View {
        Section(String(localized: "profile_section_my_data")) {
            profileRow(
                destination: .address,
                icon: "house.fill",
                title: String(localized: "profile_address")
            )
            profileRow(
                destination: .phone,
                icon: "phone.fill",
                title: String(localized: "profile_phone")
            )
            profileRow(
                destination: .email,
                icon: "envelope.fill",
                title: String(localized: "profile_email")
            )
            profileRow(
                destination: .bank,
                icon: "creditcard.fill",
                title: String(localized: "profile_bank_account")
            )
            profileRow(
                destination: .insurance,
                icon: "shield.lefthalf.filled",
                title: String(localized: "profile_insurance_status")
            )
        }
    }

    private var moreSection: some View {
        Section(String(localized: "profile_section_misc")) {
            profileRow(
                destination: .settings,
                icon: "gearshape.fill",
                title: String(localized: "profile_settings")
            )
            profileRow(
                destination: .help,
                icon: "lifepreserver.fill",
                title: String(localized: "profile_help_feedback")
            )
        }
    }

    private var legalSection: some View {
        Section(String(localized: "profile_section_legal")) {
            profileRow(
                destination: .privacy,
                icon: "hand.raised.fill",
                title: String(localized: "profile_privacy")
            )
            profileRow(
                destination: .terms,
                icon: "doc.plaintext.fill",
                title: String(localized: "profile_terms")
            )
            profileRow(
                destination: .imprint,
                icon: "info.circle.fill",
                title: String(localized: "profile_imprint")
            )
        }
    }

    private var logoutSection: some View {
        Section {
            Button(role: .destructive) {
                showLogoutConfirm = true
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text(String(localized: "profile_logout"))
                        .font(.headline)
                    Spacer()
                }
            }
            .accessibilityIdentifier("logout_button")
        }
    }

    private func profileRow(destination: Destination, icon: String, title: String) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: AppTheme.spaceM) {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 28, height: 28)
                    .background(AppTheme.primarySoft)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text(title)
                    .font(.body)
                    .foregroundStyle(AppTheme.ink)
            }
        }
    }

    // MARK: - Destinations

    @ViewBuilder
    private func destination(for dest: Destination) -> some View {
        switch dest {
        case .address:   AddressListView()
        case .phone:     PhoneListView()
        case .bank:      BankAccountListView()
        case .email:     EmailListView()
        case .insurance: InsuranceStatusView()
        case .settings:
            OranoPlaceholder(icon: "gearshape.fill",
                             title: String(localized: "profile_settings"))
        case .help:
            OranoPlaceholder(icon: "lifepreserver.fill",
                             title: String(localized: "profile_help_feedback"))
        case .privacy:   PrivacyView()
        case .terms:     TermsView()
        case .imprint:   ImprintView()
        }
    }

    // MARK: - Helpers

    private func initials(for person: InsuredPerson?) -> String {
        guard let person else { return "?" }
        let f = person.firstName.first.map(String.init) ?? ""
        let l = person.lastName.first.map(String.init) ?? ""
        return (f + l).uppercased()
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
}
