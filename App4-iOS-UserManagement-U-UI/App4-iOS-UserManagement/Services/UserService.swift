import Foundation

/// Business logic layer — orchestrates repository and validator
@MainActor
final class UserService {

    private let repository: UserRepositoryProtocol
    private let validator: UserValidator

    init(repository: UserRepositoryProtocol, validator: UserValidator = UserValidator()) {
        self.repository = repository
        self.validator = validator
    }

    // MARK: - Read

    func loadAllUsers() async throws -> [User] {
        try await repository.fetchAll()
    }

    func loadUser(id: Int64) async throws -> User {
        guard let user = try await repository.fetch(id: id) else {
            throw AppError.recordNotFound
        }
        return user
    }

    func searchUsers(query: String) async throws -> [User] {
        try await repository.search(query: query)
    }

    // MARK: - Write

    /// Creates a new user — validates first
    func createUser(_ user: User) async throws -> User {
        let trimmed = trimmedUser(user)
        let result = validator.validate(trimmed)
        if case .invalid(let errors) = result {
            throw AppError.validationFailed(errors)
        }
        return try await repository.insert(trimmed)
    }

    /// Updates an existing user — validates first
    func updateUser(_ user: User) async throws {
        let trimmed = trimmedUser(user)
        let result = validator.validate(trimmed)
        if case .invalid(let errors) = result {
            throw AppError.validationFailed(errors)
        }
        try await repository.update(trimmed)
    }

    /// Deletes a user
    func deleteUser(id: Int64) async throws {
        try await repository.delete(id: id)
    }

    // MARK: - Validierung

    func validate(_ user: User) -> ValidationResult {
        validator.validate(trimmedUser(user))
    }

    // MARK: - Debug

#if DEBUG
    /// Creates 10 predefined test users (without validation)
    func seedTestUsers() async throws -> [User] {
        var created: [User] = []
        for user in UserService.debugSeedUsers {
            let saved = try await repository.insert(user)
            created.append(saved)
        }
        return created
    }

    /// Deletes all users from the database
    func deleteAllUsers() async throws {
        try await repository.deleteAll()
    }

    private static let debugSeedUsers: [User] = [
        User(salutation: .mr,  firstName: "Thomas",    lastName: "Müller",     street: "Bahnhofstraße",   houseNumber: "12",  postalCode: "80333", city: "München",    country: "Deutschland", email: "thomas.mueller@example.de"),
        User(salutation: .ms,  firstName: "Laura",     lastName: "Schmidt",    street: "Hauptstraße",     houseNumber: "5",   postalCode: "10115", city: "Berlin",     country: "Deutschland", email: "laura.schmidt@example.de"),
        User(salutation: .mr,  firstName: "Markus",    lastName: "Weber",      street: "Gartenweg",       houseNumber: "3a",  postalCode: "60313", city: "Frankfurt",  country: "Deutschland"),
        User(salutation: .ms,  firstName: "Sabine",    lastName: "Fischer",    street: "Lindenallee",     houseNumber: "21",  postalCode: "70173", city: "Stuttgart",  country: "Deutschland", email: "s.fischer@example.de"),
        User(salutation: .mx,  firstName: "Alex",      lastName: "Wagner",     street: "Rosenstraße",     houseNumber: "8",   postalCode: "40213", city: "Düsseldorf", country: "Deutschland"),
        User(salutation: .mr,  firstName: "Stefan",    lastName: "Becker",     street: "Kirchgasse",      houseNumber: "17", postalCode: "50667", city: "Köln",       country: "Deutschland", email: "stefan.becker@example.de"),
        User(salutation: .ms,  firstName: "Julia",     lastName: "Hoffmann",   street: "Schillerplatz",   houseNumber: "2",   postalCode: "01067", city: "Dresden",    country: "Deutschland"),
        User(salutation: .mr,  firstName: "Andreas",   lastName: "Schäfer",    street: "Bergstraße",      houseNumber: "44",  postalCode: "04109", city: "Leipzig",    country: "Deutschland", email: "a.schaefer@example.de"),
        User(salutation: .ms,  firstName: "Monika",    lastName: "Koch",       street: "Marktplatz",      houseNumber: "1",   postalCode: "28195", city: "Bremen",     country: "Deutschland"),
        User(salutation: .mr,  firstName: "Christian", lastName: "Richter",    street: "Elisabethstraße", houseNumber: "33",  postalCode: "30159", city: "Hannover",   country: "Deutschland", email: "c.richter@example.de"),
    ]
#endif

    // MARK: - Helpers

    /// Trims whitespace from all text fields
    private func trimmedUser(_ user: User) -> User {
        User(
            id: user.id,
            salutation: user.salutation,
            firstName: user.firstName.trimmingCharacters(in: .whitespaces),
            lastName: user.lastName.trimmingCharacters(in: .whitespaces),
            street: user.street.trimmingCharacters(in: .whitespaces),
            houseNumber: user.houseNumber.trimmingCharacters(in: .whitespaces),
            postalCode: user.postalCode.trimmingCharacters(in: .whitespaces),
            city: user.city.trimmingCharacters(in: .whitespaces),
            country: user.country.trimmingCharacters(in: .whitespaces),
            email: user.email.trimmingCharacters(in: .whitespaces)
        )
    }
}
