import SwiftUI
import SwiftData

/// CRUD for bank accounts.
struct BankAccountListView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = BankAccountViewModel()
    @State private var showForm = false
    @State private var editing: BankAccount?

    var body: some View {
        ZStack {
            AppTheme.canvas.ignoresSafeArea()
            if viewModel.accounts.isEmpty {
                OranoEmptyState(
                    icon: "creditcard",
                    title: String(localized: "bank_empty_title"),
                    subtitle: String(localized: "bank_empty_subtitle")
                )
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.spaceM) {
                        ForEach(viewModel.accounts) { account in
                            BankAccountRowCard(account: account) {
                                editing = account
                                showForm = true
                            } onDelete: {
                                try? viewModel.delete(account)
                            }
                        }
                    }
                    .padding(AppTheme.spaceL)
                }
            }
        }
        .navigationTitle(String(localized: "profile_bank_account"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editing = nil
                    showForm = true
                } label: {
                    Image(systemName: "plus.circle.fill").font(.title3)
                }
            }
        }
        .sheet(isPresented: $showForm) {
            BankAccountFormView(editing: editing) { viewModel.loadAccounts() }
        }
        .task { viewModel.setup(context: modelContext) }
    }
}

private struct BankAccountRowCard: View {
    let account: BankAccount
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var confirmDelete = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceM) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(account.bankName)
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    Text(account.accountHolder)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if account.isPrimary { OranoPrimaryBadge() }
            }

            // Card-looking IBAN panel.
            VStack(alignment: .leading, spacing: AppTheme.spaceS) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .foregroundStyle(.white.opacity(0.85))
                    Spacer()
                    Text("BIC " + account.bic)
                        .font(.caption.monospaced())
                        .foregroundStyle(.white.opacity(0.85))
                }
                Text(account.maskedIBAN)
                    .font(.title3.monospaced())
                    .foregroundStyle(.white)
                    .padding(.top, AppTheme.spaceXS)
            }
            .padding(AppTheme.spaceM)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.actionGradient)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))

            HStack {
                Button(action: onEdit) {
                    Label(String(localized: "common_edit"), systemImage: "pencil")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppTheme.primary)
                }
                Spacer()
                Button(role: .destructive) { confirmDelete = true } label: {
                    Label(String(localized: "common_delete"), systemImage: "trash")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppTheme.danger)
                }
            }
        }
        .padding(AppTheme.spaceM)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .shadow(color: AppTheme.primaryDeep.opacity(0.05), radius: 8, x: 0, y: 3)
        .confirmationDialog(
            String(localized: "bank_delete_confirm"),
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button(String(localized: "common_delete"), role: .destructive, action: onDelete)
            Button(String(localized: "common_cancel"), role: .cancel) { }
        }
    }
}

private struct BankAccountFormView: View {
    let editing: BankAccount?
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = BankAccountViewModel()
    @State private var iban: String = ""
    @State private var bic: String = ""
    @State private var bankName: String = ""
    @State private var accountHolder: String = ""
    @State private var isPrimary: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spaceL) {
                    if let errorMessage {
                        OranoErrorBanner(message: errorMessage) { self.errorMessage = nil }
                    }
                    OranoCard {
                        VStack(spacing: AppTheme.spaceM) {
                            OranoTextField(title: "IBAN", text: $iban, capitalization: .characters)
                            OranoTextField(title: "BIC", text: $bic, capitalization: .characters)
                            OranoTextField(
                                title: String(localized: "field_bank_name"),
                                text: $bankName,
                                placeholder: String(localized: "bank_placeholder_name")
                            )
                            OranoTextField(
                                title: String(localized: "field_account_holder"),
                                text: $accountHolder,
                                placeholder: String(localized: "bank_placeholder_holder")
                            )
                        }
                    }
                    OranoCard {
                        Toggle(isOn: $isPrimary) {
                            Label(String(localized: "common_is_primary"), systemImage: "star.fill")
                        }
                        .tint(AppTheme.primary)
                    }
                }
                .padding(AppTheme.spaceL)
            }
            .background(AppTheme.canvas.ignoresSafeArea())
            .navigationTitle(editing == nil
                             ? String(localized: "bank_add_title")
                             : String(localized: "bank_edit_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "common_cancel")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "common_save"), action: save).bold()
                }
            }
            .task {
                viewModel.setup(context: modelContext)
                if let editing {
                    iban = editing.iban
                    bic = editing.bic
                    bankName = editing.bankName
                    accountHolder = editing.accountHolder
                    isPrimary = editing.isPrimary
                }
            }
        }
    }

    private func save() {
        do {
            if let editing {
                try viewModel.update(editing, iban: iban, bic: bic, bankName: bankName,
                                     accountHolder: accountHolder, isPrimary: isPrimary)
            } else {
                try viewModel.add(iban: iban, bic: bic, bankName: bankName,
                                  accountHolder: accountHolder, isPrimary: isPrimary)
            }
            onSaved()
            dismiss()
        } catch let validationError as ValidationError {
            errorMessage = validationError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
