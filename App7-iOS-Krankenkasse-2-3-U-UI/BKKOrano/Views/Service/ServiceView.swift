import SwiftUI

/// Service overview — eGK actions and certificate requests.
///
/// In the new UX this view is presentable both as a standalone detail and as
/// an embedded page; it no longer has its own tab.
struct ServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spaceL) {
                egkSection
                requestSection
            }
            .padding(.vertical, AppTheme.spaceL)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle(String(localized: "service_title"))
        .navigationBarTitleDisplayMode(.large)
    }

    private var egkSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(title: String(localized: "service_section_egk"), icon: "creditcard.fill")
            serviceCard(
                icon: "creditcard",
                title: String(localized: "service_egk_missing_title"),
                subtitle: String(localized: "service_egk_missing_subtitle")
            )
            serviceCard(
                icon: "cross.case.fill",
                title: String(localized: "service_egk_lost_title"),
                subtitle: String(localized: "service_egk_lost_subtitle")
            )
        }
    }

    private var requestSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(title: String(localized: "service_section_request"), icon: "doc.badge.plus")
            serviceCard(
                icon: "doc.badge.plus",
                title: String(localized: "service_request_certificates_title"),
                subtitle: String(localized: "service_request_certificates_subtitle")
            )
        }
    }

    private func serviceCard(icon: String, title: String, subtitle: String) -> some View {
        NavigationLink {
            OranoPlaceholder(icon: icon, title: title)
        } label: {
            HStack(spacing: AppTheme.spaceM) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 52, height: 52)
                    .background(AppTheme.peach.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.ink)
                    Text(subtitle)
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
            .padding(.horizontal, AppTheme.spaceL)
        }
        .buttonStyle(.plain)
    }
}
