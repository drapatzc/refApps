import SwiftUI

/// Contact overview — phone, written, address, customer advisor entries.
struct ContactSheetView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spaceL) {
                header
                phoneSection
                writtenSection
                moreSection
            }
            .padding(.vertical, AppTheme.spaceL)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle(String(localized: "contact_title"))
        .navigationBarTitleDisplayMode(.large)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            Text(String(localized: "contact_intro"))
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, AppTheme.spaceL)
    }

    private var phoneSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(title: String(localized: "contact_section_phone"), icon: "phone.fill")
            contactCard(
                icon: "phone.circle.fill",
                title: String(localized: "contact_service_number_title"),
                value: String(localized: "contact_service_number")
            )
        }
    }

    private var writtenSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(title: String(localized: "contact_section_written"), icon: "envelope.fill")
            contactCard(
                icon: "text.bubble.fill",
                title: String(localized: "contact_request_title"),
                value: "kontakt@bkk-orano.de"
            )
            contactCard(
                icon: "building.columns.fill",
                title: String(localized: "contact_address_title"),
                value: String(localized: "contact_address_line1") + "\n" + String(localized: "contact_address_line2")
            )
        }
    }

    private var moreSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(title: String(localized: "contact_section_more"), icon: "ellipsis.circle.fill")
            contactCard(
                icon: "hand.thumbsup.fill",
                title: String(localized: "contact_praise_complaint_title"),
                value: "feedback@bkk-orano.de"
            )
            contactCard(
                icon: "person.crop.circle.badge.questionmark.fill",
                title: String(localized: "contact_advisor_title"),
                value: String(localized: "contact_more_contacts_title")
            )
        }
    }

    private func contactCard(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: AppTheme.spaceM) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppTheme.primary)
                .frame(width: 44, height: 44)
                .background(AppTheme.primarySoft)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.ink)
            }
            Spacer()
        }
        .padding(AppTheme.spaceM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .shadow(color: AppTheme.primaryDeep.opacity(0.05), radius: 8, x: 0, y: 3)
        .padding(.horizontal, AppTheme.spaceL)
    }
}
