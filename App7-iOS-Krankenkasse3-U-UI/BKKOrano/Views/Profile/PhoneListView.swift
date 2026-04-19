import SwiftUI
import SwiftData

/// CRUD for phone numbers.
struct PhoneListView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = PhoneNumberViewModel()
    @State private var showForm = false
    @State private var editing: PhoneNumber?

    var body: some View {
        ZStack {
            AppTheme.canvas.ignoresSafeArea()
            if viewModel.phones.isEmpty {
                OranoEmptyState(
                    icon: "phone.fill",
                    title: String(localized: "phone_empty_title"),
                    subtitle: String(localized: "phone_empty_subtitle")
                )
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.spaceM) {
                        ForEach(viewModel.phones) { phone in
                            PhoneRowCard(phone: phone) {
                                editing = phone
                                showForm = true
                            } onDelete: {
                                try? viewModel.delete(phone)
                            }
                        }
                    }
                    .padding(AppTheme.spaceL)
                }
            }
        }
        .navigationTitle(String(localized: "profile_phone"))
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
            PhoneFormView(editing: editing) { viewModel.loadPhones() }
        }
        .task { viewModel.setup(context: modelContext) }
    }
}

private struct PhoneRowCard: View {
    let phone: PhoneNumber
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var confirmDelete = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            HStack(alignment: .top) {
                Image(systemName: PhoneType(rawValue: phone.phoneType)?.icon ?? "phone.fill")
                    .font(.title3)
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.primarySoft)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(PhoneType(rawValue: phone.phoneType)?.localizedName ?? phone.phoneType)
                        .font(.caption)
                        .foregroundStyle(AppTheme.primary)
                    Text(phone.number)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.ink)
                }
                Spacer()
                if phone.isPrimary { OranoPrimaryBadge() }
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
            String(localized: "phone_delete_confirm"),
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button(String(localized: "common_delete"), role: .destructive, action: onDelete)
            Button(String(localized: "common_cancel"), role: .cancel) { }
        }
    }
}

private struct PhoneFormView: View {
    let editing: PhoneNumber?
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = PhoneNumberViewModel()
    @State private var number: String = ""
    @State private var phoneType: PhoneType = .mobile
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
                            title: String(localized: "phone_section_number"),
                            text: $number,
                            keyboard: .phonePad
                        )
                    }
                    OranoCard {
                        Picker(String(localized: "phone_type"), selection: $phoneType) {
                            ForEach(PhoneType.allCases, id: \.self) { type in
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
                             ? String(localized: "phone_add_title")
                             : String(localized: "phone_edit_title"))
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
                    number = editing.number
                    phoneType = PhoneType(rawValue: editing.phoneType) ?? .mobile
                    isPrimary = editing.isPrimary
                }
            }
        }
    }

    private func save() {
        do {
            if let editing {
                try viewModel.update(editing, number: number, phoneType: phoneType.rawValue, isPrimary: isPrimary)
            } else {
                try viewModel.add(number: number, phoneType: phoneType.rawValue, isPrimary: isPrimary)
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
