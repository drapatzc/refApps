import SwiftUI

/// Placeholder list of submitted applications — styled as a clean timeline.
struct ApplicationsView: View {

    private let sampleApplications: [SampleApplication] = [
        SampleApplication(title: "Kostenerstattung Brille", date: Date().addingTimeInterval(-86_400 * 5), status: .inReview),
        SampleApplication(title: "Haushaltshilfe", date: Date().addingTimeInterval(-86_400 * 18), status: .approved),
        SampleApplication(title: "Kinderkrankengeld", date: Date().addingTimeInterval(-86_400 * 42), status: .approved)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spaceL) {
                introCard

                VStack(spacing: AppTheme.spaceM) {
                    ForEach(sampleApplications) { app in
                        applicationRow(app)
                    }
                }
                .padding(.horizontal, AppTheme.spaceL)
            }
            .padding(.vertical, AppTheme.spaceL)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle(String(localized: "applications_title"))
        .navigationBarTitleDisplayMode(.large)
    }

    private var introCard: some View {
        HStack(alignment: .top, spacing: AppTheme.spaceM) {
            Image(systemName: "tray.full.fill")
                .font(.title)
                .foregroundStyle(AppTheme.primary)
                .padding(AppTheme.spaceM)
                .background(AppTheme.peach.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
            Text(String(localized: "applications_intro"))
                .font(.callout)
                .foregroundStyle(AppTheme.ink)
        }
        .padding(AppTheme.spaceM)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .shadow(color: AppTheme.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
        .padding(.horizontal, AppTheme.spaceL)
    }

    private func applicationRow(_ app: SampleApplication) -> some View {
        HStack(alignment: .top, spacing: AppTheme.spaceM) {
            VStack(spacing: 4) {
                Circle()
                    .fill(app.status.tint)
                    .frame(width: 12, height: 12)
                Rectangle()
                    .fill(AppTheme.peach.opacity(0.8))
                    .frame(width: 2)
            }
            .frame(width: 12)
            VStack(alignment: .leading, spacing: 4) {
                Text(app.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Text(app.date.formatted(date: .long, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                OranoChip(text: app.status.label, icon: app.status.icon, filled: false)
                    .padding(.top, 4)
            }
            Spacer()
        }
        .padding(AppTheme.spaceM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .shadow(color: AppTheme.primaryDeep.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

private struct SampleApplication: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let status: Status

    enum Status {
        case inReview, approved, rejected

        var label: String {
            switch self {
            case .inReview: return "In Prüfung"
            case .approved: return "Bewilligt"
            case .rejected: return "Abgelehnt"
            }
        }
        var icon: String {
            switch self {
            case .inReview: return "hourglass"
            case .approved: return "checkmark.seal.fill"
            case .rejected: return "xmark.seal.fill"
            }
        }
        var tint: Color {
            switch self {
            case .inReview: return AppTheme.accent
            case .approved: return AppTheme.success
            case .rejected: return AppTheme.danger
            }
        }
    }
}
