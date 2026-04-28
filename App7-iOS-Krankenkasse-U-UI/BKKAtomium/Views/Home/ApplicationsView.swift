import SwiftUI
import SwiftData

/// The applications (benefit requests) tab showing a list of submitted benefit requests.
///
/// Displays all benefit requests grouped by year, with navigation to detail views
/// and the ability to add new requests via a sheet.
struct ApplicationsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = BenefitRequestViewModel()
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.requests.isEmpty {
                    EmptyStateView(
                        icon: "doc.text.fill",
                        title: String(localized: "applications_empty_title"),
                        subtitle: String(localized: "applications_empty_subtitle")
                    )
                } else {
                    List {
                        ForEach(Array(viewModel.groupedByYear.reversed()), id: \.key) { year, requests in
                            Section(header: Text("\(year)")) {
                                ForEach(requests.sorted { $0.submittedDate > $1.submittedDate }) { request in
                                    NavigationLink(value: request) {
                                        ApplicationRow(request: request)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationDestination(for: BenefitRequest.self) { request in
                        BenefitRequestDetailView(request: request)
                    }
                }
            }
            .navigationTitle(String(localized: "applications_title"))
            .navigationBarTitleDisplayMode(.large)
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
                AddBenefitRequestView()
            }
        }
        .task {
            await viewModel.setup(context: modelContext)
        }
    }
}

/// A single row in the applications list showing the request type, status, and date.
private struct ApplicationRow: View {
    let request: BenefitRequest

    var requestType: BenefitRequestType {
        BenefitRequestType(rawValue: request.requestType) ?? .sonstiges
    }

    var status: BenefitRequestStatus {
        BenefitRequestStatus(rawValue: request.status) ?? .eingereicht
    }

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.primary.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: requestType.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(requestType.localizedName)
                    .font(.subheadline.weight(.semibold))
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
                if let amount = request.amount {
                    Text(String(format: "%.2f €", amount))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ApplicationsView()
            .environment(\.modelContext, ModelContext(ModelContainer.preview))
    }
}

// MARK: - Preview Helper

extension ModelContainer {
    static var preview: ModelContainer {
        let schema = Schema([
            InsuredPerson.self, Address.self, PhoneNumber.self,
            BankAccount.self, EmailAddress.self, Invoice.self,
            InsuranceDocument.self, BenefitRequest.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }
}
