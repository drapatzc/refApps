import SwiftData
import Observation
import Foundation

@Observable final class InvoiceViewModel {
    var invoices: [Invoice] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var showSuccess: Bool = false
    var selectedCategory: InvoiceCategory? = nil
    var selectedStatus: InvoiceStatus? = nil

    private var repository: InvoiceRepository?
    private var person: InsuredPerson?

    @MainActor
    func setup(context: ModelContext) {
        repository = InvoiceRepository(context: context)
        let descriptor = FetchDescriptor<InsuredPerson>()
        person = try? context.fetch(descriptor).first
        loadInvoices()
    }

    func loadInvoices() {
        guard let person else { return }
        invoices = repository?.fetchFiltered(
            for: person,
            category: selectedCategory,
            status: selectedStatus
        ) ?? []
    }

    func add(
        date: Date,
        amount: Double,
        provider: String,
        category: String,
        status: String,
        description: String?
    ) throws {
        guard let person, let repository else { return }
        try repository.add(
            date: date,
            amount: amount,
            provider: provider,
            category: category,
            status: status,
            description: description,
            to: person
        )
        loadInvoices()
        showSuccess = true
    }

    func delete(_ invoice: Invoice) throws {
        try repository?.delete(invoice)
        loadInvoices()
    }

    var totalPaid: Double {
        invoices.map(\.amount).reduce(0, +)
    }

    var totalRefunded: Double {
        invoices
            .filter { $0.status == InvoiceStatus.erstattet.rawValue }
            .map(\.amount)
            .reduce(0, +)
    }
}
