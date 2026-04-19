import SwiftUI

/// Sick-pay overview — summary card + payment history placeholder.
struct SickPayView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spaceL) {
                summaryCard
                allPaymentsLink
                introText
            }
            .padding(.horizontal, AppTheme.spaceL)
            .padding(.vertical, AppTheme.spaceL)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle(String(localized: "sick_pay_title"))
        .navigationBarTitleDisplayMode(.large)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceM) {
            HStack(spacing: AppTheme.spaceS) {
                Image(systemName: "eurosign.bank.building.fill")
                    .foregroundStyle(.white)
                Text(String(localized: "sick_pay_all_payments_title"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }
            Text("0,00 €")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(String(localized: "sick_pay_all_payments_subtitle"))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(AppTheme.spaceL)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusXL, style: .continuous))
        .shadow(color: AppTheme.primaryDeep.opacity(0.3), radius: 16, x: 0, y: 8)
    }

    private var allPaymentsLink: some View {
        HStack(spacing: AppTheme.spaceM) {
            Image(systemName: "list.bullet.rectangle.portrait.fill")
                .font(.title3)
                .foregroundStyle(AppTheme.primary)
                .frame(width: 44, height: 44)
                .background(AppTheme.peach.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
            VStack(alignment: .leading) {
                Text(String(localized: "sick_pay_all_payments_title"))
                    .font(.subheadline.weight(.semibold))
                Text(String(localized: "sick_pay_all_payments_subtitle"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(AppTheme.spaceM)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .shadow(color: AppTheme.primaryDeep.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    private var introText: some View {
        Text(String(localized: "sick_pay_intro"))
            .font(.callout)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppTheme.spaceS)
    }
}
