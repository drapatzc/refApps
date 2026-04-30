import SwiftData
import Foundation

final class BenefitRequestRepository: BenefitRequestRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll(for person: InsuredPerson) -> [BenefitRequest] {
        person.benefitRequests.sorted { $0.submittedDate > $1.submittedDate }
    }

    func add(
        requestType: String,
        description: String,
        amount: Double?,
        to person: InsuredPerson
    ) throws {
        let errors = BenefitRequestValidator.validate(description: description)
        guard errors.isEmpty else { throw errors.first! }

        let request = BenefitRequest(
            requestType: requestType,
            status: BenefitRequestStatus.eingereicht.rawValue,
            submittedDate: Date(),
            amount: amount,
            requestDescription: description
        )
        person.benefitRequests.append(request)
        try context.save()

        NotificationService.shared.scheduleLocalNotification(
            id: "benefit_\(request.id.uuidString)",
            title: String(localized: "notification_benefit_submitted_title"),
            body: String(format: String(localized: "notification_benefit_submitted_body"),
                         BenefitRequestType(rawValue: requestType)?.localizedName ?? requestType),
            delay: 2
        )
    }

    func updateStatus(_ request: BenefitRequest, status: BenefitRequestStatus) throws {
        request.status = status.rawValue
        if status == .genehmigt || status == .abgelehnt {
            request.processedDate = Date()
        }
        try context.save()

        NotificationService.shared.scheduleLocalNotification(
            id: "benefit_status_\(request.id.uuidString)_\(Date().timeIntervalSince1970)",
            title: String(localized: "notification_benefit_status_title"),
            body: String(format: String(localized: "notification_benefit_status_body"),
                         status.localizedName),
            delay: 1
        )
    }

    func delete(_ request: BenefitRequest) throws {
        context.delete(request)
        try context.save()
    }
}
