import SwiftUI
import SwiftData

/// The main profile sheet, presented modally from the home screen.
///
/// `ProfileView` shows the insured person's header, navigation links to all
/// data categories (address, phone, bank account, email, insurance status),
/// miscellaneous links (settings, help), legal documents, and a logout button.
struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ProfileViewModel()
    @State private var showLogoutAlert = false
    @State private var destination: ProfileDestination? = nil

    /// All possible navigation destinations within the profile sheet.
    enum ProfileDestination: Hashable {
        /// The insured person's personal data overview.
        case myData
        /// The address list.
        case address
        /// The phone number list.
        case phone
        /// The bank account list.
        case bankAccount
        /// The email address list.
        case email
        /// The insurance status detail screen.
        case insuranceStatus
        /// The app settings placeholder.
        case settings
        /// The help and feedback placeholder.
        case helpFeedback
        /// The privacy policy document.
        case privacy
        /// The terms of use document.
        case terms
        /// The imprint document.
        case imprint
    }

    /// Renders the profile list with sections for personal data, miscellaneous links,
    /// legal documents, and the logout button.
    var body: some View {
        NavigationStack {
            List {
                // Profilkopf
                if let person = viewModel.person {
                    ProfileHeaderSection(person: person)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }

                // Meine Daten
                Section {
                    NavigationLink(value: ProfileDestination.address) {
                        ProfileRowView(
                            icon: "house.fill",
                            iconColor: Color(red: 0.11, green: 0.29, blue: 0.50),
                            title: String(localized: "profile_address")
                        )
                    }
                    NavigationLink(value: ProfileDestination.phone) {
                        ProfileRowView(
                            icon: "phone.fill",
                            iconColor: Color(red: 0.20, green: 0.60, blue: 0.40),
                            title: String(localized: "profile_phone")
                        )
                    }
                    NavigationLink(value: ProfileDestination.bankAccount) {
                        ProfileRowView(
                            icon: "banknote.fill",
                            iconColor: Color(red: 0.95, green: 0.65, blue: 0.10),
                            title: String(localized: "profile_bank_account")
                        )
                    }
                    NavigationLink(value: ProfileDestination.email) {
                        ProfileRowView(
                            icon: "envelope.fill",
                            iconColor: Color(red: 0.80, green: 0.25, blue: 0.25),
                            title: String(localized: "profile_email")
                        )
                    }
                    NavigationLink(value: ProfileDestination.insuranceStatus) {
                        ProfileRowView(
                            icon: "person.text.rectangle.fill",
                            iconColor: Color(red: 0.55, green: 0.25, blue: 0.75),
                            title: String(localized: "profile_insurance_status")
                        )
                    }
                } header: {
                    Text(String(localized: "profile_section_my_data"))
                }

                // Weiteres
                Section {
                    NavigationLink(value: ProfileDestination.settings) {
                        ProfileRowView(
                            icon: "gearshape.fill",
                            iconColor: .gray,
                            title: String(localized: "profile_settings")
                        )
                    }
                    NavigationLink(value: ProfileDestination.helpFeedback) {
                        ProfileRowView(
                            icon: "questionmark.circle.fill",
                            iconColor: Color(red: 0.10, green: 0.45, blue: 0.55),
                            title: String(localized: "profile_help_feedback")
                        )
                    }
                } header: {
                    Text(String(localized: "profile_section_misc"))
                }

                // Rechtliches
                Section {
                    NavigationLink(value: ProfileDestination.privacy) {
                        ProfileRowView(
                            icon: "lock.shield.fill",
                            iconColor: Color(red: 0.11, green: 0.29, blue: 0.50),
                            title: String(localized: "profile_privacy")
                        )
                    }
                    NavigationLink(value: ProfileDestination.terms) {
                        ProfileRowView(
                            icon: "doc.plaintext.fill",
                            iconColor: .gray,
                            title: String(localized: "profile_terms")
                        )
                    }
                    NavigationLink(value: ProfileDestination.imprint) {
                        ProfileRowView(
                            icon: "info.circle.fill",
                            iconColor: Color(red: 0.20, green: 0.60, blue: 0.40),
                            title: String(localized: "profile_imprint")
                        )
                    }
                } header: {
                    Text(String(localized: "profile_section_legal"))
                }

                // Abmelden
                Section {
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text(String(localized: "profile_logout"))
                                .font(.body.weight(.semibold))
                            Spacer()
                        }
                    }
                    .accessibilityIdentifier("logoutButton")
                }
            }
            .navigationTitle(String(localized: "profile_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common_close")) {
                        dismiss()
                    }
                }
            }
            .navigationDestination(for: ProfileDestination.self) { dest in
                destinationView(for: dest)
            }
            .alert(String(localized: "profile_logout_confirm_title"), isPresented: $showLogoutAlert) {
                Button(String(localized: "profile_logout"), role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        appState.logout()
                    }
                    dismiss()
                }
                Button(String(localized: "common_cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "profile_logout_confirm_message"))
            }
        }
        .onAppear {
            viewModel.loadPerson(context: modelContext)
        }
    }

    /// Returns the detail view for the given profile navigation destination.
    ///
    /// - Parameter dest: The destination to navigate to.
    /// - Returns: The corresponding SwiftUI view.
    @ViewBuilder
    private func destinationView(for dest: ProfileDestination) -> some View {
        switch dest {
        case .address:
            AddressListView()
        case .phone:
            PhoneListView()
        case .bankAccount:
            BankAccountListView()
        case .email:
            EmailListView()
        case .insuranceStatus:
            InsuranceStatusView()
        case .settings:
            SettingsView()
        case .helpFeedback:
            HelpFeedbackView()
        case .myData:
            PlaceholderView(title: String(localized: "profile_section_my_data"), icon: "person.fill")
        case .privacy:
            PrivacyView()
        case .terms:
            TermsView()
        case .imprint:
            ImprintView()
        }
    }
}

