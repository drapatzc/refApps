import SwiftData
import Foundation

final class InvoiceRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll(for person: InsuredPerson) -> [Invoice] {
        person.invoices.sorted { $0.date > $1.date }
    }

    func fetchFiltered(
        for person: InsuredPerson,
        category: InvoiceCategory? = nil,
        status: InvoiceStatus? = nil
    ) -> [Invoice] {
        fetchAll(for: person).filter { invoice in
            (category == nil || invoice.category == category?.rawValue) &&
            (status == nil || invoice.status == status?.rawValue)
        }
    }

    func add(
        date: Date,
        amount: Double,
        provider: String,
        category: String,
        status: String,
        description: String?,
        to person: InsuredPerson
    ) throws {
        let errors = InvoiceValidator.validate(date: date, amount: amount, provider: provider)
        guard errors.isEmpty else { throw errors.first! }

        let invoice = Invoice(
            date: date,
            amount: amount,
            provider: provider,
            category: category,
            status: status,
            invoiceDescription: description
        )
        person.invoices.append(invoice)
        try context.save()
    }

    func delete(_ invoice: Invoice) throws {
        context.delete(invoice)
        try context.save()
    }
}
