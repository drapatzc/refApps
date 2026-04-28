import SwiftUI
import SwiftData

/// Detail view for a benefit request showing status timeline and full information.
struct BenefitRequestDetailView: View {
    @Environment(AppState.self) private var appState
    let request: BenefitRequest

    var requestType: BenefitRequestType {
        BenefitRequestType(rawValue: request.requestType) ?? .sonstiges
    }

    var status: BenefitRequestStatus {
        BenefitRequestStatus(rawValue: request.status) ?? .eingereicht
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingL) {
                // Header
                VStack(spacing: AppTheme.spacingM) {
                    HStack(spacing: AppTheme.spacingM) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primary.opacity(0.15))
                                .frame(width: 50, height: 50)
                            Image(systemName: requestType.icon)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(AppTheme.primary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(requestType.localizedName)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text(request.submittedDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(status.localizedName)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(status.color)
                        }
                        .padding(.horizontal, AppTheme.spacingM)
                        .padding(.vertical, AppTheme.spacingS)
                        .background(status.color.opacity(0.15))
                        .cornerRadius(6)
                    }
                    .padding(AppTheme.spacingM)
                    .background(AppTheme.primary.opacity(0.05))
                    .cornerRadius(AppTheme.cornerRadiusL)
                }

                VStack(spacing: AppTheme.spacingL) {
                    // Status Timeline
                    VStack(spacing: 12) {
                        Text("Bearbeitungsverlauf")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        StatusTimelineView(status: status)
                    }
                    .padding(AppTheme.spacingM)
                    .background(AppTheme.sectionBackground)
                    .cornerRadius(AppTheme.cornerRadiusL)

                    // Details
                    VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                        Group {
                            if let amount = request.amount {
                                InfoRowView(label: "Betrag", value: String(format: "%.2f €", amount))
                            }

                            InfoRowView(label: "Eingereicht", value: request.submittedDate.formatted(date: .abbreviated, time: .shortened))

                            if let processedDate = request.processedDate {
                                InfoRowView(label: "Bearbeitet", value: processedDate.formatted(date: .abbreviated, time: .shortened))
                            }
                        }
                    }
                    .padding(AppTheme.spacingM)
                    .background(AppTheme.sectionBackground)
                    .cornerRadius(AppTheme.cornerRadiusL)

                    // Description
                    VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                        Text("Beschreibung")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)

                        Text(request.requestDescription)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(AppTheme.spacingM)
                    .background(AppTheme.sectionBackground)
                    .cornerRadius(AppTheme.cornerRadiusL)

                    // Export Button
                    ShareLink(
                        item: "Antrag: \(requestType.localizedName)",
                        subject: Text("Leistungsantrag"),
                        message: Text(request.requestDescription)
                    ) {
                        Label("Teilen", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .primaryButton()
                    }
                }
                .padding(AppTheme.spacingM)
            }
            .padding(AppTheme.spacingM)
        }
        .navigationTitle(requestType.localizedName)
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.groupedBackground)
    }
}

/// A visual timeline showing the status progression of a benefit request.
private struct StatusTimelineView: View {
    let status: BenefitRequestStatus

    private let allSteps: [BenefitRequestStatus] = [
        .eingereicht,
        .inBearbeitung,
        .genehmigt
    ]

    var body: some View {
        VStack(spacing: 16) {
            ForEach(Array(allSteps.enumerated()), id: \.offset) { index, step in
                HStack(spacing: AppTheme.spacingM) {
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(isStepCompleted(step) ? step.color : Color.gray.opacity(0.3))
                                .frame(width: 32, height: 32)

                            if isStepCompleted(step) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }

                        if index < allSteps.count - 1 {
                            Rectangle()
                                .fill(isStepCompleted(step) ? step.color : Color.gray.opacity(0.3))
                                .frame(width: 2, height: 20)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.localizedName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(isStepCompleted(step) ? .primary : .secondary)

                        if isStepCompleted(step) && step == status {
                            Text("Aktueller Status")
                                .font(.caption)
                                .foregroundStyle(step.color)
                        }
                    }

                    Spacer()
                }
            }
        }
    }

    private func isStepCompleted(_ step: BenefitRequestStatus) -> Bool {
        switch status {
        case .eingereicht:
            return step == .eingereicht
        case .inBearbeitung:
            return step == .eingereicht || step == .inBearbeitung
        case .genehmigt, .abgelehnt:
            return true
        }
    }
}

#Preview {
    let calendar = Calendar.current
    let request = BenefitRequest(
        requestType: BenefitRequestType.kostenerstattung.rawValue,
        status: BenefitRequestStatus.genehmigt.rawValue,
        submittedDate: calendar.date(from: DateComponents(year: 2026, month: 2, day: 1))!,
        processedDate: calendar.date(from: DateComponents(year: 2026, month: 2, day: 15))!,
        amount: 85.50,
        requestDescription: "Kostenerstattung für Zahnarztbehandlung durchführen"
    )

    NavigationStack {
        BenefitRequestDetailView(request: request)
            .environment(AppState())
    }
}
