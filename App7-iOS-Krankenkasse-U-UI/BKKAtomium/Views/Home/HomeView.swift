import SwiftUI

// MARK: - Navigation Destinations

/// All possible push-navigation destinations within the home dashboard.
enum HomeDestination: Hashable {
    /// The sick note submission flow.
    case sickNote
    /// The applications (Anträge) list.
    case applications
    /// The sick pay (Krankengeld) overview.
    case sickPay
    /// The health card (eGK) placeholder.
    case healthCard
    /// The doctor hotline placeholder.
    case doctorHotline
    /// The medical hotline placeholder.
    case medicalHotline
}

// MARK: - Search Actions

/// Actions that can be triggered from the global search results.
enum HomeSearchAction: Hashable {
    /// Pushes to the given `HomeDestination`.
    case navigate(HomeDestination)
    /// Opens the contact sheet.
    case openContact
    /// Opens the FAQ web sheet.
    case openFAQ
}

// MARK: - Home View

/// The main home dashboard tab shown after a successful login.
///
/// Displays a hero image, a time-based greeting, a widget grid for quick actions,
/// service hotline links, and help options. A global search bar filters all visible items.
struct HomeView: View {
    @Environment(AppState.self) private var appState

    /// Controls presentation of the profile sheet.
    @State private var showProfile = false

    /// `true` after the view first appears, used to drive entrance animations.
    @State private var headerAppeared = false

    /// The current search query entered by the user.
    @State private var searchText = ""

    /// The navigation path for push destinations within this tab.
    @State private var path = NavigationPath()

    /// Controls presentation of the contact sheet.
    @State private var showContactSheet = false

    /// Controls presentation of the FAQ web sheet.
    @State private var showFAQSheet = false

    /// The FAQ URL opened in `FAQWebView`.
    private let faqURL = URL(string: "https://www.christiandrapatz.de")!

