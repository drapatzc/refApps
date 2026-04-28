import SwiftData
import Observation
import Foundation

@Observable final class BenefitRequestViewModel {
    var requests: [BenefitRequest] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var showSuccess: Bool = false

    private var repository: BenefitRequestRepository?
    private var person: InsuredPerson?

    @MainActor
    func setup(context: ModelContext) {
        repository = BenefitRequestRepository(context: context)
        let descriptor = FetchDescriptor<InsuredPerson>()
        person = try? context.fetch(descriptor).first
        loadRequests()
    }

    func loadRequests() {
        guard let person else { return }
        requests = repository?.fetchAll(for: person) ?? []
    }

    func add(
        requestType: String,
        description: String,
        amount: Double?
    ) throws {
        guard let person, let repository else { return }
        try repository.add(
            requestType: requestType,
            description: description,
            amount: amount,
            to: person
        )
        loadRequests()
        showSuccess = true
    }

    func delete(_ request: BenefitRequest) throws {
        try repository?.delete(request)
        loadRequests()
    }

    func updateStatus(_ request: BenefitRequest, status: BenefitRequestStatus) throws {
        try repository?.updateStatus(request, status: status)
        loadRequests()
    }

    var groupedByYear: [(key: Int, value: [BenefitRequest])] {
        let grouped = Dictionary(grouping: requests) { request in
            Calendar.current.component(.year, from: request.submittedDate)
        }
        return grouped.sorted { $0.key > $1.key }
    }
}
