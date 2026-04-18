import SwiftUI

/// A list screen that displays all bank accounts for the insured person.
///
/// Supports adding new accounts via a sheet, editing existing ones by tapping
/// or using swipe actions, and deleting via a confirmation alert.
struct BankAccountListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = BankAccountViewModel()

    /// Controls presentation of the add-account form sheet.
    @State private var showAddForm = false

    /// The account currently being edited; non-nil while the edit sheet is presented.
    @State private var editAccount: BankAccount? = nil

    /// The account pending deletion; non-nil while the confirmation alert is shown.
    @State private var deleteAccount: BankAccount? = nil

    /// Renders an empty state or a list of `BankAccountRowView` items with swipe actions.
    var body: some View {
        Group {
            if viewModel.accounts.isEmpty {
                EmptyStateView(
                    icon: "banknote",
                    title: String(localized: "bank_empty_title"),
                    subtitle: String(localized: "bank_empty_subtitle")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.groupedBackground)
            } else {
                List {
                    ForEach(viewModel.accounts) { account in
                        BankAccountRowView(account: account)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) { deleteAccount = account } label: {
                                    Label(String(localized: "common_delete"), systemImage: "trash")
                                }
                                Button { editAccount = account } label: {
                                    Label(String(localized: "common_edit"), systemImage: "pencil")
                                }
                                .tint(AppTheme.primary)
                            }
                            .onTapGesture { editAccount = account }
                    }
                }
            }
        }
        .navigationTitle(String(localized: "profile_bank_account"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAddForm = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAddForm, onDismiss: { viewModel.loadAccounts() }) {
            BankAccountFormView(mode: .add, viewModel: viewModel)
        }
        .sheet(item: $editAccount, onDismiss: { viewModel.loadAccounts() }) { account in
            BankAccountFormView(mode: .edit(account), viewModel: viewModel)
        }
        .alert(String(localized: "common_delete_confirm_title"), isPresented: Binding(
            get: { deleteAccount != nil },
            set: { if !$0 { deleteAccount = nil } }
        )) {
            Button(String(localized: "common_delete"), role: .destructive) {
                if let a = deleteAccount { try? viewModel.delete(a); deleteAccount = nil }
            }
            Button(String(localized: "common_cancel"), role: .cancel) { deleteAccount = nil }
        } message: {
            Text(String(localized: "bank_delete_confirm"))
        }
        .onAppear { viewModel.setup(context: modelContext) }
    }
}

/// A single row in the bank account list showing the bank name, masked IBAN, account holder, and primary badge.
struct BankAccountRowView: View {

    /// The bank account to display.
    let account: BankAccount

    /// Renders the bank name, formatted IBAN, account holder, and an optional primary badge.
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(account.bankName)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if account.isPrimary { PrimaryBadge() }
            }

            Text(account.formattedIBAN)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(.secondary)

            Text(account.accountHolder)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, AppTheme.spacingXS)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(account.bankName), IBAN: \(account.maskedIBAN), \(account.accountHolder)")
    }
}

/// A form sheet for adding or editing a bank account.
///
/// `BankAccountFormView` uses a `Mode` enum to differentiate between an add flow
/// (empty fields) and an edit flow (fields pre-populated from the existing record).
struct BankAccountFormView: View {

    /// The two supported form modes.
    enum Mode {
        /// Adding a new bank account from scratch.
        case add
        /// Editing the given existing bank account.
        case edit(BankAccount)
    }

    /// The current form mode.
    let mode: Mode

    /// The view model that handles persistence.
    @Bindable var viewModel: BankAccountViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var iban = ""
    @State private var bic = ""
    @State private var bankName = ""
    @State private var accountHolder = ""
    @State private var isPrimary = false
    @State private var errorMessage: String? = nil

    /// `true` when the form is in edit mode.
    private var isEditing: Bool {
        if case .edit = mode { return true }; return false
    }

    /// Renders the form with sections for IBAN/BIC, account details, and the save button.
    var body: some View {
        NavigationStack {
            Form {
                if let error = errorMessage {
                    Section {
                        ErrorBannerView(message: error) { errorMessage = nil }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                }

                Section("IBAN & BIC") {
                    AppTextField(
                        label: "IBAN",
                        text: $iban,
                        placeholder: "DE89 3704 0044 0532 0130 00",
                        keyboardType: .asciiCapable,
                        autocapitalization: .characters
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    AppTextField(
                        label: "BIC",
                        text: $bic,
                        placeholder: "COBADEFFXXX",
                        keyboardType: .asciiCapable,
                        autocapitalization: .characters
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section(String(localized: "bank_section_details")) {
                    AppTextField(
                        label: String(localized: "field_bank_name"),
                        text: $bankName,
                        placeholder: String(localized: "bank_placeholder_name")
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    AppTextField(
                        label: String(localized: "field_account_holder"),
                        text: $accountHolder,
                        placeholder: String(localized: "bank_placeholder_holder")
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    Toggle(String(localized: "common_is_primary"), isOn: $isPrimary)
                }

                Section {
                    Button { save() } label: {
                        HStack {
                            Spacer()
                            Text(isEditing ? String(localized: "common_save") : String(localized: "common_add"))
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .primaryButton()
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                }
            }
            .navigationTitle(isEditing ? String(localized: "bank_edit_title") : String(localized: "bank_add_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common_cancel")) { dismiss() }
                }
            }
            .onAppear {
                if case .edit(let a) = mode {
                    iban = a.formattedIBAN; bic = a.bic
                    bankName = a.bankName; accountHolder = a.accountHolder; isPrimary = a.isPrimary
                }
            }
        }
    }

    /// Attempts to save the form data by calling the appropriate view model method.
    ///
    /// Dismisses the sheet on success. Displays a validation or generic error banner on failure.
    private func save() {
        errorMessage = nil
        do {
            switch mode {
            case .add:
                try viewModel.add(iban: iban, bic: bic, bankName: bankName, accountHolder: accountHolder, isPrimary: isPrimary)
            case .edit(let a):
                try viewModel.update(a, iban: iban, bic: bic, bankName: bankName, accountHolder: accountHolder, isPrimary: isPrimary)
            }
            dismiss()
        } catch let e as ValidationError {
            errorMessage = e.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
