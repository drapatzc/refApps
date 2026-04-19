import SwiftUI

struct HealthCardView: View {
    @Environment(AppState.self) private var appState

    private let cardColor = Color(red: 0.10, green: 0.45, blue: 0.55)

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingL) {
                digitalCard
                sectionHeader("Informationen")
                infoCards
                Spacer(minLength: AppTheme.spacingXXL)
            }
            .padding(.top, AppTheme.spacingM)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.groupedBackground)
        .navigationTitle(String(localized: "widget_health_card_title"))
        .navigationBarTitleDisplayMode(.large)
    }

    private var digitalCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusXL)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.08, green: 0.35, blue: 0.50),
                            Color(red: 0.05, green: 0.20, blue: 0.38)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 210)

            // Decorative circles
            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 180, height: 180)
                .offset(x: 100, y: -60)
            Circle()
                .fill(.white.opacity(0.04))
                .frame(width: 120, height: 120)
                .offset(x: -80, y: 70)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "cross.circle.fill")
                        .foregroundStyle(.white)
                        .font(.title3)
                    Text("BKK Atomium")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.white.opacity(0.8))
                        .font(.title3)
                }

                Spacer()

                HStack {
                    Image(systemName: "creditcard.fill")
                        .foregroundStyle(.white.opacity(0.6))
                        .font(.system(size: 32))
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("GÜLTIG BIS")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                            .tracking(0.5)
                        Text("12 / 2027")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text(appState.currentUserName)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    Text("A123456789")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
            .padding(AppTheme.spacingL)
        }
        .shadow(color: cardColor.opacity(0.35), radius: 16, x: 0, y: 8)
        .padding(.horizontal, AppTheme.spacingM)
    }

    private var infoCards: some View {
        VStack(spacing: AppTheme.spacingS) {
            infoRow(
                icon: "checkmark.shield.fill",
                color: Color(red: 0.20, green: 0.60, blue: 0.40),
                title: "Status",
                value: "✓ Aktiv versichert"
            )
            infoRow(
                icon: "number.circle.fill",
                color: AppTheme.primary,
                title: "Versichertennummer",
                value: "A123456789"
            )
            infoRow(
                icon: "calendar.circle.fill",
                color: cardColor,
                title: "Gültig bis",
                value: "Dezember 2027"
            )
            infoRow(
                icon: "info.circle.fill",
                color: .gray,
                title: "Hinweis",
                value: "Dies ist eine digitale Darstellung. Die physische Karte bleibt weiterhin gültig."
            )
        }
        .padding(.horizontal, AppTheme.spacingM)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppTheme.spacingM)
    }

    private func infoRow(icon: String, color: Color, title: String, value: String) -> some View {
        HStack(spacing: AppTheme.spacingM) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 20))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.spacingM)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack { HealthCardView() }
        .environment(AppState())
}
