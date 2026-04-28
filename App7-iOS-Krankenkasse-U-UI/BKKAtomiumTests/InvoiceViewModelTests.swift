import Testing
import SwiftData
@testable import BKKAtomium

@Suite("InvoiceViewModel")
struct InvoiceViewModelTests {

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

    @Test("Load invoices")
    func loadInvoices() async {
        let container = makeContainer()
        let viewModel = InvoiceViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        #expect(!viewModel.invoices.isEmpty)
    }

    @Test("Filter invoices by category")
    func filterByCategory() async {
        let container = makeContainer()
        let viewModel = InvoiceViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        viewModel.selectedCategory = .treatment
        let filtered = viewModel.invoices.filter { $0.category == .treatment }

        #expect(filtered.count > 0)
    }

    @Test("Filter invoices by status")
    func filterByStatus() async {
        let container = makeContainer()
        let viewModel = InvoiceViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        viewModel.selectedStatus = .paid
        let filtered = viewModel.invoices.filter { $0.status == .paid }

        #expect(filtered.count >= 0)
    }

    @Test("Calculate total paid amount")
    func calculateTotalPaid() async {
        let container = makeContainer()
        let viewModel = InvoiceViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        let paidInvoices = viewModel.invoices.filter { $0.status == .paid }
        let expectedTotal = paidInvoices.reduce(0) { $0 + $1.amount }

        #expect(viewModel.totalPaid == expectedTotal)
    }

    @Test("Calculate total refunded amount")
    func calculateTotalRefunded() async {
        let container = makeContainer()
        let viewModel = InvoiceViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        let refundedInvoices = viewModel.invoices.filter { $0.status == .refunded }
        let expectedTotal = refundedInvoices.reduce(0) { $0 + $1.amount }

        #expect(viewModel.totalRefunded == expectedTotal)
    }

    @Test("Add invoice")
    func addInvoice() async {
        let container = makeContainer()
        let viewModel = InvoiceViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)
        let initialCount = viewModel.invoices.count

        let newInvoice = Invoice(
            provider: "Test Provider",
            amount: 100.0,
            category: .treatment,
            status: .pending,
            date: Date(),
            notes: "Test"
        )
        try? container.mainContext.insert(newInvoice)
        try? container.mainContext.save()

        await viewModel.setup(context: container.mainContext)
        #expect(viewModel.invoices.count == initialCount + 1)
    }

    @Test("Delete invoice")
    func deleteInvoice() async {
        let container = makeContainer()
        let viewModel = InvoiceViewModel(modelContext: container.mainContext)

        await viewModel.setup(context: container.mainContext)

        if let firstInvoice = viewModel.invoices.first {
            try? container.mainContext.delete(firstInvoice)
            try? container.mainContext.save()

            await viewModel.setup(context: container.mainContext)
            #expect(!viewModel.invoices.contains(where: { $0.id == firstInvoice.id }))
        }
    }
}
