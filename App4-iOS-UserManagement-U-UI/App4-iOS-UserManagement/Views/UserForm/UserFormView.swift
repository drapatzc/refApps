import SwiftUI

struct UserFormView: View {
    @ObservedObject var viewModel: UserFormViewModel
    @Environment(\.dismiss) private var dismiss

    var onSaved: ((User) -> Void)? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    salutationSection
                    nameSection
                    addressSection
                    contactSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(viewModel.isEditing
                ? String(localized: "form_title_edit")
                : String(localized: "form_title_new"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "button_cancel")) {
                        dismiss()
                    }
                    .accessibilityIdentifier("btn_cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "button_save")) {
                        Task { await saveUser() }
                    }
                    .fontWeight(.semibold)
                    .disabled(viewModel.isLoading)
                    .accessibilityIdentifier("btn_save")
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
            .alert(String(localized: "error_title"), isPresented: .constant(viewModel.errorMessage != nil)) {
                Button(String(localized: "button_ok")) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - Sections

    private var salutationSection: some View {
        FormSection(title: String(localized: "section_salutation")) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "field_salutation"))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Picker(String(localized: "field_salutation"), selection: $viewModel.salutation) {
                    ForEach(Salutation.allCases) { sal in
                        Text(sal.localizedLabel).tag(sal)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var nameSection: some View {
        FormSection(title: String(localized: "section_name")) {
            FormFieldView(
                label: String(localized: "field_first_name"),
                placeholder: String(localized: "placeholder_first_name"),
                text: $viewModel.firstName,
                errorMessage: viewModel.fieldErrors[.firstName],
                identifier: "tf_firstName"
            )
            .onChange(of: viewModel.firstName) { _, _ in
                if viewModel.fieldErrors[.firstName] != nil {
                    viewModel.validateField(.firstName)
                }
            }

            FormFieldView(
                label: String(localized: "field_last_name"),
                placeholder: String(localized: "placeholder_last_name"),
                text: $viewModel.lastName,
                errorMessage: viewModel.fieldErrors[.lastName],
                identifier: "tf_lastName"
            )
            .onChange(of: viewModel.lastName) { _, _ in
                if viewModel.fieldErrors[.lastName] != nil {
                    viewModel.validateField(.lastName)
                }
            }
        }
    }

    private var addressSection: some View {
        FormSection(title: String(localized: "section_address")) {
            HStack(alignment: .top, spacing: 12) {
                FormFieldView(
                    label: String(localized: "field_street"),
                    placeholder: String(localized: "placeholder_street"),
                    text: $viewModel.street,
                    errorMessage: viewModel.fieldErrors[.street],
                    identifier: "tf_street"
                )
                .frame(maxWidth: .infinity)
                .onChange(of: viewModel.street) { _, _ in
                    if viewModel.fieldErrors[.street] != nil {
                        viewModel.validateField(.street)
                    }
                }

                FormFieldView(
                    label: String(localized: "field_house_number"),
                    placeholder: String(localized: "placeholder_house_number"),
                    text: $viewModel.houseNumber,
                    errorMessage: viewModel.fieldErrors[.houseNumber],
                    identifier: "tf_houseNumber"
                )
                .frame(width: 80)
                .onChange(of: viewModel.houseNumber) { _, _ in
                    if viewModel.fieldErrors[.houseNumber] != nil {
                        viewModel.validateField(.houseNumber)
                    }
                }
            }

            HStack(alignment: .top, spacing: 12) {
                FormFieldView(
                    label: String(localized: "field_postal_code"),
                    placeholder: String(localized: "placeholder_postal_code"),
                    text: $viewModel.postalCode,
                    errorMessage: viewModel.fieldErrors[.postalCode],
                    keyboardType: .numberPad,
                    autocapitalization: .never,
                    identifier: "tf_postalCode"
                )
                .frame(width: 110)
                .onChange(of: viewModel.postalCode) { _, _ in
                    if viewModel.fieldErrors[.postalCode] != nil {
                        viewModel.validateField(.postalCode)
                    }
                }

                FormFieldView(
                    label: String(localized: "field_city"),
                    placeholder: String(localized: "placeholder_city"),
                    text: $viewModel.city,
                    errorMessage: viewModel.fieldErrors[.city],
                    identifier: "tf_city"
                )
                .frame(maxWidth: .infinity)
                .onChange(of: viewModel.city) { _, _ in
                    if viewModel.fieldErrors[.city] != nil {
                        viewModel.validateField(.city)
                    }
                }
            }

            FormFieldView(
                label: String(localized: "field_country"),
                placeholder: String(localized: "placeholder_country"),
                text: $viewModel.country,
                errorMessage: viewModel.fieldErrors[.country],
                identifier: "tf_country"
            )
            .onChange(of: viewModel.country) { _, _ in
                if viewModel.fieldErrors[.country] != nil {
                    viewModel.validateField(.country)
                }
            }
        }
    }

    private var contactSection: some View {
        FormSection(title: String(localized: "section_contact")) {
            FormFieldView(
                label: String(localized: "field_email"),
                placeholder: String(localized: "placeholder_email"),
                text: $viewModel.email,
                errorMessage: viewModel.fieldErrors[.email],
                keyboardType: .emailAddress,
                autocapitalization: .never,
                identifier: "tf_email"
            )
            .onChange(of: viewModel.email) { _, _ in
                if viewModel.fieldErrors[.email] != nil {
                    viewModel.validateField(.email)
                }
            }

            Text(String(localized: "email_optional_hint"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Aktionen

    private func saveUser() async {
        await viewModel.save()
        if viewModel.isSaved, let user = viewModel.savedUser {
            onSaved?(user)
            dismiss()
        }
    }
}

// MARK: - Hilfskonstrukte

private struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.leading, 4)

            VStack(spacing: 12) {
                content
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
