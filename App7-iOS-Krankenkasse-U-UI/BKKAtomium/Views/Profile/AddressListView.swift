import SwiftUI

/// A list screen that displays all addresses for the insured person.
///
/// Supports adding new addresses via a sheet, editing existing ones by tapping
/// or using swipe actions, and deleting via a confirmation alert.
struct AddressListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AddressViewModel()
    @State private var showAddForm = false
    @State private var editAddress: Address? = nil
    @State private var deleteAddress: Address? = nil

    /// Renders an empty state or a list of `AddressRowView` items with swipe actions.
    var body: some View {
        Group {
            if viewModel.addresses.isEmpty {
                EmptyStateView(
                    icon: "house",
                    title: String(localized: "address_empty_title"),
                    subtitle: String(localized: "address_empty_subtitle")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.groupedBackground)
            } else {
                List {
                    ForEach(viewModel.addresses) { address in
                        AddressRowView(address: address)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteAddress = address
                                } label: {
                                    Label(String(localized: "common_delete"), systemImage: "trash")
                                }
                                Button {
                                    editAddress = address
                                } label: {
                                    Label(String(localized: "common_edit"), systemImage: "pencil")
                                }
                                .tint(AppTheme.primary)
                            }
                            .onTapGesture {
                                editAddress = address
                            }
                    }
                }
            }
        }
        .navigationTitle(String(localized: "profile_address"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddForm = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(String(localized: "address_add"))
            }
        }
        .sheet(isPresented: $showAddForm, onDismiss: { viewModel.loadAddresses() }) {
            AddressFormView(mode: .add, viewModel: viewModel)
        }
        .sheet(item: $editAddress, onDismiss: { viewModel.loadAddresses() }) { address in
            AddressFormView(mode: .edit(address), viewModel: viewModel)
        }
        .alert(String(localized: "common_delete_confirm_title"), isPresented: Binding(
            get: { deleteAddress != nil },
            set: { if !$0 { deleteAddress = nil } }
        )) {
            Button(String(localized: "common_delete"), role: .destructive) {
                if let addr = deleteAddress {
                    try? viewModel.delete(addr)
                    deleteAddress = nil
                }
            }
            Button(String(localized: "common_cancel"), role: .cancel) {
                deleteAddress = nil
            }
        } message: {
            Text(String(localized: "address_delete_confirm"))
        }
        .onAppear {
            viewModel.setup(context: modelContext)
        }
    }
}

/// A single row in the address list showing type, street/number, postal code/city, and
/// optionally the country and a primary badge.
struct AddressRowView: View {

    /// The address to display.
    let address: Address

    /// Renders the address type, street, city line, country (if not Germany), and primary badge.
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
            HStack {
                Text(address.addressType)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.primary)

                Spacer()

                if address.isPrimary {
                    PrimaryBadge()
                }
            }

            Text("\(address.street) \(address.houseNumber)")
                .font(.subheadline.weight(.medium))

            Text("\(address.postalCode) \(address.city)")
                .font(.caption)
                .foregroundStyle(.secondary)

            if address.country != "Deutschland" {
                Text(address.country)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, AppTheme.spacingXS)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(address.addressType): \(address.singleLineAddress)")
    }
}
