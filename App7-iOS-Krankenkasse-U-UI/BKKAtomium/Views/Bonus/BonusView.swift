import SwiftUI

// MARK: - Mock Data

struct BonusMeasure: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let points: Int
    let date: Date
    let icon: String
    let color: Color
}

@Observable
final class BonusProgramViewModel {
    let goalEuro: Double = 200
    var currentEuro: Double = 90
    var year: Int = Calendar.current.component(.year, from: Date())

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

    var completedCount: Int { measures.count }
    var progress: Double { min(currentEuro / goalEuro, 1.0) }

    var formattedCurrent: String { formatEuro(currentEuro) }
    var formattedGoal: String { formatEuro(goalEuro) }

    private func formatEuro(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value)) €"
    }
}

// MARK: - Bonus View

struct BonusView: View {
    @State private var viewModel = BonusProgramViewModel()
    @State private var appeared = false
    @State private var showAddMeasure = false
    @State private var showApplyBonus = false
    @State private var showEndParticipation = false

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
        // Haptic: Maßnahme erfolgreich hinzugefügt
        .sensoryFeedback(.success, trigger: viewModel.completedCount)
        // Haptic: Sheet öffnet sich
        .sensoryFeedback(.impact(weight: .medium), trigger: showAddMeasure) { _, new in new }
        .onAppear {
            withAnimation(AppTheme.animationSmooth) {
                appeared = true
            }
        }
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        VStack(spacing: AppTheme.spacingM) {
            // Kreisförmiger Fortschrittsring
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
                    .animation(.spring(duration: 1.0, bounce: 0.08), value: appeared)

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

            // Linearer Gauge als sekundäre Fortschrittsanzeige
            Gauge(value: viewModel.progress) {
                EmptyView()
            } currentValueLabel: {
                Text(viewModel.formattedCurrent)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.primary)
            } minimumValueLabel: {
                Text("0 €").font(.caption2).foregroundStyle(.secondary)
            } maximumValueLabel: {
                Text(viewModel.formattedGoal).font(.caption2).foregroundStyle(.secondary)
            }
            .gaugeStyle(.linearCapacity)
            .tint(AppTheme.accent)
            .animation(.smooth(duration: 1.2), value: viewModel.progress)
            .padding(.horizontal, AppTheme.spacingL)

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

private struct StatCard: View {
    let icon: String
    let color: Color
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
                    // Symbol bounced bei jedem Wert-Wechsel (z.B. neue Maßnahme)
                    .symbolEffect(.bounce, value: value)
            }
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
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

private struct MeasureRow: View {
    let measure: BonusMeasure

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: measure.date)
    }

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
