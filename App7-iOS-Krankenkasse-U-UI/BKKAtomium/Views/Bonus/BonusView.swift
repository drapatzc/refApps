import SwiftUI

// MARK: - Mock Data

/// A value type representing a single completed bonus programme measure.
struct BonusMeasure: Identifiable, Hashable {

    /// A stable random identifier for list diffing.
    let id = UUID()

    /// The display name of the health measure (e.g. "Check-up 35").
    let title: String

    /// The monetary bonus credited for completing the measure, in Euro cents.
    let points: Int

    /// The date on which the measure was completed.
    let date: Date

    /// The SF Symbols icon name representing the measure type.
    let icon: String

    /// The tint color used for the measure icon and badge.
    let color: Color
}

/// The observable view model powering the bonus programme screen.
///
/// Holds the current bonus balance, yearly goal, and the list of completed measures.
/// All currency formatting is performed in-memory using `NumberFormatter`.
@Observable
final class BonusProgramViewModel {

    /// The total monetary goal for the current year in Euro.
    let goalEuro: Double = 200

    /// The amount already credited towards the yearly goal in Euro.
    var currentEuro: Double = 90

    /// The calendar year for which the bonus balance is displayed.
    var year: Int = Calendar.current.component(.year, from: Date())

    /// The list of completed health measures contributing to the bonus balance.
    var measures: [BonusMeasure] = [
        BonusMeasure(
            title: String(localized: "bonus_measure_checkup"),
            points: 30,
            date: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
            icon: "stethoscope",
            color: Color(red: 0.20, green: 0.60, blue: 0.40)
        ),
        BonusMeasure(
            title: String(localized: "bonus_measure_dental"),
            points: 30,
            date: Calendar.current.date(byAdding: .day, value: -45, to: Date()) ?? Date(),
            icon: "cross.case.fill",
            color: Color(red: 0.11, green: 0.29, blue: 0.50)
        ),
        BonusMeasure(
            title: String(localized: "bonus_measure_sport"),
            points: 30,
            date: Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date(),
            icon: "figure.run",
            color: Color(red: 0.80, green: 0.55, blue: 0.15)
        )
    ]

    /// The total number of completed measures.
    var completedCount: Int { measures.count }

    /// The progress as a fraction between 0 and 1 relative to `goalEuro`.
    var progress: Double { min(currentEuro / goalEuro, 1.0) }

    /// The current balance formatted as a locale-sensitive Euro currency string.
    var formattedCurrent: String {
        formatEuro(currentEuro)
    }

    /// The yearly goal formatted as a locale-sensitive Euro currency string.
    var formattedGoal: String {
        formatEuro(goalEuro)
    }

    /// Returns a locale-sensitive Euro-formatted string for the given value.
    ///
    /// - Parameter value: The value to format.
    /// - Returns: A currency-formatted string, e.g. `"90 €"`.
    private func formatEuro(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value)) €"
    }
}

// MARK: - Bonus View

/// The bonus programme tab screen.
///
/// Displays a circular progress ring, a stats row, the list of completed measures,
/// and action buttons for adding new measures, requesting a reward payout, or ending participation.
struct BonusView: View {
    @State private var viewModel = BonusProgramViewModel()

    /// `true` after the view appears, used to animate the progress ring and content entrance.
    @State private var appeared = false
    @State private var showAddMeasure = false
    @State private var showApplyBonus = false
    @State private var showEndParticipation = false

