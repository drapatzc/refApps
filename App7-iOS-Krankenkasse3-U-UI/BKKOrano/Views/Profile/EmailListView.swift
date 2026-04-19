import SwiftUI
import SwiftData

/// CRUD for email addresses.
struct EmailListView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = EmailViewModel()
    @State private var showForm = false
    @State private var editing: EmailAddress?

    var body: some View {
        ZStack {
            AppTheme.canvas.ignoresSafeArea()
            if viewModel.emails.isEmpty {
                OranoEmptyState(
                    icon: "envelope.fill",
                    title: String(localized: "email_empty_title"),
                    subtitle: String(localized: "email_empty_subtitle")
                )
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.spaceM) {
                        ForEach(viewModel.emails) { mail in
                            EmailRowCard(email: mail) {
                                editing = mail
                                showForm = true
                            } onDelete: {
                                try? viewModel.delete(mail)
                            }
                        }
                    }
                    .padding(AppTheme.spaceL)
                }
            }
        }
        .navigationTitle(String(localized: "profile_email"))
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
            EmailFormView(editing: editing) { viewModel.loadEmails() }
        }
        .task { viewModel.setup(context: modelContext) }
    }
}

private struct EmailRowCard: View {
    let email: EmailAddress
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var confirmDelete = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            HStack(alignment: .top) {
                Image(systemName: EmailType(rawValue: email.emailType)?.icon ?? "envelope.fill")
                    .font(.title3)
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.primarySoft)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(EmailType(rawValue: email.emailType)?.localizedName ?? email.emailType)
                        .font(.caption)
                        .foregroundStyle(AppTheme.primary)
                    Text(email.email)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.ink)
                }
                Spacer()
                if email.isPrimary { OranoPrimaryBadge() }
            }
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
            String(localized: "email_delete_confirm"),
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button(String(localized: "common_delete"), role: .destructive, action: onDelete)
            Button(String(localized: "common_cancel"), role: .cancel) { }
        }
    }
}

private struct EmailFormView: View {
    let editing: EmailAddress?
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = EmailViewModel()
    @State private var address: String = ""
    @State private var emailType: EmailType = .personal
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
                        OranoTextField(
                            title: String(localized: "field_email"),
                            text: $address,
                            keyboard: .emailAddress,
                            capitalization: .never
                        )
                    }
                    OranoCard {
                        Picker(String(localized: "email_type"), selection: $emailType) {
                            ForEach(EmailType.allCases, id: \.self) { type in
                                Label(type.localizedName, systemImage: type.icon).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
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
                             ? String(localized: "email_add_title")
                             : String(localized: "email_edit_title"))
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
                    address = editing.email
                    emailType = EmailType(rawValue: editing.emailType) ?? .personal
                    isPrimary = editing.isPrimary
                }
            }
        }
    }

    private func save() {
        do {
            if let editing {
                try viewModel.update(editing, email: address, emailType: emailType.rawValue, isPrimary: isPrimary)
            } else {
                try viewModel.add(email: address, emailType: emailType.rawValue, isPrimary: isPrimary)
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
