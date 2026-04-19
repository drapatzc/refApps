import SwiftUI
import SwiftData

/// Shows the insured person's personal and statutory data.
struct InsuranceStatusView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spaceL) {
                heroCard
                personalSection
                insuranceSection
                hint
            }
            .padding(.vertical, AppTheme.spaceL)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle(String(localized: "insurance_status_title"))
        .navigationBarTitleDisplayMode(.large)
        .task {
            viewModel.loadPerson(context: modelContext)
        }
    }

    // MARK: - Hero

    private var heroCard: some View {
        HStack(spacing: AppTheme.spaceL) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 72, height: 72)
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "insurance_status_valid"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                if let person = viewModel.person {
                    Text(person.fullName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("Nr. " + person.insuranceNumber)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            Spacer()
        }
        .padding(AppTheme.spaceL)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusXL, style: .continuous))
        .shadow(color: AppTheme.primaryDeep.opacity(0.3), radius: 14, x: 0, y: 6)
        .padding(.horizontal, AppTheme.spaceL)
    }

    // MARK: - Sections

    private var personalSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(
                title: String(localized: "insurance_section_personal"),
                icon: "person.fill"
            )
            VStack(spacing: 0) {
                if let person = viewModel.person {
                    OranoInfoRow(title: String(localized: "insurance_field_name"),
                                 value: person.fullName, icon: "person.fill")
                        .padding(.horizontal, AppTheme.spaceM)
                    Divider().padding(.leading, AppTheme.spaceXL)
                    OranoInfoRow(title: String(localized: "insurance_field_birth"),
                                 value: person.birthDate.formatted(date: .long, time: .omitted),
                                 icon: "calendar")
                        .padding(.horizontal, AppTheme.spaceM)
                }
            }
            .padding(.vertical, AppTheme.spaceS)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
            .shadow(color: AppTheme.primaryDeep.opacity(0.05), radius: 8, x: 0, y: 3)
            .padding(.horizontal, AppTheme.spaceL)
        }
    }

    private var insuranceSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(
                title: String(localized: "insurance_section_insurance"),
                icon: "shield.lefthalf.filled"
            )
            VStack(spacing: 0) {
                if let person = viewModel.person {
                    OranoInfoRow(title: String(localized: "insurance_field_number"),
                                 value: person.insuranceNumber, icon: "number")
                        .padding(.horizontal, AppTheme.spaceM)
                    Divider().padding(.leading, AppTheme.spaceXL)
                    OranoInfoRow(title: String(localized: "insurance_field_pension"),
                                 value: person.pensionInsuranceNumber, icon: "clock.fill")
                        .padding(.horizontal, AppTheme.spaceM)
                    Divider().padding(.leading, AppTheme.spaceXL)
                    OranoInfoRow(title: String(localized: "insurance_field_tax_id"),
                                 value: person.taxId, icon: "doc.text.fill")
                        .padding(.horizontal, AppTheme.spaceM)
                }
            }
            .padding(.vertical, AppTheme.spaceS)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
            .shadow(color: AppTheme.primaryDeep.opacity(0.05), radius: 8, x: 0, y: 3)
            .padding(.horizontal, AppTheme.spaceL)
        }
    }

    private var hint: some View {
        HStack(alignment: .top, spacing: AppTheme.spaceS) {
            Image(systemName: "lock.fill")
                .foregroundStyle(AppTheme.primary)
            Text(String(localized: "insurance_status_hint"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(AppTheme.spaceM)
        .background(AppTheme.primarySoft)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
        .padding(.horizontal, AppTheme.spaceL)
    }
}
