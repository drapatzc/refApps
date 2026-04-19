import SwiftUI

/// Bonus program screen — radial progress, stat highlights, measures list.
///
/// Design differs from the reference: the progress ring is replaced by a
/// horizontal stats strip plus a ring-gauge side-card, so data is readable
/// in one glance without any overlap with the toolbar.
struct BonusView: View {

    @State private var viewModel = BonusProgramViewModel()
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spaceL) {
                heroCard
                statsRow
                measuresSection
                actionsSection
            }
            .padding(.vertical, AppTheme.spaceL)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle(String(localized: "bonus_title"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.85)) {
                appeared = true
            }
        }
    }

    // MARK: - Hero card

    private var heroCard: some View {
        HStack(spacing: AppTheme.spaceL) {
            progressRing
                .frame(width: 132, height: 132)

            VStack(alignment: .leading, spacing: AppTheme.spaceS) {
                Text(String(localized: "bonus_current_points"))
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))
                Text(viewModel.formattedCurrent)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(String(format: String(localized: "bonus_goal_label"), viewModel.formattedGoal))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                Text(String(format: String(localized: "bonus_year_label"), viewModel.year))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
        }
        .padding(AppTheme.spaceL)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusXL, style: .continuous))
        .shadow(color: AppTheme.primaryDeep.opacity(0.3), radius: 16, x: 0, y: 8)
        .padding(.horizontal, AppTheme.spaceL)
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.25), lineWidth: 10)
            Circle()
                .trim(from: 0, to: appeared ? CGFloat(viewModel.progress) : 0)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text("\(Int(viewModel.progress * 100)) %")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                Text(String(localized: "bonus_measures_completed"))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
    }

    // MARK: - Stats row

    private var statsRow: some View {
        HStack(spacing: AppTheme.spaceM) {
            statCard(
                title: String(localized: "bonus_measures_completed"),
                value: "\(viewModel.completedCount)",
                icon: "checkmark.circle.fill"
            )
            statCard(
                title: String(localized: "bonus_current_points"),
                value: viewModel.formattedCurrent,
                icon: "eurosign.circle.fill"
            )
        }
        .padding(.horizontal, AppTheme.spaceL)
    }

    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.primary)
                Spacer()
            }
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(AppTheme.ink)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(AppTheme.spaceM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .shadow(color: AppTheme.primaryDeep.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    // MARK: - Measures section

    private var measuresSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(
                title: String(localized: "bonus_measures_list_title"),
                icon: "list.star"
            )
            VStack(spacing: 0) {
                ForEach(Array(viewModel.measures.enumerated()), id: \.element.id) { index, measure in
                    measureRow(measure)
                    if index < viewModel.measures.count - 1 {
                        Divider().padding(.leading, 72)
                    }
                }
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
            .shadow(color: AppTheme.primaryDeep.opacity(0.05), radius: 8, x: 0, y: 3)
            .padding(.horizontal, AppTheme.spaceL)
        }
    }

    private func measureRow(_ measure: BonusMeasure) -> some View {
        HStack(spacing: AppTheme.spaceM) {
            Image(systemName: measure.icon)
                .font(.title3)
                .foregroundStyle(AppTheme.primary)
                .frame(width: 44, height: 44)
                .background(AppTheme.peach.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusS, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: String.LocalizationValue(measure.titleKey)))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                Text(measure.date.formatted(date: .long, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("+" + viewModel.formatEuro(measure.euroAmount))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.success)
        }
        .padding(.horizontal, AppTheme.spaceM)
        .padding(.vertical, 14)
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: AppTheme.spaceS) {
            Button { } label: {
                Text(String(localized: "bonus_action_new_measure"))
            }
            .oranoPrimaryButton()

            Button { } label: {
                Text(String(localized: "bonus_action_request_reward"))
            }
            .oranoSecondaryButton()

            Button { } label: {
                Text(String(localized: "bonus_action_end_participation"))
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
            .padding(.top, AppTheme.spaceS)
        }
        .padding(.horizontal, AppTheme.spaceL)
    }
}

#Preview {
    NavigationStack {
        BonusView()
    }
}
