import SwiftUI

// MARK: - Message Model

/// A value type representing a single message in the inbox.
struct PostfachMessage: Identifiable, Hashable {

    /// A stable random identifier for list diffing.
    let id = UUID()

    /// The message subject line.
    let subject: String

    /// The full message body text.
    let body: String

    /// The date and time the message was sent or received.
    let date: Date

    /// The originating party of the message.
    let sender: Sender

    /// The two possible senders of an inbox message.
    enum Sender {
        /// A message sent by the insurance company.
        case insurance
        /// A message sent by the insured person.
        case user
    }
}

/// A date-range filter applied to the inbox message list.
enum PostfachDateFilter: String, CaseIterable, Identifiable {

    /// Show all messages regardless of date.
    case all

    /// Show messages from the past seven days.
    case week

    /// Show messages from the past calendar month.
    case month

    /// Show messages from the past calendar year.
    case year

    /// The raw value used as the `Identifiable` identifier.
    var id: String { rawValue }

    /// The localized display name for each filter option.
    var localizedTitle: String {
        switch self {
        case .all: return String(localized: "postfach_filter_all")
        case .week: return String(localized: "postfach_filter_week")
        case .month: return String(localized: "postfach_filter_month")
        case .year: return String(localized: "postfach_filter_year")
        }
    }

    /// Returns `true` when the given date falls within this filter's range.
    ///
    /// - Parameter date: The date to test.
    /// - Returns: `true` if the date matches the filter, `false` otherwise.
    func matches(_ date: Date) -> Bool {
        let now = Date()
        switch self {
        case .all: return true
        case .week:
            return date >= Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            return date >= Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            return date >= Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
        }
    }
}

// MARK: - Mock Data

/// The ordered list of mock inbox messages used by `PostfachView`.
private let mockMessages: [PostfachMessage] = {
    let now = Date()
    let cal = Calendar.current
    func daysAgo(_ d: Int) -> Date { cal.date(byAdding: .day, value: -d, to: now) ?? now }

    return [
        PostfachMessage(
            subject: String(localized: "postfach_msg1_subject"),
            body: String(localized: "postfach_msg1_body"),
            date: daysAgo(400),
            sender: .insurance
        ),
        PostfachMessage(
            subject: String(localized: "postfach_msg2_subject"),
            body: String(localized: "postfach_msg2_body"),
            date: daysAgo(399),
            sender: .user
        ),
        PostfachMessage(
            subject: String(localized: "postfach_msg3_subject"),
            body: String(localized: "postfach_msg3_body"),
            date: daysAgo(120),
            sender: .insurance
        ),
        PostfachMessage(
            subject: String(localized: "postfach_msg4_subject"),
            body: String(localized: "postfach_msg4_body"),
            date: daysAgo(119),
            sender: .user
        ),
        PostfachMessage(
            subject: String(localized: "postfach_msg5_subject"),
            body: String(localized: "postfach_msg5_body"),
            date: daysAgo(118),
            sender: .insurance
        ),
        PostfachMessage(
            subject: String(localized: "postfach_msg6_subject"),
            body: String(localized: "postfach_msg6_body"),
            date: daysAgo(40),
            sender: .insurance
        ),
        PostfachMessage(
            subject: String(localized: "postfach_msg7_subject"),
            body: String(localized: "postfach_msg7_body"),
            date: daysAgo(39),
            sender: .user
        ),
        PostfachMessage(
            subject: String(localized: "postfach_msg8_subject"),
            body: String(localized: "postfach_msg8_body"),
            date: daysAgo(10),
            sender: .insurance
        ),
        PostfachMessage(
            subject: String(localized: "postfach_msg9_subject"),
            body: String(localized: "postfach_msg9_body"),
            date: daysAgo(9),
            sender: .user
        ),
        PostfachMessage(
            subject: String(localized: "postfach_msg10_subject"),
            body: String(localized: "postfach_msg10_body"),
            date: daysAgo(2),
            sender: .insurance
        )
    ]
}()

// MARK: - Postfach View

/// The message inbox (Postfach) tab screen.
///
/// Displays messages as chat-style bubbles, with the insurance company's messages on the left
/// and the user's messages on the right. Supports full-text search and date-range filtering
/// via a bottom sheet.
struct PostfachView: View {

    /// The current search query entered in the search bar.
    @State private var searchText = ""

    /// The active date-range filter applied to the message list.
    @State private var filter: PostfachDateFilter = .all

    /// Controls presentation of the filter bottom sheet.
    @State private var showFilterSheet = false

