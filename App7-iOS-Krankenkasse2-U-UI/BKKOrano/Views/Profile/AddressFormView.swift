import SwiftUI
import SwiftData

/// Sheet-style form for adding or editing an Address.
struct AddressFormView: View {

    let editing: Address?
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AddressViewModel()

    @State private var street: String = ""
    @State private var houseNumber: String = ""
    @State private var postalCode: String = ""
    @State private var city: String = ""
    @State private var country: String = "Deutschland"
    @State private var addressType: AddressType = .primary
    @State private var isPrimary: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spaceL) {
                    if let errorMessage {
                        OranoErrorBanner(message: errorMessage) {
                            self.errorMessage = nil
                        }
                    }

                    streetSection
                    locationSection
                    typeSection
                    primaryToggle
                }
                .padding(AppTheme.spaceL)
            }
            .background(AppTheme.canvas.ignoresSafeArea())
            .navigationTitle(editing == nil
                             ? String(localized: "address_add_title")
                             : String(localized: "address_edit_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "common_cancel")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "common_save"), action: save)
                        .bold()
                        .accessibilityIdentifier("save_address_button")
                }
            }
            .task {
                viewModel.setup(context: modelContext)
                populateFromEditing()
            }
        }
    }

    // MARK: - Sections

    private var streetSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(
                title: String(localized: "address_section_street"),
                icon: "road.lanes"
            )
            OranoCard {
                VStack(spacing: AppTheme.spaceM) {
                    OranoTextField(
                        title: String(localized: "field_street"),
                        text: $street,
                        placeholder: String(localized: "address_placeholder_street")
                    )
                    OranoTextField(
                        title: String(localized: "field_house_number"),
                        text: $houseNumber,
                        placeholder: String(localized: "address_placeholder_house_number")
                    )
                }
            }
        }
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(
                title: String(localized: "address_section_location"),
                icon: "mappin.circle.fill"
            )
            OranoCard {
                VStack(spacing: AppTheme.spaceM) {
                    OranoTextField(
                        title: String(localized: "field_postal_code"),
                        text: $postalCode,
                        keyboard: .numberPad
                    )
                    OranoTextField(
                        title: String(localized: "field_city"),
                        text: $city,
                        placeholder: String(localized: "address_placeholder_city")
                    )
                    OranoTextField(
                        title: String(localized: "field_country"),
                        text: $country
                    )
                }
            }
        }
    }

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(
                title: String(localized: "address_section_type"),
                icon: "tag.fill"
            )
            OranoCard {
                Picker(String(localized: "address_type"), selection: $addressType) {
                    ForEach(AddressType.allCases, id: \.self) { type in
                        Text(type.localizedName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var primaryToggle: some View {
        OranoCard {
            Toggle(isOn: $isPrimary) {
                Label(String(localized: "common_is_primary"), systemImage: "star.fill")
                    .foregroundStyle(AppTheme.ink)
            }
            .tint(AppTheme.primary)
        }
    }

    // MARK: - Save

    private func save() {
        do {
            if let editing {
                try viewModel.update(
                    editing,
                    street: street,
                    houseNumber: houseNumber,
                    postalCode: postalCode,
                    city: city,
                    country: country,
                    addressType: addressType.rawValue,
                    isPrimary: isPrimary
                )
            } else {
                try viewModel.add(
                    street: street,
                    houseNumber: houseNumber,
                    postalCode: postalCode,
                    city: city,
                    country: country,
                    addressType: addressType.rawValue,
                    isPrimary: isPrimary
                )
            }
            onSaved()
            dismiss()
        } catch let validationError as ValidationError {
            errorMessage = validationError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func populateFromEditing() {
        guard let editing else { return }
        street = editing.street
        houseNumber = editing.houseNumber
        postalCode = editing.postalCode
        city = editing.city
        country = editing.country
        addressType = AddressType(rawValue: editing.addressType) ?? .primary
        isPrimary = editing.isPrimary
    }
}