    /// Renders the navigation stack with the scrollable bonus content.
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingL) {
                    progressCard

                    statsRow

                    measuresList

                    actionButtons

                    Text(String(localized: "bonus_info_hint"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.spacingL)
                        .padding(.bottom, AppTheme.spacingXL)
                }
                .padding(.top, AppTheme.spacingM)
            }
            .scrollIndicators(.hidden)
            .background(AppTheme.groupedBackground)
            .navigationTitle(String(localized: "bonus_title"))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddMeasure) {
                AddMeasureView { newMeasure in
                    viewModel.measures.insert(newMeasure, at: 0)
                    viewModel.currentEuro += Double(newMeasure.points)
                }
            }
            .sheet(isPresented: $showApplyBonus) {
                ApplyBonusView(currentPoints: viewModel.currentEuro)
            }
            .confirmationDialog("Teilnahme beenden", isPresented: $showEndParticipation, titleVisibility: .visible) {
                Button("Teilnahme beenden", role: .destructive) {}
                Button(String(localized: "common_cancel"), role: .cancel) {}
            } message: {
                Text("Möchten Sie Ihre Teilnahme am Bonusprogramm wirklich beenden? Gesammelte Punkte verfallen.")
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }

    // MARK: - Progress Card

    /// The animated circular progress ring card showing current balance vs. goal.
    private var progressCard: some View {
        VStack(spacing: AppTheme.spacingM) {
            ZStack {
                Circle()
                    .stroke(AppTheme.primary.opacity(0.12), lineWidth: 14)

                Circle()
                    .trim(from: 0, to: appeared ? viewModel.progress : 0)
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color(red: 0.20, green: 0.60, blue: 0.40),
                                Color(red: 0.10, green: 0.38, blue: 0.24),
                                Color(red: 0.95, green: 0.65, blue: 0.10),
                                Color(red: 0.20, green: 0.60, blue: 0.40)
                            ],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.9), value: appeared)

                VStack(spacing: AppTheme.spacingXS) {
                    Text(String(localized: "bonus_current_points"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    Text(viewModel.formattedCurrent)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primary)
                        .contentTransition(.numericText())

                    Text(String(format: String(localized: "bonus_goal_label"), viewModel.formattedGoal))
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 220, height: 220)
            .padding(.top, AppTheme.spacingS)

            Text(String(format: String(localized: "bonus_year_label"), viewModel.year))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.primary)
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, AppTheme.spacingXS)
                .background(AppTheme.primary.opacity(0.10))
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacingL)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusXL)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        .padding(.horizontal, AppTheme.spacingM)
    }

    // MARK: - Stats Row

    /// A horizontal row of two `StatCard` views showing completed measure count and current balance.
    private var statsRow: some View {
        HStack(spacing: AppTheme.spacingM) {
            StatCard(
                icon: "checkmark.seal.fill",
                color: Color(red: 0.20, green: 0.60, blue: 0.40),
                value: "\(viewModel.completedCount)",
                label: String(localized: "bonus_measures_completed")
            )
            StatCard(
                icon: "star.fill",
                color: Color(red: 0.95, green: 0.65, blue: 0.10),
                value: viewModel.formattedCurrent,
                label: String(localized: "bonus_current_points")
            )
        }
        .padding(.horizontal, AppTheme.spacingM)
    }

    // MARK: - Measures List

    /// The vertical list of completed health measures, rendered inside a card background.
    private var measuresList: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text(String(localized: "bonus_measures_list_title"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, AppTheme.spacingM)

            VStack(spacing: 1) {
                ForEach(viewModel.measures) { measure in
                    MeasureRow(measure: measure)
                    if measure.id != viewModel.measures.last?.id {
                        Divider()
                            .padding(.leading, 70)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL))
            .padding(.horizontal, AppTheme.spacingM)
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - Action Buttons

    /// The three action buttons: add measure, request reward payout, and end participation.
    private var actionButtons: some View {
        VStack(spacing: AppTheme.spacingS) {
            Button {
                showAddMeasure = true
            } label: {
                Text(String(localized: "bonus_action_new_measure"))
                    .primaryButton()
            }

            Button {
                showApplyBonus = true
            } label: {
                HStack {
                    Text(String(localized: "bonus_action_request_reward"))
                }
                .font(.headline)
                .foregroundStyle(AppTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacingM)
                .background(AppTheme.primary.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
            }

            Button {
                showEndParticipation = true
            } label: {
                Text(String(localized: "bonus_action_end_participation"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, AppTheme.spacingS)
            }
        }
        .padding(.horizontal, AppTheme.spacingM)
    }
}

// MARK: - Stat Card

/// A small card displaying a single statistic with an icon, value, and label.
private struct StatCard: View {

    /// The SF Symbols icon name.
    let icon: String

    /// The tint color for the icon and its background circle.
    let color: Color

    /// The primary value string (e.g. a count or currency amount).
    let value: String

    /// The caption label describing the statistic.
    let label: String

    /// Renders the icon circle, value, and label in a left-aligned vertical stack.
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.spacingM)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Measure Row

/// A single row in the completed measures list showing the measure icon, title, date, and bonus amount.
private struct MeasureRow: View {

    /// The measure to display.
    let measure: BonusMeasure

    /// The completion date formatted as a medium-style date string.
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: measure.date)
    }

    /// Renders the icon, title, date, and bonus amount in a horizontal layout.
    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(measure.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: measure.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(measure.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(measure.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("+\(measure.points) €")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color(red: 0.20, green: 0.60, blue: 0.40))
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, AppTheme.spacingS + 2)
    }
}

#Preview {
    BonusView()
        .environment(AppState())
}
