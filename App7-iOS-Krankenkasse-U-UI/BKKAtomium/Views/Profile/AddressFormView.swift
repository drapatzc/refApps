import SwiftUI

/// A form sheet for adding or editing a postal address.
///
/// `AddressFormView` uses a `Mode` enum to differentiate between an add flow
/// (empty fields) and an edit flow (fields pre-populated from the existing record).
struct AddressFormView: View {

    /// The two supported form modes.
    enum Mode {
        /// Adding a new address from scratch.
        case add
        /// Editing the given existing address.
        case edit(Address)
    }

    /// The current form mode.
    let mode: Mode

    /// The view model that handles persistence.
    @Bindable var viewModel: AddressViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var street = ""
    @State private var houseNumber = ""
    @State private var postalCode = ""
    @State private var city = ""
    @State private var country = "Deutschland"
    @State private var addressType = AddressType.primary.rawValue
    @State private var isPrimary = false
    @State private var errorMessage: String? = nil
    @State private var isSaving = false

    /// `true` when the form is in edit mode.
    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    /// Renders the form with sections for street, location, type, and the save button.
    var body: some View {
        NavigationStack {
            Form {
                if let error = errorMessage {
                    Section {
                        ErrorBannerView(message: error) {
                            errorMessage = nil
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                }

                Section(String(localized: "address_section_street")) {
                    AppTextField(
                        label: String(localized: "field_street"),
                        text: $street,
                        placeholder: String(localized: "address_placeholder_street")
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)

                    AppTextField(
                        label: String(localized: "field_house_number"),
                        text: $houseNumber,
                        placeholder: String(localized: "address_placeholder_house_number")
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                }

                Section(String(localized: "address_section_location")) {
                    AppTextField(
                        label: String(localized: "field_postal_code"),
                        text: $postalCode,
                        placeholder: "12345",
                        keyboardType: .numbersAndPunctuation
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)

                    AppTextField(
                        label: String(localized: "field_city"),
                        text: $city,
                        placeholder: String(localized: "address_placeholder_city")
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)

                    AppTextField(
                        label: String(localized: "field_country"),
                        text: $country,
                        placeholder: "Deutschland"
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                }

                Section(String(localized: "address_section_type")) {
                    Picker(String(localized: "address_type"), selection: $addressType) {
                        ForEach(AddressType.allCases, id: \.rawValue) { type in
                            Text(type.localizedName).tag(type.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    Toggle(String(localized: "common_is_primary"), isOn: $isPrimary)
                }

                Section {
                    Button {
                        save()
                    } label: {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                            } else {
                                Text(isEditing ? String(localized: "common_save") : String(localized: "common_add"))
                                    .font(.headline)
                            }
                            Spacer()
                        }
                    }
                    .primaryButton()
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .disabled(isSaving)
                }
            }
            .navigationTitle(isEditing ? String(localized: "address_edit_title") : String(localized: "address_add_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common_cancel")) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadInitialValues()
            }
        }
    }

    /// Pre-populates the form fields with values from the address being edited.
    private func loadInitialValues() {
        if case .edit(let address) = mode {
            street = address.street
            houseNumber = address.houseNumber
            postalCode = address.postalCode
            city = address.city
            country = address.country
            addressType = address.addressType
            isPrimary = address.isPrimary
        }
    }

    /// Attempts to save the form data by calling the appropriate view model method.
    ///
    /// Dismisses the sheet on success. Displays a validation or generic error banner on failure.
    private func save() {
        isSaving = true
        errorMessage = nil

        do {
            switch mode {
            case .add:
                try viewModel.add(
                    street: street,
                    houseNumber: houseNumber,
                    postalCode: postalCode,
                    city: city,
                    country: country,
                    addressType: addressType,
                    isPrimary: isPrimary
                )
            case .edit(let address):
                try viewModel.update(
                    address,
                    street: street,
                    houseNumber: houseNumber,
                    postalCode: postalCode,
                    city: city,
                    country: country,
                    addressType: addressType,
                    isPrimary: isPrimary
                )
            }
            dismiss()
        } catch let error as ValidationError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
}
