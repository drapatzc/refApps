import SwiftUI

/// Postfach / inbox — redesigned as a Mail-style message list with thread detail.
///
/// UX departure from the reference app: the chat-bubble metaphor is replaced
/// by a tidy preview list (sender, subject, snippet, unread dot, date). Opening
/// a row pushes a detail page with the full content — familiar, calm, and easy
/// to scan when messages accumulate.
struct PostfachView: View {

    enum Filter: String, CaseIterable, Identifiable {
        case all, week, month, year
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all:   return String(localized: "postfach_filter_all")
            case .week:  return String(localized: "postfach_filter_week")
            case .month: return String(localized: "postfach_filter_month")
            case .year:  return String(localized: "postfach_filter_year")
            }
        }
    }

    @State private var messages: [PostMessage] = PostMessage.mock
    @State private var searchText: String = ""
    @State private var filter: Filter = .all
    @State private var showFilter: Bool = false

    private var filteredMessages: [PostMessage] {
        let now = Date()
        let byPeriod = messages.filter { msg in
            switch filter {
            case .all:   return true
            case .week:  return msg.date > now.addingTimeInterval(-60 * 60 * 24 * 7)
            case .month: return msg.date > now.addingTimeInterval(-60 * 60 * 24 * 31)
            case .year:  return msg.date > now.addingTimeInterval(-60 * 60 * 24 * 365)
            }
        }
        guard !searchText.isEmpty else { return byPeriod }
        let needle = searchText.lowercased()
        return byPeriod.filter {
            $0.subject.lowercased().contains(needle) ||
            $0.body.lowercased().contains(needle) ||
            $0.senderLabel.lowercased().contains(needle)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredMessages.isEmpty {
                    OranoEmptyState(
                        icon: "bubble.left.and.bubble.right",
                        title: String(localized: "postfach_empty_title"),
                        subtitle: String(localized: "postfach_empty_subtitle")
                    )
                } else {
                    List {
                        ForEach(filteredMessages) { msg in
                            NavigationLink {
                                PostMessageDetail(message: msg)
                            } label: {
                                messageRow(msg)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(String(localized: "postfach_title"))
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: Text(String(localized: "postfach_search_placeholder"))
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilter = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text(filter.label)
                                .font(.footnote)
                        }
                    }
                }
            }
            .sheet(isPresented: $showFilter) {
                filterSheet
                    .presentationDetents([.fraction(0.4)])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private func messageRow(_ msg: PostMessage) -> some View {
        HStack(alignment: .top, spacing: AppTheme.spaceM) {
            senderAvatar(for: msg)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(msg.senderLabel)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.ink)
                    Spacer()
                    Text(msg.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Text(msg.subject)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text(msg.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    private func senderAvatar(for msg: PostMessage) -> some View {
        ZStack {
            if msg.isFromUser {
                Circle()
                    .fill(AppTheme.primarySoft)
                    .frame(width: 40, height: 40)
            } else {
                Circle()
                    .fill(AppTheme.actionGradient)
                    .frame(width: 40, height: 40)
            }
            Image(systemName: msg.isFromUser ? "person.fill" : "heart.text.square.fill")
                .font(.subheadline)
                .foregroundStyle(msg.isFromUser ? AppTheme.primary : .white)
        }
    }

    // MARK: - Filter sheet

    private var filterSheet: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceM) {
            Text(String(localized: "postfach_filter_title"))
                .font(.title3.weight(.semibold))
            ForEach(Filter.allCases) { option in
                Button {
                    filter = option
                    showFilter = false
                } label: {
                    HStack {
                        Text(option.label)
                            .foregroundStyle(AppTheme.ink)
                        Spacer()
                        if filter == option {
                            Image(systemName: "checkmark")
                                .foregroundStyle(AppTheme.primary)
                        }
                    }
                    .padding(.vertical, 10)
                }
                Divider()
            }
        }
        .padding(AppTheme.spaceL)
    }
}

// MARK: - Detail view

struct PostMessageDetail: View {
    let message: PostMessage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spaceL) {
                VStack(alignment: .leading, spacing: AppTheme.spaceS) {
                    Text(message.subject)
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                        .foregroundStyle(AppTheme.ink)
                    HStack {
                        Text(message.senderLabel)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(AppTheme.primary)
                        Spacer()
                        Text(message.date.formatted(date: .long, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(message.body)
                    .font(.body)
                    .foregroundStyle(AppTheme.ink)
            }
            .padding(AppTheme.spaceL)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Model

struct PostMessage: Identifiable, Hashable {
    let id = UUID()
    let isFromUser: Bool
    let subject: String
    let body: String
    let date: Date

    var senderLabel: String {
        isFromUser
            ? String(localized: "postfach_sender_you")
            : String(localized: "postfach_sender_insurance")
    }

    static var mock: [PostMessage] {
        let now = Date()
        func minus(_ days: Int) -> Date { now.addingTimeInterval(-60 * 60 * 24 * TimeInterval(days)) }
        return [
            .init(isFromUser: false,
                  subject: String(localized: "postfach_msg1_subject"),
                  body: String(localized: "postfach_msg1_body"),
                  date: minus(400)),
            .init(isFromUser: true,
                  subject: String(localized: "postfach_msg2_subject"),
                  body: String(localized: "postfach_msg2_body"),
                  date: minus(398)),
            .init(isFromUser: false,
                  subject: String(localized: "postfach_msg3_subject"),
                  body: String(localized: "postfach_msg3_body"),
                  date: minus(120)),
            .init(isFromUser: true,
                  subject: String(localized: "postfach_msg4_subject"),
                  body: String(localized: "postfach_msg4_body"),
                  date: minus(119)),
            .init(isFromUser: false,
                  subject: String(localized: "postfach_msg5_subject"),
                  body: String(localized: "postfach_msg5_body"),
                  date: minus(118)),
            .init(isFromUser: false,
                  subject: String(localized: "postfach_msg6_subject"),
                  body: String(localized: "postfach_msg6_body"),
                  date: minus(40)),
            .init(isFromUser: true,
                  subject: String(localized: "postfach_msg7_subject"),
                  body: String(localized: "postfach_msg7_body"),
                  date: minus(39)),
            .init(isFromUser: false,
                  subject: String(localized: "postfach_msg8_subject"),
                  body: String(localized: "postfach_msg8_body"),
                  date: minus(14)),
            .init(isFromUser: true,
                  subject: String(localized: "postfach_msg9_subject"),
                  body: String(localized: "postfach_msg9_body"),
                  date: minus(13)),
            .init(isFromUser: false,
                  subject: String(localized: "postfach_msg10_subject"),
                  body: String(localized: "postfach_msg10_body"),
                  date: minus(2))
        ]
        .sorted { $0.date > $1.date }
    }
}
