import Foundation
import SwiftUI

@MainActor
final class UserFormViewModel: ObservableObject {

    // MARK: - Formularfelder
    @Published var salutation: Salutation = .mr
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var street: String = ""
    @Published var houseNumber: String = ""
    @Published var postalCode: String = ""
    @Published var city: String = ""
    @Published var country: String = ""
    @Published var email: String = ""

    // MARK: - Validierungsfehler (pro Feld)
    @Published var fieldErrors: [UserField: String] = [:]

    // MARK: - UI-State
    @Published var isLoading: Bool = false
    @Published var isSaved: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Gespeicherter Benutzer (nach Erfolg)
    private(set) var savedUser: User? = nil

    // MARK: - Modus
    let isEditing: Bool
    private let existingUser: User?

    // MARK: - Dependencies
    private let service: UserService

    // MARK: - Init

    /// Neuer Benutzer
    init(service: UserService) {
        self.service = service
        self.isEditing = false
        self.existingUser = nil
        // Standardland
        country = Locale.current.language.languageCode?.identifier == "de" ? "Deutschland" : "Germany"
    }

    /// Benutzer bearbeiten
    init(service: UserService, user: User) {
        self.service = service
        self.isEditing = true
        self.existingUser = user
        // Populate fields
        salutation = user.salutation
        firstName = user.firstName
        lastName = user.lastName
        street = user.street
        houseNumber = user.houseNumber
        postalCode = user.postalCode
        city = user.city
        country = user.country
        email = user.email
    }

    // MARK: - Aktueller Benutzer aus Formular

    var currentUser: User {
        User(
            id: existingUser?.id ?? 0,
            salutation: salutation,
            firstName: firstName,
            lastName: lastName,
            street: street,
            houseNumber: houseNumber,
            postalCode: postalCode,
            city: city,
            country: country,
            email: email
        )
    }

    // MARK: - Speichern

    func save() async {
        isLoading = true
        errorMessage = nil
        fieldErrors = [:]
        defer { isLoading = false }

        do {
            if isEditing {
                try await service.updateUser(currentUser)
                savedUser = currentUser
            } else {
                let created = try await service.createUser(currentUser)
                savedUser = created
            }
            isSaved = true
        } catch let appError as AppError {
            if case .validationFailed(let errors) = appError {
                for fieldError in errors {
                    fieldErrors[fieldError.field] = fieldError.message
                }
            } else {
                errorMessage = appError.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Echtzeit-Validierung (einzelnes Feld)

    func validateField(_ field: UserField) {
        let validator = UserValidator()
        var error: ValidationFieldError? = nil

        switch field {
        case .salutation:
            error = validator.validateSalutation(salutation)
        case .firstName:
            error = validator.validateFirstName(firstName)
        case .lastName:
            error = validator.validateLastName(lastName)
        case .street:
            error = validator.validateStreet(street)
        case .houseNumber:
            error = validator.validateHouseNumber(houseNumber)
        case .postalCode:
            error = validator.validatePostalCode(postalCode)
        case .city:
            error = validator.validateCity(city)
        case .country:
            error = validator.validateCountry(country)
        case .email:
            error = validator.validateEmail(email)
        }

        if let error {
            fieldErrors[field] = error.message
        } else {
            fieldErrors.removeValue(forKey: field)
        }
    }

    var hasErrors: Bool {
        !fieldErrors.isEmpty
    }
}