// MARK: - Profilkopf

/// The gradient header section that shows the person's initials, full name, and insurance number.
struct ProfileHeaderSection: View {

    /// The insured person whose data is displayed in the header.
    let person: InsuredPerson
    @Environment(\.colorScheme) private var colorScheme

    /// Renders the gradient banner with an avatar circle and name/insurance number text.
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                AppTheme.headerGradient
                    .frame(height: 140)

                VStack(spacing: AppTheme.spacingS) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 72, height: 72)

                        Text(person.firstName.prefix(1) + person.lastName.prefix(1))
                            .font(.title.weight(.bold))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: 2) {
                        Text(person.fullName)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)

                        Text(person.insuranceNumber)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(.top, AppTheme.spacingM)
                .padding(.bottom, AppTheme.spacingL)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(person.fullName), \(String(localized: "insurance_number")): \(person.insuranceNumber)")
    }
}

// MARK: - Profilzeile

/// A single row inside the profile list with a colored icon and a text label.
struct ProfileRowView: View {

    /// The SF Symbols name for the row icon.
    let icon: String

    /// The tint color of the icon background.
    let iconColor: Color

    /// The row label text.
    let title: String

    /// Renders the rounded icon container and the title label side by side.
    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 34, height: 34)

                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(.body)
        }
    }
}

// MARK: - Platzhalter

/// A full-screen placeholder shown for features that have not been implemented yet.
struct PlaceholderView: View {

    /// The title displayed below the placeholder icon.
    let title: String

    /// The SF Symbols name of the large placeholder icon.
    let icon: String

    /// Renders the icon, title, and a "coming soon" subtitle centered in the available space.
    var body: some View {
        VStack(spacing: AppTheme.spacingL) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.secondary.opacity(0.4))

            Text(title)
                .font(.title2.weight(.bold))

            Text(String(localized: "placeholder_coming_soon"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.groupedBackground)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
