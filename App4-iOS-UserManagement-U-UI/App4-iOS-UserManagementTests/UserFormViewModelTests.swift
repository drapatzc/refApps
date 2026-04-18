import XCTest
@testable import App4_iOS_UserManagement

@MainActor
final class UserFormViewModelTests: XCTestCase {

    var mockRepository: MockUserRepository!
    var service: UserService!
    var sut: UserFormViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        service = UserService(repository: mockRepository)
        sut = UserFormViewModel(service: service)
    }

    override func tearDown() {
        mockRepository.reset()
        service = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialisierung

    func test_init_newUser_isEditingFalse() {
        XCTAssertFalse(sut.isEditing)
    }

    func test_init_existingUser_isEditingTrue() {
        let vm = UserFormViewModel(service: service, user: User.makeTest(id: 1))
        XCTAssertTrue(vm.isEditing)
    }

    func test_init_existingUser_populatesFields() {
        let user = User.makeTest(
            id: 1,
            firstName: "Anna",
            lastName: "Schmidt",
            email: "anna@test.de"
        )
        let vm = UserFormViewModel(service: service, user: user)
        XCTAssertEqual(vm.firstName, "Anna")
        XCTAssertEqual(vm.lastName, "Schmidt")
        XCTAssertEqual(vm.email, "anna@test.de")
    }

    // MARK: - Speichern (Neuer Benutzer)

    func test_save_newUser_validData_setsIsSaved() async {
        sut.firstName = "Max"
        sut.lastName = "Mustermann"
        sut.street = "Hauptstraße"
        sut.houseNumber = "1"
        sut.postalCode = "12345"
        sut.city = "Berlin"
        sut.country = "Germany"

        await sut.save()

        XCTAssertTrue(sut.isSaved)
        XCTAssertNotNil(sut.savedUser)
    }

    func test_save_newUser_validData_callsInsert() async {
        sut.firstName = "Max"
        sut.lastName = "Mustermann"
        sut.street = "Hauptstraße"
        sut.houseNumber = "1"
        sut.postalCode = "12345"
        sut.city = "Berlin"
        sut.country = "Germany"

        await sut.save()

        XCTAssertEqual(mockRepository.insertCallCount, 1)
    }

    // MARK: - Speichern (Bearbeiten)

    func test_save_editUser_validData_callsUpdate() async {
        let user = User.makeTest(id: 1)
        mockRepository.addUser(user)
        let vm = UserFormViewModel(service: service, user: user)
        vm.firstName = "Bearbeitet"

        await vm.save()

        XCTAssertEqual(mockRepository.updateCallCount, 1)
        XCTAssertTrue(vm.isSaved)
    }

    // MARK: - Validierung

    func test_save_invalidData_setsFieldErrors() async {
        sut.firstName = "" // Pflichtfeld leer
        sut.lastName = "Test"
        sut.street = "Straße"
        sut.houseNumber = "1"
        sut.postalCode = "12345"
        sut.city = "Stadt"
        sut.country = "Land"

        await sut.save()

        XCTAssertFalse(sut.isSaved)
        XCTAssertNotNil(sut.fieldErrors[.firstName])
    }

    func test_save_invalidEmail_setsEmailError() async {
        sut.firstName = "Max"
        sut.lastName = "Mustermann"
        sut.street = "Hauptstraße"
        sut.houseNumber = "1"
        sut.postalCode = "12345"
        sut.city = "Berlin"
        sut.country = "Germany"
        sut.email = "not-valid"

        await sut.save()

        XCTAssertFalse(sut.isSaved)
        XCTAssertNotNil(sut.fieldErrors[.email])
    }

    func test_save_invalidPostalCode_setsPostalCodeError() async {
        sut.firstName = "Max"
        sut.lastName = "Mustermann"
        sut.street = "Hauptstraße"
        sut.houseNumber = "1"
        sut.postalCode = "ABCDE" // Keine Ziffern
        sut.city = "Berlin"
        sut.country = "Germany"

        await sut.save()

        XCTAssertFalse(sut.isSaved)
        XCTAssertNotNil(sut.fieldErrors[.postalCode])
    }

    // MARK: - Einzelfeldvalidierung

    func test_validateField_firstName_emptyAfterChange_setsError() {
        sut.firstName = ""
        sut.validateField(.firstName)
        XCTAssertNotNil(sut.fieldErrors[.firstName])
    }

    func test_validateField_firstName_validAfterChange_removesError() {
        sut.fieldErrors[.firstName] = "Pflichtfeld"
        sut.firstName = "Max"
        sut.validateField(.firstName)
        XCTAssertNil(sut.fieldErrors[.firstName])
    }

    func test_hasErrors_withErrors_returnsTrue() {
        sut.fieldErrors[.firstName] = "Fehler"
        XCTAssertTrue(sut.hasErrors)
    }

    func test_hasErrors_noErrors_returnsFalse() {
        sut.fieldErrors = [:]
        XCTAssertFalse(sut.hasErrors)
    }

    // MARK: - currentUser

    func test_currentUser_reflectsFormState() {
        sut.salutation = .ms
        sut.firstName = "Maria"
        sut.lastName = "Muster"
        sut.email = "maria@test.de"

        let user = sut.currentUser
        XCTAssertEqual(user.salutation, .ms)
        XCTAssertEqual(user.firstName, "Maria")
        XCTAssertEqual(user.lastName, "Muster")
        XCTAssertEqual(user.email, "maria@test.de")
    }
}