    /// Returns a localized greeting string based on the current hour of the day.
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return String(localized: "greeting_morning")
        case 12..<17: return String(localized: "greeting_afternoon")
        case 17..<22: return String(localized: "greeting_evening")
        default: return String(localized: "greeting_night")
        }
    }

    /// The search results filtered from `HomeSearchableItem.all` matching the current query.
    private var filteredItems: [HomeSearchableItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return [] }
        return HomeSearchableItem.all.filter {
            $0.title.lowercased().contains(query) ||
            $0.subtitle.lowercased().contains(query)
        }
    }

    /// `true` when the search field contains non-whitespace text.
    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Renders the navigation stack with the dashboard or search results, toolbar, and sheets.
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if isSearching {
                    searchResultsContent
                } else {
                    dashboardContent
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AppTheme.groupedBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BKKLogoView()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppTheme.primary)
                    }
                    .accessibilityLabel(String(localized: "home_nav_profile"))
                    .accessibilityIdentifier("profileButton")
                }
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text(String(localized: "home_search_placeholder"))
            )
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showContactSheet) {
                ContactSheetView()
            }
            .sheet(isPresented: $showFAQSheet) {
                FAQWebView(url: faqURL)
                    .ignoresSafeArea()
            }
            .navigationDestination(for: HomeDestination.self) { destination in
                destinationView(for: destination)
            }
        }
        .onAppear {
            withAnimation {
                headerAppeared = true
            }
        }
    }

    // MARK: - Dashboard Content

    /// The full scrollable dashboard layout shown when no search is active.
    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                MountainHeroView()
                    .frame(height: 220)
                    .clipped()

                VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                    // Begrüßung
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        Text(greeting)
                            .font(.title.weight(.bold))
                            .foregroundStyle(.primary)
                            .opacity(headerAppeared ? 1 : 0)
                            .offset(y: headerAppeared ? 0 : 12)

                        Text(appState.currentUserName)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(AppTheme.primary)
                            .opacity(headerAppeared ? 1 : 0)
                            .offset(y: headerAppeared ? 0 : 8)
                    }
                    .padding(.horizontal, AppTheme.spacingM)
                    .padding(.top, AppTheme.spacingL)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: headerAppeared)

                    // Widget-Kacheln
                    sectionTitle(String(localized: "home_section_services"))

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: AppTheme.spacingM),
                            GridItem(.flexible(), spacing: AppTheme.spacingM)
                        ],
                        spacing: AppTheme.spacingM
                    ) {
                        ForEach(Array(HomeWidget.allWidgets.enumerated()), id: \.offset) { index, widget in
                            NavigationLink(value: widget.destination) {
                                HomeWidgetCard(widget: widget)
                            }
                            .buttonStyle(.plain)
                            .opacity(headerAppeared ? 1 : 0)
                            .offset(y: headerAppeared ? 0 : 20)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.8)
                                    .delay(0.2 + Double(index) * 0.06),
                                value: headerAppeared
                            )
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingM)

                    // Service-Hotline
                    sectionTitle(String(localized: "home_section_service_hotline"))
                    VStack(spacing: AppTheme.spacingS) {
                        NavigationLink(value: HomeDestination.doctorHotline) {
                            HomeListRow(
                                icon: "phone.fill",
                                iconColor: Color(red: 0.20, green: 0.60, blue: 0.40),
                                title: String(localized: "home_hotline_doctor_title"),
                                subtitle: String(localized: "home_hotline_doctor_subtitle")
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink(value: HomeDestination.medicalHotline) {
                            HomeListRow(
                                icon: "phone.fill",
                                iconColor: Color(red: 0.11, green: 0.29, blue: 0.50),
                                title: String(localized: "home_hotline_medical_title"),
                                subtitle: String(localized: "home_hotline_medical_subtitle")
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, AppTheme.spacingM)

                    // Hilfe
                    sectionTitle(String(localized: "home_section_help"))
                    VStack(spacing: AppTheme.spacingS) {
                        Button {
                            showContactSheet = true
                        } label: {
                            HomeListRow(
                                icon: "envelope.fill",
                                iconColor: Color(red: 0.55, green: 0.25, blue: 0.75),
                                title: String(localized: "home_help_contact"),
                                subtitle: String(localized: "home_help_contact_subtitle")
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            showFAQSheet = true
                        } label: {
                            HomeListRow(
                                icon: "questionmark.circle.fill",
                                iconColor: Color(red: 0.10, green: 0.45, blue: 0.55),
                                title: String(localized: "home_help_faq"),
                                subtitle: String(localized: "home_help_faq_subtitle")
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, AppTheme.spacingM)

                    Spacer(minLength: AppTheme.spacingXXL)
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Search Results

    /// The content shown when the user is actively searching.
    private var searchResultsContent: some View {
        Group {
            if filteredItems.isEmpty {
                VStack(spacing: AppTheme.spacingM) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 52))
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text(String(localized: "home_search_no_results"))
                        .font(.headline)
                    Text(String(localized: "home_search_no_results_subtitle"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, AppTheme.spacingXXL)
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.spacingS) {
                        ForEach(filteredItems) { item in
                            Button {
                                triggerSearchAction(item.action)
                            } label: {
                                HomeListRow(
                                    icon: item.icon,
                                    iconColor: item.color,
                                    title: item.title,
                                    subtitle: item.subtitle
                                )
                            }
                            .buttonStyle(.plain)
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingM)
                    .padding(.top, AppTheme.spacingM)
                }
                .animation(.easeInOut(duration: 0.2), value: filteredItems.count)
            }
        }
    }

    /// Clears the search text and triggers the given action on the navigation stack or sheet state.
    ///
    /// - Parameter action: The `HomeSearchAction` to execute.
    private func triggerSearchAction(_ action: HomeSearchAction) {
        searchText = ""
        switch action {
        case .navigate(let destination):
            path.append(destination)
        case .openContact:
            showContactSheet = true
        case .openFAQ:
            showFAQSheet = true
        }
    }

    // MARK: - Section Title

    /// Returns a styled, uppercase section title label.
    ///
    /// - Parameter title: The localized title string.
    /// - Returns: A text view formatted as a section header.
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.5)
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.top, AppTheme.spacingS)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Destination Views

    /// Returns the destination view for the given `HomeDestination`.
    ///
    /// - Parameter destination: The home navigation destination to render.
    /// - Returns: The corresponding SwiftUI view.
    @ViewBuilder
    private func destinationView(for destination: HomeDestination) -> some View {
        switch destination {
        case .sickNote:
            SickNoteFlowView()
        case .applications:
            ApplicationsView()
        case .sickPay:
            SickPayView()
        case .healthCard:
            HealthCardView()
        case .doctorHotline:
            HotlineView(
                title: String(localized: "home_hotline_doctor_title"),
                number: "116 117",
                description: "Über den ärztlichen Bereitschaftsdienst erhalten Sie schnell einen Arzttermin – auch kurzfristig, wenn Ihre Praxis keinen freien Termin hat.",
                hours: "24 Stunden täglich, 7 Tage die Woche",
                note: "Im lebensbedrohlichen Notfall wählen Sie bitte 112.",
                color: Color(red: 0.20, green: 0.60, blue: 0.40)
            )
        case .medicalHotline:
            HotlineView(
                title: String(localized: "home_hotline_medical_title"),
                number: "116 117",
                description: "Kostenlose telefonische Beratung durch medizinisches Fachpersonal – wenn Sie unsicher sind, ob ein Arztbesuch notwendig ist.",
                hours: "Täglich 19:00–8:00 Uhr, am Wochenende und Feiertagen ganztägig",
                note: "Im lebensbedrohlichen Notfall wählen Sie bitte 112.",
                color: Color(red: 0.11, green: 0.29, blue: 0.50)
            )
        }
    }
}

// MARK: - Logo

/// The BKK Atomium logo view shown in the navigation bar leading position.
///
/// Displays a cross circle SF Symbol alongside the app name in bold.
struct BKKLogoView: View {

    /// Renders the cross icon and "BKK Atomium" label side by side.
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "cross.circle.fill")
                .foregroundStyle(AppTheme.primary)
                .font(.subheadline)
            Text("BKK Atomium")
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Hero Foto

/// A hero image view that displays a local mountain photograph from the asset catalog.
/// Hidden from accessibility as it is purely decorative.
struct MountainHeroView: View {

    /// Renders the local hero image from Assets with gradient overlays and a bottom fade.
    var body: some View {
        ZStack {
            Image("hero-mountain")
                .resizable()
                .scaledToFill()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.08),
                    Color.black.opacity(0.30)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, AppTheme.groupedBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 70)
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }
}

// MARK: - Widget-Modell

/// A value type that describes a single quick-action widget on the home dashboard.
struct HomeWidget {

    /// The widget title displayed below the icon.
    let title: String

    /// A short descriptive subtitle.
    let subtitle: String

    /// The SF Symbols name for the widget icon.
    let icon: String

    /// The tint color applied to the icon and its background circle.
    let color: Color

    /// The navigation destination triggered when the widget is tapped.
    let destination: HomeDestination

    /// The four widgets shown in the dashboard grid.
    static let allWidgets: [HomeWidget] = [
        HomeWidget(
            title: String(localized: "widget_sick_note_title"),
            subtitle: String(localized: "widget_sick_note_subtitle"),
            icon: "doc.text.fill",
            color: Color(red: 0.20, green: 0.60, blue: 0.40),
            destination: .sickNote
        ),
        HomeWidget(
            title: String(localized: "widget_applications_title"),
            subtitle: String(localized: "widget_applications_subtitle"),
            icon: "tray.2.fill",
            color: Color(red: 0.55, green: 0.25, blue: 0.75),
            destination: .applications
        ),
        HomeWidget(
            title: String(localized: "widget_sick_pay_title"),
            subtitle: String(localized: "widget_sick_pay_subtitle"),
            icon: "eurosign.circle.fill",
            color: Color(red: 0.80, green: 0.25, blue: 0.25),
            destination: .sickPay
        ),
        HomeWidget(
            title: String(localized: "widget_health_card_title"),
            subtitle: String(localized: "widget_health_card_subtitle"),
            icon: "creditcard.fill",
            color: Color(red: 0.10, green: 0.45, blue: 0.55),
            destination: .healthCard
        )
    ]
}

// MARK: - Widget-Karte

/// A card view that presents a single `HomeWidget` with its icon, title, and subtitle.
struct HomeWidgetCard: View {
    @Environment(\.colorScheme) private var colorScheme

    /// The widget data to display.
    let widget: HomeWidget

    /// Renders the icon circle, title, and subtitle in a card with a colored border accent.
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            ZStack {
                Circle()
                    .fill(widget.color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: widget.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(widget.color)
            }

            Spacer(minLength: AppTheme.spacingXS)

            Text(widget.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .multilineTextAlignment(.leading)

            Text(widget.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(AppTheme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL))
        .shadow(
            color: colorScheme == .dark ? .black.opacity(0.25) : .black.opacity(0.06),
            radius: 10, x: 0, y: 4
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL)
                .stroke(widget.color.opacity(0.15), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(widget.title): \(widget.subtitle)")
    }
}

// MARK: - List-Row (für Service-Hotline, Hilfe, Suchergebnisse)

/// A styled list row with a colored icon container, title, subtitle, and a chevron indicator.
///
/// Used for service hotlines, help options, and search results on the home screen.
struct HomeListRow: View {
    @Environment(\.colorScheme) private var colorScheme

    /// The SF Symbols name for the leading icon.
    let icon: String

    /// The tint color applied to the icon and its background.
    let iconColor: Color

    /// The primary row label.
    let title: String

    /// The secondary descriptive text shown below the title.
    let subtitle: String

    /// Renders the icon container, text stack, and trailing chevron in a card-styled row.
    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, AppTheme.spacingM - 2)
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
        .shadow(
            color: colorScheme == .dark ? .black.opacity(0.20) : .black.opacity(0.04),
            radius: 8, x: 0, y: 2
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(subtitle)")
    }
}

// MARK: - Searchable Items

/// A value type that makes a home screen item searchable.
///
/// Combines display metadata (title, subtitle, icon, color) with the action to perform
/// when the item is selected from search results.
struct HomeSearchableItem: Identifiable {

    /// A stable random identifier for list diffing.
    let id = UUID()

    /// The item title matched against search queries.
    let title: String

    /// The item subtitle matched against search queries.
    let subtitle: String

    /// The SF Symbols icon name.
    let icon: String

    /// The tint color for the icon.
    let color: Color

    /// The action to trigger when the item is selected from search results.
    let action: HomeSearchAction

    /// All searchable items, derived from the widget grid and static hotline/help entries.
    static var all: [HomeSearchableItem] {
        HomeWidget.allWidgets.map {
            HomeSearchableItem(
                title: $0.title,
                subtitle: $0.subtitle,
                icon: $0.icon,
                color: $0.color,
                action: .navigate($0.destination)
            )
        } + [
            HomeSearchableItem(
                title: String(localized: "home_hotline_doctor_title"),
                subtitle: String(localized: "home_hotline_doctor_subtitle"),
                icon: "phone.fill",
                color: Color(red: 0.20, green: 0.60, blue: 0.40),
                action: .navigate(.doctorHotline)
            ),
            HomeSearchableItem(
                title: String(localized: "home_hotline_medical_title"),
                subtitle: String(localized: "home_hotline_medical_subtitle"),
                icon: "phone.fill",
                color: Color(red: 0.11, green: 0.29, blue: 0.50),
                action: .navigate(.medicalHotline)
            ),
            HomeSearchableItem(
                title: String(localized: "home_help_contact"),
                subtitle: String(localized: "home_help_contact_subtitle"),
                icon: "envelope.fill",
                color: Color(red: 0.55, green: 0.25, blue: 0.75),
                action: .openContact
            ),
            HomeSearchableItem(
                title: String(localized: "home_help_faq"),
                subtitle: String(localized: "home_help_faq_subtitle"),
                icon: "questionmark.circle.fill",
                color: Color(red: 0.10, green: 0.45, blue: 0.55),
                action: .openFAQ
            )
        ]
    }
}
