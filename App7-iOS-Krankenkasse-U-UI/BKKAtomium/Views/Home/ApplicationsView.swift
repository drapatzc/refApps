import SwiftUI

// MARK: - Model

/// A value type representing a single submitted application entry.
struct ApplicationEntry: Identifiable, Hashable {

    /// A stable random identifier for list diffing.
    let id = UUID()

    /// The sequential number of this application within its year.
    let number: Int

    /// The date and time the application was submitted.
    let date: Date
}

// MARK: - Mock Data

/// In-memory mock data source for the applications screen.
private enum ApplicationsMock {

    /// The years for which mock entries are available, shown as list sections.
    static let years: [Int] = [2026, 2025, 2024]

    /// Mock application entries grouped by year.
    static let entries: [Int: [ApplicationEntry]] = [
        2024: [
            ApplicationEntry(number: 1, date: makeDate(year: 2024, month: 3,  day: 14, hour: 9,  minute: 30)),
            ApplicationEntry(number: 2, date: makeDate(year: 2024, month: 7,  day: 2,  hour: 14, minute: 15)),
            ApplicationEntry(number: 3, date: makeDate(year: 2024, month: 11, day: 20, hour: 16, minute: 45))
        ],
        2025: [
            ApplicationEntry(number: 1, date: makeDate(year: 2025, month: 2,  day: 8,  hour: 11, minute: 0)),
            ApplicationEntry(number: 2, date: makeDate(year: 2025, month: 5,  day: 17, hour: 13, minute: 20)),
            ApplicationEntry(number: 3, date: makeDate(year: 2025, month: 10, day: 3,  hour: 15, minute: 50))
        ],
        2026: [
            ApplicationEntry(number: 1, date: makeDate(year: 2026, month: 1,  day: 12, hour: 10, minute: 5)),
            ApplicationEntry(number: 2, date: makeDate(year: 2026, month: 2,  day: 28, hour: 9,  minute: 40)),
            ApplicationEntry(number: 3, date: makeDate(year: 2026, month: 4,  day: 5,  hour: 17, minute: 10))
        ]
    ]

    /// Creates a `Date` from individual calendar components using the current calendar.
    ///
    /// - Parameters:
    ///   - year: The calendar year.
    ///   - month: The calendar month (1–12).
    ///   - day: The day of the month.
    ///   - hour: The hour of the day (0–23).
    ///   - minute: The minute (0–59).
    /// - Returns: The constructed `Date`, or `Date()` if the components are invalid.
    private static func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}

// MARK: - Applications View

/// A list screen that shows all submitted applications grouped by year.
///
/// Each row navigates to a placeholder "in development" screen. Data is provided
/// by `ApplicationsMock`.
struct ApplicationsView: View {

    /// Renders the introductory text and year-grouped list of application entries.
    var body: some View {
        List {
            Section {
                Text(String(localized: "applications_intro"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: AppTheme.spacingM,
                                              leading: AppTheme.spacingM,
                                              bottom: AppTheme.spacingM,
                                              trailing: AppTheme.spacingM))
            }

            ForEach(ApplicationsMock.years, id: \.self) { year in
                Section(header: Text(String(year))) {
                    ForEach(ApplicationsMock.entries[year] ?? []) { entry in
                        NavigationLink {
                            PlaceholderView(
                                title: String(localized: "placeholder_in_development_title"),
                                icon: "hammer.fill"
                            )
                        } label: {
                            ApplicationRow(entry: entry)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.groupedBackground)
        .navigationTitle(String(localized: "applications_title"))
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Row

/// A single row in the applications list showing the entry icon, title, and submission date.
private struct ApplicationRow: View {

    /// The application entry to display.
    let entry: ApplicationEntry

    /// The formatted application title using the entry number.
    private var title: String {
        String(format: String(localized: "applications_entry_format"), entry.number)
    }

    /// The formatted submission date and time string.
    private var dateText: String {
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: entry.date)
    }

    /// Renders the icon container, title, and date in a horizontal stack.
    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.55, green: 0.25, blue: 0.75).opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(red: 0.55, green: 0.25, blue: 0.75))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(dateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(dateText)")
    }
}

#Preview {
    NavigationStack {
        ApplicationsView()
    }
}
