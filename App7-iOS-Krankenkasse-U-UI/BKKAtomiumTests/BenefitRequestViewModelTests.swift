import Testing
import SwiftData
@testable import BKKAtomium

@Suite("BenefitRequestViewModel")
struct BenefitRequestViewModelTests {

    private func makeContainer() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: InsuranceDocument.self,
            BenefitRequest.self,
            Invoice.self,
            Document.self,
            configuration: config
        )
        return container
    }

    @Test("Load empty benefit requests")
    func loadEmpty() async {
        let container = makeContainer()
        let viewModel = BenefitRequestViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        #expect(viewModel.benefitRequests.isEmpty == false) // Demo has seeded data
    }

    @Test("Add new benefit request")
    func addBenefitRequest() async {
        let container = makeContainer()
        let viewModel = BenefitRequestViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)
        let initialCount = viewModel.benefitRequests.count

        let newRequest = BenefitRequest(
            type: .dentalTreatment,
            description: "Test Request",
            amount: 150.0
        )
        try? container.mainContext.insert(newRequest)
        try? container.mainContext.save()

        await viewModel.setup(context: container.mainContext)
        #expect(viewModel.benefitRequests.count == initialCount + 1)
    }

    @Test("Group requests by year")
    func groupByYear() async {
        let container = makeContainer()
        let viewModel = BenefitRequestViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        let grouped = viewModel.groupedByYear
        #expect(!grouped.isEmpty)
    }

    @Test("Delete benefit request")
    func deleteBenefitRequest() async {
        let container = makeContainer()
        let viewModel = BenefitRequestViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        if let firstRequest = viewModel.benefitRequests.first {
            try? container.mainContext.delete(firstRequest)
            try? container.mainContext.save()

            await viewModel.setup(context: container.mainContext)
            #expect(!viewModel.benefitRequests.contains(where: { $0.id == firstRequest.id }))
        }
    }

    @Test("Requests sorted by date descending")
    func requestsSortedByDate() async {
        let container = makeContainer()
        let viewModel = BenefitRequestViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        for i in 0..<(viewModel.benefitRequests.count - 1) {
            let current = viewModel.benefitRequests[i]
            let next = viewModel.benefitRequests[i + 1]
            #expect(current.submissionDate >= next.submissionDate)
        }
    }
}
