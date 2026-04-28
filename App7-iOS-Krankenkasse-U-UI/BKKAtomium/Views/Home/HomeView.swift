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
    /// Switches to a specific tab.
    case switchTab(String)
}

// MARK: - Home View

/// The main home dashboard tab shown after a successful login.
///
/// Displays a hero image, a time-based greeting, a widget grid for quick actions,
/// service hotline links, and help options. A global search bar filters all visible items.
struct HomeView: View {
    @Environment(AppState.self) private var appState

    @State private var showProfile = false
    @State private var headerAppeared = false

    /// Namespace für iOS 18 Zoom-Transitions bei Widget-Karten.
    @Namespace private var zoomNamespace

    /// The current search query entered by the user.
    @State private var searchText = ""

    /// The navigation path for push destinations within this tab.
    @State private var path = NavigationPath()

    /// Controls presentation of the contact sheet.
    @State private var showContactSheet = false

    /// Controls presentation of the FAQ web sheet.
    @State private var showFAQSheet = false

    /// Destination, die nach einer Suche als Sheet geöffnet wird.
    @State private var sheetDestination: HomeDestination? = nil

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

    /// The search results filtered from `HomeSearchableItem.all` matching the current query with fuzzy matching.
    /// Entering "?" shows all available search results.
    private var filteredItems: [HomeSearchableItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return [] }

        // Show all results when user enters "?"
        if query == "?" {
            return HomeSearchableItem.all
        }

