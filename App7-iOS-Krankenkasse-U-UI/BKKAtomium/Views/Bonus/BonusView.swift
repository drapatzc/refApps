import SwiftUI
import Charts

// MARK: - Mock Data

struct BonusMeasure: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let category: String
    let points: Int
    let date: Date
    let icon: String
    let color: Color

    init(title: String, category: String = "Sonstiges", points: Int, date: Date, icon: String, color: Color) {
        self.title = title
        self.category = category
        self.points = points
        self.date = date
        self.icon = icon
        self.color = color
    }
}

@Observable
final class BonusProgramViewModel {
    let goalEuro: Double = 200
    var currentEuro: Double = 195
    var year: Int = Calendar.current.component(.year, from: Date())

    var measures: [BonusMeasure] = {
        let cal = Calendar.current
        func ago(_ days: Int) -> Date { cal.date(byAdding: .day, value: -days, to: Date()) ?? Date() }
        return [
            BonusMeasure(title: String(localized: "bonus_measure_checkup"),    category: "Vorsorge",        points: 30, date: ago(14),  icon: "stethoscope",              color: Color(red: 0.20, green: 0.60, blue: 0.40)),
            BonusMeasure(title: String(localized: "bonus_measure_dental"),     category: "Vorsorge",        points: 20, date: ago(45),  icon: "cross.case.fill",          color: Color(red: 0.11, green: 0.29, blue: 0.50)),
            BonusMeasure(title: String(localized: "bonus_measure_sport"),      category: "Sport & Fitness", points: 30, date: ago(90),  icon: "figure.run",               color: Color(red: 0.80, green: 0.55, blue: 0.15)),
            BonusMeasure(title: String(localized: "bonus_measure_gym"),        category: "Sport & Fitness", points: 25, date: ago(120), icon: "dumbbell.fill",            color: Color(red: 0.55, green: 0.25, blue: 0.75)),
            BonusMeasure(title: String(localized: "bonus_measure_vaccination"),category: "Impfung",         points: 20, date: ago(150), icon: "syringe.fill",             color: Color(red: 0.10, green: 0.45, blue: 0.55)),
            BonusMeasure(title: "Ernährungskurs",                              category: "Ernährung",       points: 15, date: ago(180), icon: "leaf.fill",                color: Color(red: 0.95, green: 0.65, blue: 0.10)),
            BonusMeasure(title: "Blutspende",                                  category: "Soziales",        points: 30, date: ago(210), icon: "drop.fill",                color: Color(red: 0.80, green: 0.25, blue: 0.25)),
            BonusMeasure(title: "Stressbewältigungskurs",                      category: "Ernährung",       points: 25, date: ago(250), icon: "brain.head.profile",       color: Color(red: 0.35, green: 0.55, blue: 0.75)),
        ]
    }()

    var completedCount: Int { measures.count }
    var progress: Double { min(currentEuro / goalEuro, 1.0) }

    var formattedCurrent: String { formatEuro(currentEuro) }
    var formattedGoal:    String { formatEuro(goalEuro) }

    /// Aggregierte Kategorie-Aufteilung für das Donut-Diagramm.
    var categoryBreakdown: [(name: String, total: Int, color: Color)] {
        let palette: [String: Color] = [
            "Vorsorge":       Color(red: 0.20, green: 0.60, blue: 0.40),
            "Sport & Fitness":Color(red: 0.11, green: 0.29, blue: 0.50),
            "Impfung":        Color(red: 0.10, green: 0.45, blue: 0.55),
            "Ernährung":      Color(red: 0.95, green: 0.65, blue: 0.10),
            "Soziales":       Color(red: 0.80, green: 0.25, blue: 0.25),
        ]
        var dict: [String: Int] = [:]
        for m in measures { dict[m.category, default: 0] += m.points }
        return dict
            .map { (name: $0.key, total: $0.value, color: palette[$0.key] ?? .secondary) }
            .sorted { $0.total > $1.total }
    }

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
                    categoryChartSection
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
        .sensoryFeedback(.success, trigger: viewModel.completedCount)
        .sensoryFeedback(.impact(weight: .medium), trigger: showAddMeasure) { _, new in new }
        .onAppear {
            withAnimation(AppTheme.animationSmooth) { appeared = true }
        }
    }

    // MARK: - Progress Card

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
        .background(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusXL).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        .padding(.horizontal, AppTheme.spacingM)
    }

    // MARK: - Kategorie-Chart

    private var categoryChartSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text("Aufschlüsselung nach Kategorie")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, AppTheme.spacingM)

            VStack(spacing: AppTheme.spacingM) {
                Chart(viewModel.categoryBreakdown, id: \.name) { item in
                    SectorMark(
                        angle: .value("Punkte", item.total),
                        innerRadius: .ratio(0.56),
                        angularInset: 2.5
                    )
                    .foregroundStyle(item.color)
                    .cornerRadius(5)
                }
                .frame(height: 180)
                .animation(.spring(duration: 0.8, bounce: 0.05), value: appeared)

                // Legende
                VStack(spacing: 6) {
                    ForEach(viewModel.categoryBreakdown, id: \.name) { item in
                        HStack(spacing: AppTheme.spacingS) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(item.color)
                                .frame(width: 12, height: 12)
                            Text(item.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(item.total) €")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.spacingM)
            }
            .padding(AppTheme.spacingM)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
            .padding(.horizontal, AppTheme.spacingM)
        }
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
                        Divider().padding(.leading, 70)
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
            Button { showAddMeasure = true } label: {
                Text(String(localized: "bonus_action_new_measure")).primaryButton()
            }

            Button { showApplyBonus = true } label: {
                Text(String(localized: "bonus_action_request_reward"))
                    .font(.headline)
                    .foregroundStyle(AppTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.spacingM)
                    .background(AppTheme.primary.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
            }

            Button { showEndParticipation = true } label: {
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
                Text(formattedDate + " · " + measure.category)
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
