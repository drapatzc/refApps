import SwiftUI
import SwiftData

/// Address CRUD — card list with swipe-to-delete and a floating add button.
struct AddressListView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AddressViewModel()
    @State private var showForm = false
    @State private var editingAddress: Address?

    var body: some View {
        ZStack {
            AppTheme.canvas.ignoresSafeArea()

            if viewModel.addresses.isEmpty {
                OranoEmptyState(
                    icon: "house.fill",
                    title: String(localized: "address_empty_title"),
                    subtitle: String(localized: "address_empty_subtitle")
                )
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.spaceM) {
                        ForEach(viewModel.addresses) { address in
                            AddressRowCard(address: address) {
                                editingAddress = address
                                showForm = true
                            } onDelete: {
                                try? viewModel.delete(address)
                            }
                        }
                    }
                    .padding(AppTheme.spaceL)
                }
            }
        }
        .navigationTitle(String(localized: "profile_address"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editingAddress = nil
                    showForm = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .accessibilityIdentifier("add_address_button")
            }
        }
        .sheet(isPresented: $showForm) {
            AddressFormView(editing: editingAddress) {
                viewModel.loadAddresses()
            }
        }
        .task {
            viewModel.setup(context: modelContext)
        }
    }
}

private struct AddressRowCard: View {
    let address: Address
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var confirmDelete = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            HStack(alignment: .top) {
                Image(systemName: AddressType(rawValue: address.addressType)?.icon ?? "house.fill")
                    .font(.title3)
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.peach.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(AddressType(rawValue: address.addressType)?.localizedName ?? address.addressType)
                        .font(.caption)
                        .foregroundStyle(AppTheme.primary)
                    Text(address.singleLineAddress)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.ink)
                    Text(address.country)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if address.isPrimary { OranoPrimaryBadge() }
            }

            HStack {
                Button(action: onEdit) {
                    Label(String(localized: "common_edit"), systemImage: "pencil")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppTheme.primary)
                }
                Spacer()
                Button(role: .destructive) {
                    confirmDelete = true
                } label: {
                    Label(String(localized: "common_delete"), systemImage: "trash")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppTheme.danger)
                }
            }
            .padding(.top, AppTheme.spaceXS)
        }
        .padding(AppTheme.spaceM)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .shadow(color: AppTheme.primaryDeep.opacity(0.05), radius: 8, x: 0, y: 3)
        .confirmationDialog(
            String(localized: "address_delete_confirm"),
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button(String(localized: "common_delete"), role: .destructive, action: onDelete)
            Button(String(localized: "common_cancel"), role: .cancel) { }
        }
    }
}
