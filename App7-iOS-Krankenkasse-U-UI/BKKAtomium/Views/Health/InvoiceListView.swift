import SwiftUI
import SwiftData

/// View for managing invoices with filtering, sorting, and CRUD operations.
struct InvoiceListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @State private var viewModel = InvoiceViewModel()
    @State private var selectedCategory: InvoiceCategory? = nil
    @State private var selectedStatus: InvoiceStatus? = nil
    @State private var showAddSheet = false

    var filteredInvoices: [Invoice] {
        viewModel.invoices.filter { invoice in
            let categoryMatch = selectedCategory == nil || invoice.category == selectedCategory?.rawValue
            let statusMatch = selectedStatus == nil || invoice.status == selectedStatus?.rawValue
            return categoryMatch && statusMatch
        }
    }

    var body: some View {
        List {
            // Filters
            Section(header: Text("Filter")) {
                Picker("Kategorie", selection: $selectedCategory) {
                    Text("Alle Kategorien").tag(nil as InvoiceCategory?)
                    ForEach(InvoiceCategory.allCases, id: \.self) { category in
                        HStack(spacing: 8) {
                            Image(systemName: category.icon)
                            Text(category.localizedName)
                        }
                        .tag(category as InvoiceCategory?)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedCategory) { viewModel.selectedCategory = selectedCategory; viewModel.loadInvoices() }

                Picker("Status", selection: $selectedStatus) {
                    Text("Alle Status").tag(nil as InvoiceStatus?)
                    ForEach(InvoiceStatus.allCases, id: \.self) { status in
                        HStack(spacing: 8) {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(status.color)
                            Text(status.localizedName)
                        }
                        .tag(status as InvoiceStatus?)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedStatus) { viewModel.selectedStatus = selectedStatus; viewModel.loadInvoices() }
            }

            // Summary
            Section(header: Text("Zusammenfassung")) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Offen")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.2f €", viewModel.invoices.filter { $0.status == InvoiceStatus.offen.rawValue }.map(\.amount).reduce(0, +)))
                            .font(.headline)
                            .foregroundStyle(.orange)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Erstattet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.2f €", viewModel.totalRefunded))
                            .font(.headline)
                            .foregroundStyle(.green)
                    }
                }
            }

            // Invoices List
            if filteredInvoices.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        Text("Keine Rechnungen")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Fügen Sie eine neue Rechnung hinzu, um sie hier anzuzeigen.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.spacingL)
                    .listRowBackground(Color.clear)
                }
            } else {
                Section(header: Text("Rechnungen")) {
                    ForEach(filteredInvoices.sorted { $0.date > $1.date }) { invoice in
                        InvoiceRow(invoice: invoice)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task {
                                        try? viewModel.delete(invoice)
                                    }
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                ShareLink(
                                    item: invoice.provider,
                                    subject: Text("Rechnung"),
                                    message: Text("\(invoice.provider) - \(String(format: "%.2f €", invoice.amount))")
                                ) {
                                    Label("Teilen", systemImage: "square.and.arrow.up")
                                }
                                .tint(.blue)
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Rechnungen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddInvoiceView()
        }
        .task {
            await viewModel.setup(context: modelContext)
        }
    }
}

/// A single invoice row showing category, provider, date, and amount.
private struct InvoiceRow: View {
    let invoice: Invoice

    var category: InvoiceCategory {
        InvoiceCategory(rawValue: invoice.category) ?? .sonstiges
    }

    var status: InvoiceStatus {
        InvoiceStatus(rawValue: invoice.status) ?? .offen
    }

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(category.icon.isEmpty ? Color.gray.opacity(0.2) : Color.clear)
                    .frame(width: 40, height: 40)
                Image(systemName: category.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(invoice.provider)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(invoice.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.2f €", invoice.amount))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(status.localizedName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(status.color)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        InvoiceListView()
            .environment(\.modelContext, ModelContext(ModelContainer.preview))
            .environment(AppState())
    }
}
