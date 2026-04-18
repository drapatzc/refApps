import SwiftUI

/// A list screen that displays all email addresses for the insured person.
///
/// Supports adding new addresses via a sheet, editing existing ones by tapping
/// or using swipe actions, and deleting via a confirmation alert.
struct EmailListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = EmailViewModel()

    /// Controls presentation of the add-email form sheet.
    @State private var showAddForm = false

    /// The email address currently being edited; non-nil while the edit sheet is presented.
    @State private var editEmail: EmailAddress? = nil

    /// The email address pending deletion; non-nil while the confirmation alert is shown.
    @State private var deleteEmail: EmailAddress? = nil

    /// Renders an empty state or a list of `EmailRowView` items with swipe actions.
    var body: some View {
        Group {
            if viewModel.emails.isEmpty {
                EmptyStateView(
                    icon: "envelope",
                    title: String(localized: "email_empty_title"),
                    subtitle: String(localized: "email_empty_subtitle")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.groupedBackground)
            } else {
                List {
                    ForEach(viewModel.emails) { email in
                        EmailRowView(email: email)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) { deleteEmail = email } label: {
                                    Label(String(localized: "common_delete"), systemImage: "trash")
                                }
                                Button { editEmail = email } label: {
                                    Label(String(localized: "common_edit"), systemImage: "pencil")
                                }
                                .tint(AppTheme.primary)
                            }
                            .onTapGesture { editEmail = email }
                    }
                }
            }
        }
        .navigationTitle(String(localized: "profile_email"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAddForm = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAddForm, onDismiss: { viewModel.loadEmails() }) {
            EmailFormView(mode: .add, viewModel: viewModel)
        }
        .sheet(item: $editEmail, onDismiss: { viewModel.loadEmails() }) { email in
            EmailFormView(mode: .edit(email), viewModel: viewModel)
        }
        .alert(String(localized: "common_delete_confirm_title"), isPresented: Binding(
            get: { deleteEmail != nil },
            set: { if !$0 { deleteEmail = nil } }
        )) {
            Button(String(localized: "common_delete"), role: .destructive) {
                if let e = deleteEmail { try? viewModel.delete(e); deleteEmail = nil }
            }
            Button(String(localized: "common_cancel"), role: .cancel) { deleteEmail = nil }
        } message: {
            Text(String(localized: "email_delete_confirm"))
        }
        .onAppear { viewModel.setup(context: modelContext) }
    }
}

/// A single row in the email list showing the type icon, address, type label, and primary badge.
struct EmailRowView: View {

    /// The email address to display.
    let email: EmailAddress

    /// The SF Symbols icon name for the email type, falling back to `"envelope.fill"`.
    private var typeIcon: String {
        EmailType(rawValue: email.emailType)?.icon ?? "envelope.fill"
    }

    /// Renders the type icon, email address, type label, and an optional primary badge.
    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            Image(systemName: typeIcon)
                .font(.subheadline)
                .foregroundStyle(AppTheme.primary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(email.email)
                    .font(.subheadline.weight(.medium))

                Text(EmailType(rawValue: email.emailType)?.localizedName ?? email.emailType)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            if email.isPrimary { PrimaryBadge() }
        }
        .padding(.vertical, AppTheme.spacingXS)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(email.emailType): \(email.email)")
    }
}

/// A form sheet for adding or editing an email address.
///
/// `EmailFormView` uses a `Mode` enum to differentiate between an add flow
/// (empty fields) and an edit flow (fields pre-populated from the existing record).
struct EmailFormView: View {

    /// The two supported form modes.
    enum Mode {
        /// Adding a new email address from scratch.
        case add
        /// Editing the given existing email address.
        case edit(EmailAddress)
    }

    /// The current form mode.
    let mode: Mode

    /// The view model that handles persistence.
    @Bindable var viewModel: EmailViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var emailType = EmailType.personal.rawValue
    @State private var isPrimary = false
    @State private var errorMessage: String? = nil

    /// `true` when the form is in edit mode.
    private var isEditing: Bool {
        if case .edit = mode { return true }; return false
    }

    /// Renders the form with sections for the email address, type, and the save button.
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

                Section(String(localized: "email_section_address")) {
                    AppTextField(
                        label: String(localized: "field_email"),
                        text: $email,
                        placeholder: "name@beispiel.de",
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section(String(localized: "email_section_type")) {
                    Picker(String(localized: "email_type"), selection: $emailType) {
                        ForEach(EmailType.allCases, id: \.rawValue) { t in
                            Label(t.localizedName, systemImage: t.icon).tag(t.rawValue)
                        }
                    }

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
            .navigationTitle(isEditing ? String(localized: "email_edit_title") : String(localized: "email_add_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common_cancel")) { dismiss() }
                }
            }
            .onAppear {
                if case .edit(let e) = mode {
                    email = e.email; emailType = e.emailType; isPrimary = e.isPrimary
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
                try viewModel.add(email: email, emailType: emailType, isPrimary: isPrimary)
            case .edit(let e):
                try viewModel.update(e, email: email, emailType: emailType, isPrimary: isPrimary)
            }
            dismiss()
        } catch let e as ValidationError {
            errorMessage = e.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
