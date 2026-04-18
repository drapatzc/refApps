import SwiftUI

/// A list screen that displays all phone numbers for the insured person.
///
/// Supports adding new numbers via a sheet, editing existing ones by tapping
/// or using swipe actions, and deleting via a confirmation alert.
struct PhoneListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = PhoneNumberViewModel()

    /// Controls presentation of the add-phone form sheet.
    @State private var showAddForm = false

    /// The phone number currently being edited; non-nil while the edit sheet is presented.
    @State private var editPhone: PhoneNumber? = nil

    /// The phone number pending deletion; non-nil while the confirmation alert is shown.
    @State private var deletePhone: PhoneNumber? = nil

    /// Renders an empty state or a list of `PhoneRowView` items with swipe actions.
    var body: some View {
        Group {
            if viewModel.phones.isEmpty {
                EmptyStateView(
                    icon: "phone",
                    title: String(localized: "phone_empty_title"),
                    subtitle: String(localized: "phone_empty_subtitle")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.groupedBackground)
            } else {
                List {
                    ForEach(viewModel.phones) { phone in
                        PhoneRowView(phone: phone)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deletePhone = phone
                                } label: {
                                    Label(String(localized: "common_delete"), systemImage: "trash")
                                }
                                Button {
                                    editPhone = phone
                                } label: {
                                    Label(String(localized: "common_edit"), systemImage: "pencil")
                                }
                                .tint(AppTheme.primary)
                            }
                            .onTapGesture { editPhone = phone }
                    }
                }
            }
        }
        .navigationTitle(String(localized: "profile_phone"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAddForm = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddForm, onDismiss: { viewModel.loadPhones() }) {
            PhoneFormView(mode: .add, viewModel: viewModel)
        }
        .sheet(item: $editPhone, onDismiss: { viewModel.loadPhones() }) { phone in
            PhoneFormView(mode: .edit(phone), viewModel: viewModel)
        }
        .alert(String(localized: "common_delete_confirm_title"), isPresented: Binding(
            get: { deletePhone != nil },
            set: { if !$0 { deletePhone = nil } }
        )) {
            Button(String(localized: "common_delete"), role: .destructive) {
                if let p = deletePhone { try? viewModel.delete(p); deletePhone = nil }
            }
            Button(String(localized: "common_cancel"), role: .cancel) { deletePhone = nil }
        } message: {
            Text(String(localized: "phone_delete_confirm"))
        }
        .onAppear { viewModel.setup(context: modelContext) }
    }
}

/// A single row in the phone number list showing the type icon, number, type label, and primary badge.
struct PhoneRowView: View {

    /// The phone number to display.
    let phone: PhoneNumber

    /// The SF Symbols icon name for the phone type, falling back to `"phone.fill"`.
    private var typeIcon: String {
        PhoneType(rawValue: phone.phoneType)?.icon ?? "phone.fill"
    }

    /// Renders the type icon, number, type label, and an optional primary badge.
    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            Image(systemName: typeIcon)
                .font(.subheadline)
                .foregroundStyle(AppTheme.primary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(phone.number)
                    .font(.subheadline.weight(.medium))

                Text(PhoneType(rawValue: phone.phoneType)?.localizedName ?? phone.phoneType)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if phone.isPrimary { PrimaryBadge() }
        }
        .padding(.vertical, AppTheme.spacingXS)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(phone.phoneType): \(phone.number)")
    }
}

/// A form sheet for adding or editing a phone number.
///
/// `PhoneFormView` uses a `Mode` enum to differentiate between an add flow
/// (empty fields) and an edit flow (fields pre-populated from the existing record).
struct PhoneFormView: View {

    /// The two supported form modes.
    enum Mode {
        /// Adding a new phone number from scratch.
        case add
        /// Editing the given existing phone number.
        case edit(PhoneNumber)
    }

    /// The current form mode.
    let mode: Mode

    /// The view model that handles persistence.
    @Bindable var viewModel: PhoneNumberViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var number = ""
    @State private var phoneType = PhoneType.mobile.rawValue
    @State private var isPrimary = false
    @State private var errorMessage: String? = nil

    /// `true` when the form is in edit mode.
    private var isEditing: Bool {
        if case .edit = mode { return true }; return false
    }

    /// Renders the form with sections for the phone number, type, and the save button.
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

                Section(String(localized: "phone_section_number")) {
                    AppTextField(
                        label: String(localized: "field_phone_number"),
                        text: $number,
                        placeholder: "+49 170 1234567",
                        keyboardType: .phonePad,
                        autocapitalization: .never
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section(String(localized: "phone_section_type")) {
                    Picker(String(localized: "phone_type"), selection: $phoneType) {
                        ForEach(PhoneType.allCases, id: \.rawValue) { t in
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
            .navigationTitle(isEditing ? String(localized: "phone_edit_title") : String(localized: "phone_add_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common_cancel")) { dismiss() }
                }
            }
            .onAppear {
                if case .edit(let p) = mode {
                    number = p.number; phoneType = p.phoneType; isPrimary = p.isPrimary
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
                try viewModel.add(number: number, phoneType: phoneType, isPrimary: isPrimary)
            case .edit(let p):
                try viewModel.update(p, number: number, phoneType: phoneType, isPrimary: isPrimary)
            }
            dismiss()
        } catch let e as ValidationError {
            errorMessage = e.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