        return HomeSearchableItem.all.filter {
            fuzzyMatch(query, against: $0.title.lowercased()) ||
            fuzzyMatch(query, against: $0.subtitle.lowercased())
        }
    }

    /// Performs fuzzy matching between a search term and a target string using Levenshtein distance.
    /// Allows for spelling mistakes and typos.
    ///
    /// Examples:
    /// - "Bonsp" matches "Bonusprogramm" (1 missing char)
    /// - "Krankmeldung" matches "Krankmeldung" (exact)
    /// - "Postfch" matches "Postfach" (1 missing char)
    private func fuzzyMatch(_ query: String, against target: String) -> Bool {
        // Exact substring match (fast path)
        if target.contains(query) {
            return true
        }

        // Levenshtein distance for spell tolerance
        // Allow 1 error per 3 characters (more liberal)
        let maxDistance = max(1, (query.count + 2) / 3)
        let distance = levenshteinDistance(query, target)

        return distance <= maxDistance
    }

    /// Calculates the Levenshtein distance between two strings.
    ///
    /// The Levenshtein distance is the minimum number of single-character edits
    /// (insertions, deletions, or substitutions) required to change one string into another.
    ///
    /// Algorithm: Dynamic Programming with O(m*n) time complexity and O(n) space complexity.
    ///
    /// - Parameters:
    ///   - s1: First string to compare
    ///   - s2: Second string to compare
    /// - Returns: The minimum edit distance between the two strings
    ///
    /// Examples:
    /// - levenshteinDistance("cat", "cats") = 1 (insertion)
    /// - levenshteinDistance("kitten", "sitting") = 3 (substitution x3)
    /// - levenshteinDistance("Bonsp", "Bonusp") = 1 (insertion)
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1 = Array(s1), s2 = Array(s2)
        let (m, n) = (s1.count, s2.count)

        // Base cases
        if m == 0 { return n }
        if n == 0 { return m }

        // Use two rows for space optimization (O(n) instead of O(m*n))
        var prev = Array(0...n)
        var curr = Array(repeating: 0, count: n + 1)

        for i in 1...m {
            curr[0] = i
            for j in 1...n {
                let cost = s1[i - 1] == s2[j - 1] ? 0 : 1
                curr[j] = min(
                    curr[j - 1] + 1,      // insertion
                    prev[j] + 1,          // deletion
                    prev[j - 1] + cost    // substitution
                )
            }
            // Swap rows for next iteration
            (prev, curr) = (curr, prev)
        }
        return prev[n]
    }


    /// Renders the navigation stack with the dashboard, toolbar, and sheets.
    var body: some View {
        NavigationStack(path: $path) {
            dashboardContent
                .scrollDismissesKeyboard(.interactively)
                .background(AppTheme.groupedBackground)
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: String(localized: "home_search_placeholder")
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("BKK Atomium")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            showProfile = true
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .font(.title3)
                                .foregroundStyle(AppTheme.primary)
                        }
                        .sensoryFeedback(.impact(weight: .light), trigger: showProfile) { _, new in new }
                        .accessibilityLabel(String(localized: "home_nav_profile"))
                        .accessibilityIdentifier("profileButton")
                    }
                }
                .navigationDestination(for: HomeDestination.self) { destination in
                    destinationView(for: destination)
                }
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
            // Sheet für Suchergebnis-Navigation
            .sheet(isPresented: Binding(
                get: { sheetDestination != nil },
                set: { if !$0 { sheetDestination = nil } }
            )) {
                if let dest = sheetDestination {
                    NavigationStack {
                        sheetContentView(for: dest)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button { sheetDestination = nil } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                            .font(.title3)
                                    }
                                }
                            }
                    }
                }
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
    // MARK: - Search Results (Inline)

    private var searchResultsContent: some View {
        LazyVStack(spacing: AppTheme.spacingS) {
            if filteredItems.isEmpty {
                VStack(spacing: AppTheme.spacingM) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary.opacity(0.4))
                    Text(String(localized: "home_search_no_results"))
                        .font(.headline)
                    Text(String(localized: "home_search_no_results_subtitle"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, AppTheme.spacingXXL)
                .padding(.horizontal, AppTheme.spacingM)
            } else {
                ForEach(filteredItems) { item in
                    Button {
                        handleSearchAction(item.action)
                    } label: {
                        HomeListRow(
                            icon: item.icon,
                            iconColor: item.color,
                            title: item.title,
                            subtitle: item.subtitle
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.top, AppTheme.spacingM)
        .padding(.bottom, AppTheme.spacingXXL)
    }

    private func handleSearchAction(_ action: HomeSearchAction) {
        withAnimation(AppTheme.animationSnappy) {
            searchText = ""
        }
        switch action {
        case .navigate(let destination):
            sheetDestination = destination
        case .openContact:
            showContactSheet = true
        case .openFAQ:
            showFAQSheet = true
        case .switchTab(let tab):
            appState.selectedTab = tab
        }
    }

    /// Destination-View für Sheet-Präsentation (ohne Zoom-Transition, da modal).
    @ViewBuilder
    private func sheetContentView(for destination: HomeDestination) -> some View {
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

    // MARK: - Dashboard Content

    private var dashboardContent: some View {
        ScrollView {
            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                searchResultsContent
            } else {
                VStack(spacing: 0) {
                // Parallax-Hero: GeometryReader liest Position im ScrollView-CoordinateSpace
                // und versetzt das Bild mit 35% Parallax-Faktor (iOS 17+, kein #available nötig)
                GeometryReader { proxy in
                    let minY = proxy.frame(in: .named("homeScroll")).minY
                    MountainHeroView()
                        .frame(
                            width: proxy.size.width,
                            height: max(220, 220 + minY)
                        )
                        .clipped()
                        .offset(y: minY > 0 ? -minY : minY * 0.35)
                }
                .frame(height: 220)

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
                    .animation(.spring(duration: 0.5, bounce: 0.2).delay(0.1), value: headerAppeared)

                    // Bonusprogramm + Postfach Widgets
                    VStack(spacing: AppTheme.spacingM) {
                        Button {
                            appState.selectedTab = "bonus"
                        } label: {
                            DashboardWidgetRow(
                                icon: "star.fill",
                                iconColor: Color(red: 0.95, green: 0.65, blue: 0.10),
                                title: String(localized: "home_widget_bonus_title"),
                                value: "1.250",
                                subtitle: String(localized: "home_widget_bonus_subtitle")
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            appState.selectedTab = "postfach"
                        } label: {
                            DashboardWidgetRow(
                                icon: "envelope.badge.fill",
                                iconColor: Color(red: 0.55, green: 0.25, blue: 0.75),
                                title: String(localized: "home_widget_postfach_title"),
                                value: "3",
                                subtitle: String(localized: "home_widget_postfach_new_messages")
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, AppTheme.spacingM)

                    // Advertisement Carousel
                    sectionTitle(String(localized: "home_section_advertisements"))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(AdCarouselItem.allItems) { item in
                                Link(destination: item.url) {
                                    AdvertisementCard(item: item)
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .frame(height: 160)

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
                                    // iOS 18: Zoom-Transition vom Widget zur Detail-View
                                    .zoomTransitionSource(id: widget.destination, in: zoomNamespace)
                            }
                            .buttonStyle(.plain)
                            // Long-Press Context Menu mit Schnellaktionen
                            .contextMenu {
                                Button("Öffnen", systemImage: "arrow.right.circle") {
                                    path.append(widget.destination)
                                }
                            }
                            .opacity(headerAppeared ? 1 : 0)
                            .offset(y: headerAppeared ? 0 : 20)
                            .animation(
                                .spring(duration: 0.5, bounce: 0.2)
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
            } // VStack (Dashboard)
            } // else (no search)
        }
        .scrollIndicators(.hidden)
        .coordinateSpace(name: "homeScroll")
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
                .zoomTransitionDestination(id: destination, in: zoomNamespace)
        case .applications:
            ApplicationsView()
                .zoomTransitionDestination(id: destination, in: zoomNamespace)
        case .sickPay:
            SickPayView()
                .zoomTransitionDestination(id: destination, in: zoomNamespace)
        case .healthCard:
            HealthCardView()
                .zoomTransitionDestination(id: destination, in: zoomNamespace)
        case .doctorHotline:
            HotlineView(
                title: String(localized: "home_hotline_doctor_title"),
                number: "116 117",
                description: "Über den ärztlichen Bereitschaftsdienst erhalten Sie schnell einen Arzttermin – auch kurzfristig, wenn Ihre Praxis keinen freien Termin hat.",
                hours: "24 Stunden täglich, 7 Tage die Woche",
                note: "Im lebensbedrohlichen Notfall wählen Sie bitte 112.",
                color: Color(red: 0.20, green: 0.60, blue: 0.40)
            )
            .zoomTransitionDestination(id: destination, in: zoomNamespace)
        case .medicalHotline:
            HotlineView(
                title: String(localized: "home_hotline_medical_title"),
                number: "116 117",
                description: "Kostenlose telefonische Beratung durch medizinisches Fachpersonal – wenn Sie unsicher sind, ob ein Arztbesuch notwendig ist.",
                hours: "Täglich 19:00–8:00 Uhr, am Wochenende und Feiertagen ganztägig",
                note: "Im lebensbedrohlichen Notfall wählen Sie bitte 112.",
                color: Color(red: 0.11, green: 0.29, blue: 0.50)
            )
            .zoomTransitionDestination(id: destination, in: zoomNamespace)
        }
    }
}

// MARK: - Logo

/// The BKK Atomium logo view shown in the navigation bar leading position.
///
/// Displays a cross circle SF Symbol alongside the app name in bold.
struct BKKLogoView: View {

    /// Renders the BKK Atomium logo with health icon and label.
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary)
                    .frame(width: 28, height: 28)

                Image(systemName: "heart.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("BKK")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.primary)
                Text("Atomium")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AppTheme.primary)
            }
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

    /// All searchable items from all tabs and views.
    static var all: [HomeSearchableItem] {
        // Home dashboard widgets
        let homeWidgets = HomeWidget.allWidgets.map {
            HomeSearchableItem(
                title: $0.title,
                subtitle: $0.subtitle,
                icon: $0.icon,
                color: $0.color,
                action: .navigate($0.destination)
            )
        }

        // Home service hotlines & help
        let homeServices = [
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

        // Tab navigation items
        let tabItems = [
            HomeSearchableItem(
                title: String(localized: "tab_bonus"),
                subtitle: String(localized: "bonus_title"),
                icon: "star.fill",
                color: Color(red: 0.95, green: 0.65, blue: 0.10),
                action: .switchTab("bonus")
            ),
            HomeSearchableItem(
                title: String(localized: "tab_postfach"),
                subtitle: String(localized: "postfach_title"),
                icon: "tray.fill",
                color: Color(red: 0.55, green: 0.25, blue: 0.75),
                action: .switchTab("postfach")
            ),
            HomeSearchableItem(
                title: String(localized: "tab_health"),
                subtitle: String(localized: "health_title"),
                icon: "heart.fill",
                color: Color(red: 0.80, green: 0.25, blue: 0.25),
                action: .switchTab("health")
            ),
            HomeSearchableItem(
                title: String(localized: "tab_service"),
                subtitle: String(localized: "service_title"),
                icon: "headphones",
                color: Color(red: 0.20, green: 0.60, blue: 0.40),
                action: .switchTab("service")
            )
        ]

        // Profile/Settings items
        let profileItems = [
            HomeSearchableItem(
                title: String(localized: "profile_settings"),
                subtitle: String(localized: "settings_title"),
                icon: "gear",
                color: AppTheme.primary,
                action: .switchTab("service") // Settings are accessed via Profile button
            ),
            HomeSearchableItem(
                title: String(localized: "profile_insurance_status"),
                subtitle: String(localized: "insurance_status_title"),
                icon: "checkmark.circle.fill",
                color: Color(red: 0.20, green: 0.60, blue: 0.40),
                action: .switchTab("service")
            )
        ]

        return homeWidgets + homeServices + tabItems + profileItems
    }
}

// MARK: - Dashboard Widget Row

/// A styled widget row for dashboard items like Bonusprogramm and Postfach.
struct DashboardWidgetRow: View {
    @Environment(\.colorScheme) private var colorScheme

    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
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

            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(iconColor)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, AppTheme.spacingM)
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
        .shadow(
            color: colorScheme == .dark ? .black.opacity(0.20) : .black.opacity(0.04),
            radius: 8, x: 0, y: 2
        )
    }
}

// MARK: - Advertisement Carousel

/// A value type that describes an advertisement carousel item.
struct AdCarouselItem: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let url: URL

    /// Sample advertisement items for the carousel.
    static let allItems: [AdCarouselItem] = [
        AdCarouselItem(
            title: String(localized: "ad_health_tips_title"),
            imageName: "ad-health-tips",
            url: URL(string: "https://christiandrapatz.de/de/")!
        ),
        AdCarouselItem(
            title: String(localized: "ad_wellness_programs_title"),
            imageName: "ad-wellness",
            url: URL(string: "https://xcodex.betterlocale.com")!
        ),
        AdCarouselItem(
            title: String(localized: "ad_dental_care_title"),
            imageName: "ad-dental",
            url: URL(string: "https://betterlocale.com/de-home/")!
        ),
        AdCarouselItem(
            title: String(localized: "ad_mental_health_title"),
            imageName: "ad-mental-health",
            url: URL(string: "https://atomiumgames.com")!
        )
    ]
}

/// A card view for advertisement carousel items.
struct AdvertisementCard: View {
    let item: AdCarouselItem

    private var gradientStart: Color {
        switch item.imageName {
        case "ad-health-tips": return Color(red: 0.95, green: 0.45, blue: 0.30)
        case "ad-wellness": return Color(red: 0.35, green: 0.75, blue: 0.55)
        case "ad-dental": return Color(red: 1.0, green: 0.85, blue: 0.40)
        case "ad-mental-health": return Color(red: 0.80, green: 0.60, blue: 1.0)
        default: return AppTheme.primary
        }
    }

    private var gradientEnd: Color {
        switch item.imageName {
        case "ad-health-tips": return Color(red: 0.80, green: 0.25, blue: 0.25)
        case "ad-wellness": return Color(red: 0.20, green: 0.60, blue: 0.40)
        case "ad-dental": return Color(red: 0.95, green: 0.65, blue: 0.10)
        case "ad-mental-health": return Color(red: 0.55, green: 0.25, blue: 0.75)
        default: return AppTheme.primary
        }
    }

    private var icon: String {
        switch item.imageName {
        case "ad-health-tips": return "stethoscope"
        case "ad-wellness": return "figure.stairs"
        case "ad-dental": return "mouth"
        case "ad-mental-health": return "brain.head.profile"
        default: return "heart.fill"
        }
    }

    var body: some View {
        ZStack {
            // Background Image
            Image(item.imageName)
                .resizable()
                .scaledToFill()

            // Dark overlay - full coverage for text readability
            LinearGradient(
                colors: [.black.opacity(0.2), .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Title at bottom (centered and padded)
            VStack(alignment: .center) {
                Spacer()
                Text(item.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.spacingXS)
                    .padding(.bottom, AppTheme.spacingS)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
            }
        }
        .frame(width: 160, height: 160)
        .clipped()
    }
}

// MARK: - Search Sheet

/// A sheet view for searching across all home items.
struct HomeSearchSheet: View {
    @Binding var searchText: String
    @Binding var path: NavigationPath
    @Binding var showContactSheet: Bool
    @Binding var showFAQSheet: Bool
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @FocusState private var searchFocused: Bool

    private var filteredItems: [HomeSearchableItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return [] }

        if query == "?" {
            return HomeSearchableItem.all
        }

        return HomeSearchableItem.all.filter {
            fuzzyMatch(query, against: $0.title.lowercased()) ||
            fuzzyMatch(query, against: $0.subtitle.lowercased())
        }
    }

    private func fuzzyMatch(_ query: String, against target: String) -> Bool {
        if target.contains(query) {
            return true
        }
        let maxDistance = max(1, (query.count + 2) / 3)
        let distance = levenshteinDistance(query, target)
        return distance <= maxDistance
    }

    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1 = Array(s1), s2 = Array(s2)
        let (m, n) = (s1.count, s2.count)

        if m == 0 { return n }
        if n == 0 { return m }

        var prev = Array(0...n)
        var curr = Array(repeating: 0, count: n + 1)

        for i in 1...m {
            curr[0] = i
            for j in 1...n {
                let cost = s1[i - 1] == s2[j - 1] ? 0 : 1
                curr[j] = min(
                    curr[j - 1] + 1,
                    prev[j] + 1,
                    prev[j - 1] + cost
                )
            }
            (prev, curr) = (curr, prev)
        }
        return prev[n]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: AppTheme.spacingM) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField(String(localized: "home_search_placeholder"), text: $searchText)
                        .focused($searchFocused)
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(AppTheme.spacingM)
                .background(Color(.secondarySystemBackground))

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
                            }
                        }
                        .padding(.horizontal, AppTheme.spacingM)
                        .padding(.top, AppTheme.spacingM)
                    }
                }

                Spacer(minLength: 0)
            }
            .background(AppTheme.groupedBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common_cancel")) {
                        searchText = ""
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            searchFocused = true
        }
    }

    private func triggerSearchAction(_ action: HomeSearchAction) {
        searchText = ""
        dismiss()

        switch action {
        case .navigate(let destination):
            path.append(destination)
        case .openContact:
            showContactSheet = true
        case .openFAQ:
            showFAQSheet = true
        case .switchTab(let tabName):
            appState.selectedTab = tabName
        }
    }
}
