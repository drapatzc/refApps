import SwiftUI

struct PregnancyView: View {
    @State private var showContact = false

    private let benefits: [(icon: String, color: Color, title: String, detail: String)] = [
        ("person.fill.badge.plus",         Color(red: 0.95, green: 0.55, blue: 0.65), "Hebammenversorgung",        "Vollständige Übernahme aller Hebammenleistungen"),
        ("stethoscope",                     Color(red: 0.20, green: 0.60, blue: 0.40), "Vorsorgeuntersuchungen",   "Alle gesetzlich vorgeschriebenen Untersuchungen"),
        ("building.2.fill",                 Color(red: 0.11, green: 0.29, blue: 0.50), "Geburtskosten",            "Übernahme der Krankenhaus- und Entbindungskosten"),
        ("figure.walk",                     Color(red: 0.55, green: 0.25, blue: 0.75), "Rückbildungsgymnastik",    "10 Stunden Rückbildungskurs, 100 % Kostenübernahme"),
        ("cross.case.fill",                Color(red: 0.10, green: 0.45, blue: 0.55), "Wochenbettbetreuung",      "Nachsorge durch Hebamme nach der Geburt"),
        ("heart.text.square.fill",         Color(red: 0.95, green: 0.65, blue: 0.10), "Geburtsvorbereitungskurs", "Bis zu 2 Geburtsvorbereitungskurse pro Schwangerschaft")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingL) {
                noActivePregnancyCard

                sectionHeader("Leistungen für werdende Mütter")

                VStack(spacing: AppTheme.spacingS) {
                    ForEach(Array(benefits.enumerated()), id: \.offset) { _, b in
                        BenefitRow(icon: b.icon, color: b.color, title: b.title, detail: b.detail)
                    }
                }
                .padding(.horizontal, AppTheme.spacingM)

                contactBanner

                Spacer(minLength: AppTheme.spacingXXL)
            }
            .padding(.top, AppTheme.spacingM)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.groupedBackground)
        .navigationTitle(String(localized: "health_pregnancy_title"))
        .navigationBarTitleDisplayMode(.large)
    }

    private var noActivePregnancyCard: some View {
        VStack(spacing: AppTheme.spacingM) {
            Image(systemName: "figure.and.child.holdinghands")
                .font(.system(size: 48))
                .foregroundStyle(Color(red: 0.95, green: 0.55, blue: 0.65))
            Text("Keine aktive Schwangerschaft")
                .font(.headline.weight(.bold))
            Text("Derzeit ist keine Schwangerschaft in Ihrer Akte hinterlegt.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacingXL)
        .padding(.horizontal, AppTheme.spacingM)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusXL))
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        .padding(.horizontal, AppTheme.spacingM)
    }

    private var contactBanner: some View {
        VStack(spacing: AppTheme.spacingM) {
            Text("Schwanger?")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
            Text("Melden Sie sich bei uns – wir begleiten Sie durch diese besondere Zeit.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
            Button {
                showContact = true
            } label: {
                Text("Jetzt kontaktieren")
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.95, green: 0.55, blue: 0.65))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.spacingS + 4)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.spacingL)
        .background(
            LinearGradient(
                colors: [Color(red: 0.95, green: 0.55, blue: 0.65), Color(red: 0.80, green: 0.35, blue: 0.55)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusXL))
        .padding(.horizontal, AppTheme.spacingM)
        .sheet(isPresented: $showContact) {
            ContactSheetView()
        }
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
}

private struct BenefitRow: View {
    let icon: String
    let color: Color
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
    NavigationStack { PregnancyView() }
}
