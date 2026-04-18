import XCTest
import SwiftData
@testable import App11_iOS_Namensliste_U_UI

final class App11_iOS_Namensliste_U_UITests: XCTestCase {

    var viewModel: PersonViewModel!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Person.self, configurations: config)
        modelContext = ModelContext(modelContainer)
        viewModel = PersonViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        modelContainer = nil
        modelContext = nil
    }

    // MARK: - Test 1: Person Initialisierung

    func testPersonInitialization() throws {
        let person = Person(vorname: "Max", nachname: "Mustermann")
        XCTAssertEqual(person.vorname, "Max")
        XCTAssertEqual(person.nachname, "Mustermann")
        XCTAssertNotNil(person.erstelltAm)
    }

    // MARK: - Test 2: Vollständiger Name

    func testVollerNameFormatierung() throws {
        let person = Person(vorname: "Anna", nachname: "Schmidt")
        XCTAssertEqual(person.vollerName, "Schmidt, Anna")
    }

    // MARK: - Test 3: Validierung – leerer Vorname

    func testValidierungSchlagtFehlBeiLeeremVorname() throws {
        viewModel.vorname = ""
        viewModel.nachname = "Mustermann"
        let isValid = viewModel.validateInput()
        XCTAssertFalse(isValid)
        XCTAssertTrue(viewModel.vornameError)
        XCTAssertFalse(viewModel.nachnameError)
    }

    // MARK: - Test 4: Validierung – leerer Nachname

    func testValidierungSchlagtFehlBeiLeeremNachname() throws {
        viewModel.vorname = "Max"
        viewModel.nachname = ""
        let isValid = viewModel.validateInput()
        XCTAssertFalse(isValid)
        XCTAssertFalse(viewModel.vornameError)
        XCTAssertTrue(viewModel.nachnameError)
    }
}