    /// Messages filtered by the active date range and search query.
    private var filteredMessages: [PostfachMessage] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        return mockMessages.filter { message in
            let matchesDate = filter.matches(message.date)
            let matchesQuery = query.isEmpty ||
                message.subject.lowercased().contains(query) ||
                message.body.lowercased().contains(query)
            return matchesDate && matchesQuery
        }
    }

    /// Renders the navigation stack with the message list or empty state, search bar, and filter toolbar button.
    var body: some View {
        NavigationStack {
            Group {
                if filteredMessages.isEmpty {
                    emptyState
                } else {
                    messagesList
                }
            }
            .background(AppTheme.groupedBackground)
            .navigationTitle(String(localized: "postfach_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        Label(
                            String(localized: "postfach_filter_button"),
                            systemImage: "calendar"
                        )
                    }
                }
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text(String(localized: "postfach_search_placeholder"))
            )
            .sheet(isPresented: $showFilterSheet) {
                PostfachFilterSheet(selected: $filter)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - List

    /// The scrollable lazy stack of `MessageBubbleView` items, auto-scrolled to the last message.
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: AppTheme.spacingM) {
                    ForEach(filteredMessages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, AppTheme.spacingM)
            }
            .onAppear {
                if let last = filteredMessages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Empty State

    /// The centered empty state shown when no messages match the current filter and search query.
    private var emptyState: some View {
        VStack(spacing: AppTheme.spacingM) {
            Image(systemName: "tray")
                .font(.system(size: 52))
                .foregroundStyle(.secondary.opacity(0.5))
            Text(String(localized: "postfach_empty_title"))
                .font(.headline)
            Text(String(localized: "postfach_empty_subtitle"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.spacingL)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Bubble View

/// A chat-style message bubble for a single `PostfachMessage`.
///
/// Insurance messages appear on the left with a neutral background;
/// user messages appear on the right with the primary color background.
private struct MessageBubbleView: View {
    @Environment(\.colorScheme) private var colorScheme

    /// The message to render.
    let message: PostfachMessage

    /// `true` when the message was sent by the insured person.
    private var isUser: Bool { message.sender == .user }

    /// The bubble background color based on sender and color scheme.
    private var bubbleColor: Color {
        isUser ? AppTheme.primary : (colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
    }

    /// The primary text color inside the bubble.
    private var textColor: Color {
        isUser ? .white : .primary
    }

    /// The secondary / timestamp text color inside the bubble.
    private var secondaryTextColor: Color {
        isUser ? .white.opacity(0.75) : .secondary
    }

    /// The localized sender label shown at the top of the bubble.
    private var senderLabel: String {
        isUser
            ? String(localized: "postfach_sender_you")
            : String(localized: "postfach_sender_insurance")
    }

    /// The message date formatted as a medium date with short time.
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: message.date)
    }

    /// Renders the sender avatar, bubble content (sender label, subject, body), and timestamps.
    var body: some View {
        HStack(alignment: .bottom, spacing: AppTheme.spacingS) {
            if isUser { Spacer(minLength: 40) }

            if !isUser {
                senderAvatar
            }

            VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                HStack {
                    Text(senderLabel)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(secondaryTextColor)
                    Spacer()
                    Text(formattedDate)
                        .font(.caption2)
                        .foregroundStyle(secondaryTextColor)
                }

                Text(message.subject)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(textColor)

                Text(message.body)
                    .font(.subheadline)
                    .foregroundStyle(textColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppTheme.spacingM)
            .background(bubbleColor)
            .clipShape(BubbleShape(isUser: isUser))
            .shadow(
                color: colorScheme == .dark ? .clear : .black.opacity(0.06),
                radius: 6, x: 0, y: 2
            )
            .frame(maxWidth: 300, alignment: isUser ? .trailing : .leading)

            if isUser {
                userAvatar
            }

            if !isUser { Spacer(minLength: 40) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(senderLabel). \(message.subject). \(message.body)")
    }

    /// The avatar shown on the left side for insurance messages.
    private var senderAvatar: some View {
        ZStack {
            Circle()
                .fill(AppTheme.primary.opacity(0.15))
                .frame(width: 32, height: 32)
            Image(systemName: "cross.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.primary)
        }
    }

    /// The avatar shown on the right side for user messages.
    private var userAvatar: some View {
        ZStack {
            Circle()
                .fill(AppTheme.accent.opacity(0.15))
                .frame(width: 32, height: 32)
            Image(systemName: "person.fill")
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.accent)
        }
    }
}

// MARK: - Bubble Shape

/// A custom `Shape` that renders a rounded rectangle with a small corner notch indicating the message direction.
///
/// For user messages the notch appears on the bottom-right; for insurance messages on the bottom-left.
private struct BubbleShape: Shape {

    /// When `true`, the tail notch is placed on the right (user) side.
    let isUser: Bool

    /// Builds the bubble path from a rounded rectangle with an additional corner accent rectangle.
    ///
    /// - Parameter rect: The bounding rectangle provided by SwiftUI layout.
    /// - Returns: The completed bubble `Path`.
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16
        let tailSize: CGFloat = 4

        return Path { path in
            path.addRoundedRect(
                in: rect,
                cornerSize: CGSize(width: radius, height: radius),
                style: .continuous
            )

            // Kleiner Eck-Akzent auf der jeweiligen Seite
            if isUser {
                path.addRect(CGRect(
                    x: rect.maxX - tailSize,
                    y: rect.maxY - tailSize,
                    width: tailSize,
                    height: tailSize
                ))
            } else {
                path.addRect(CGRect(
                    x: 0,
                    y: rect.maxY - tailSize,
                    width: tailSize,
                    height: tailSize
                ))
            }
        }
    }
}

// MARK: - Filter Sheet

/// A half-sheet that lets the user select one of the available `PostfachDateFilter` options.
private struct PostfachFilterSheet: View {

    /// A binding to the currently selected filter, updated when the user taps a row.
    @Binding var selected: PostfachDateFilter
    @Environment(\.dismiss) private var dismiss

    /// Renders the filter list with a checkmark on the active option.
    var body: some View {
        NavigationStack {
            List {
                ForEach(PostfachDateFilter.allCases) { option in
                    Button {
                        selected = option
                        dismiss()
                    } label: {
                        HStack {
                            Text(option.localizedTitle)
                                .foregroundStyle(.primary)
                            Spacer()
                            if option == selected {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppTheme.primary)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "postfach_filter_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common_close")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PostfachView()
        .environment(AppState())
}
