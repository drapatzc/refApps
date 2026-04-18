import XCTest
@testable import App4_iOS_UserManagement

final class UserValidatorTests: XCTestCase {

    var sut: UserValidator!

    override func setUp() {
        super.setUp()
        sut = UserValidator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Hilfsmethode

    private func makeValidUser() -> User {
        User.makeTest()
    }

    // MARK: - Vorname

    func test_validateFirstName_empty_returnsError() {
        let error = sut.validateFirstName("")
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.field, .firstName)
    }

    func test_validateFirstName_whitespaceOnly_returnsError() {
        let error = sut.validateFirstName("   ")
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.field, .firstName)
    }

    func test_validateFirstName_valid_returnsNil() {
        let error = sut.validateFirstName("Max")
        XCTAssertNil(error)
    }

    func test_validateFirstName_exactMaxLength_returnsNil() {
        let name = String(repeating: "A", count: UserValidator.maxNameLength)
        let error = sut.validateFirstName(name)
        XCTAssertNil(error)
    }

    func test_validateFirstName_exceedsMaxLength_returnsError() {
        let name = String(repeating: "A", count: UserValidator.maxNameLength + 1)
        let error = sut.validateFirstName(name)
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.field, .firstName)
    }

    // MARK: - Nachname

    func test_validateLastName_empty_returnsError() {
        let error = sut.validateLastName("")
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.field, .lastName)
    }

    func test_validateLastName_valid_returnsNil() {
        let error = sut.validateLastName("Mustermann")
        XCTAssertNil(error)
    }

    func test_validateLastName_exceedsMaxLength_returnsError() {
        let name = String(repeating: "Z", count: UserValidator.maxNameLength + 1)
        let error = sut.validateLastName(name)
        XCTAssertNotNil(error)
    }

    // MARK: - PLZ

    func test_validatePostalCode_empty_returnsError() {
        let error = sut.validatePostalCode("")
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.field, .postalCode)
    }

    func test_validatePostalCode_valid5Digits_returnsNil() {
        let error = sut.validatePostalCode("12345")
        XCTAssertNil(error)
    }

    func test_validatePostalCode_withLetters_returnsError() {
        let error = sut.validatePostalCode("1234A")
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.field, .postalCode)
    }

    func test_validatePostalCode_tooShort_returnsError() {
        let error = sut.validatePostalCode("12")
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.field, .postalCode)
    }

    func test_validatePostalCode_tooLong_returnsError() {
        let error = sut.validatePostalCode("12345678901") // 11 Stellen
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.field, .postalCode)
    }

    func test_validatePostalCode_exactMinLength_returnsNil() {
        let error = sut.validatePostalCode("123")
        XCTAssertNil(error)
    }

    func test_validatePostalCode_exactMaxLength_returnsNil() {
        let error = sut.validatePostalCode("1234567890") // 10 Stellen
        XCTAssertNil(error)
    }

    // MARK: - E-Mail

    func test_validateEmail_empty_returnsNil() {
        // E-Mail ist optional
        let error = sut.validateEmail("")
        XCTAssertNil(error)
    }

    func test_validateEmail_validAddress_returnsNil() {
        let error = sut.validateEmail("max@example.com")
        XCTAssertNil(error)
    }

    func test_validateEmail_missingAt_returnsError() {
        let error = sut.validateEmail("maxexample.com")
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.field, .email)
    }

    func test_validateEmail_missingDomain_returnsError() {
        let error = sut.validateEmail("max@")
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.field, .email)
    }

    func test_validateEmail_missingTLD_returnsError() {
        let error = sut.validateEmail("max@example")
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.field, .email)
    }

    func test_validateEmail_exceedsMaxLength_returnsError() {
        let localPart = String(repeating: "a", count: 245)
        let email = "\(localPart)@example.com"
        XCTAssertGreaterThan(email.count, UserValidator.maxEmailLength)
        let error = sut.validateEmail(email)
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.field, .email)
    }

    func test_validateEmail_withSubdomain_returnsNil() {
        let error = sut.validateEmail("user@mail.example.co.uk")
        XCTAssertNil(error)
    }

    // MARK: - Gesamtvalidierung

    func test_validate_validUser_returnsValid() {
        let user = makeValidUser()
        let result = sut.validate(user)
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.errors.isEmpty)
    }

    func test_validate_multipleErrors_returnsAllErrors() {
        let user = User(
            id: 0,
            salutation: .mr,
            firstName: "",
            lastName: "",
            street: "Valid Street",
            houseNumber: "1",
            postalCode: "ABC",
            city: "Berlin",
            country: "Germany",
            email: ""
        )
        let result = sut.validate(user)
        XCTAssertFalse(result.isValid)
        // Expect errors for: firstName, lastName, postalCode
        XCTAssertGreaterThanOrEqual(result.errors.count, 3)
    }

    func test_validate_trimming_whitespace_firstName_returnsError() {
        // The validator itself does not trim — that is done by the service
        // Here we verify that " " is treated as empty
        let error = sut.validateFirstName("   ")
        XCTAssertNotNil(error)
    }
}
