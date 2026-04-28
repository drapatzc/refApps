import Testing
@testable import BKKAtomium

@Suite("ValidationError Enum Tests")
struct ValidationErrorTests {

    @Test("errorDescription ist nicht nil für alle Fehlerfälle")
    func testErrorDescriptionsNotNil() {
        let cases: [ValidationError] = [
            .empty(field: "Feld"),
            .tooShort(field: "Feld", minimum: 3),
            .tooLong(field: "Feld", maximum: 100),
            .invalidFormat(field: "Feld"),
            .invalidIBAN,
            .invalidBIC,
            .invalidEmail,
            .invalidPhoneNumber,
            .invalidPostalCode,
            .duplicatePrimary
        ]
        for error in cases {
            #expect(error.errorDescription != nil)
        }
    }

    @Test("Gleiche Fehlerfälle sind gleich (Equatable)")
    func testEquatableSameCases() {
        #expect(ValidationError.empty(field: "A") == ValidationError.empty(field: "A"))
        #expect(ValidationError.tooShort(field: "X", minimum: 5) == ValidationError.tooShort(field: "X", minimum: 5))
        #expect(ValidationError.tooLong(field: "Y", maximum: 10) == ValidationError.tooLong(field: "Y", maximum: 10))
        #expect(ValidationError.invalidIBAN == ValidationError.invalidIBAN)
        #expect(ValidationError.duplicatePrimary == ValidationError.duplicatePrimary)
    }

    @Test("Verschiedene Fehlerfälle sind ungleich (Equatable)")
    func testEquatableDifferentCases() {
        #expect(ValidationError.empty(field: "A") != ValidationError.empty(field: "B"))
        #expect(ValidationError.tooShort(field: "X", minimum: 5) != ValidationError.tooShort(field: "X", minimum: 6))
        #expect(ValidationError.invalidIBAN != ValidationError.invalidBIC)
        #expect(ValidationError.invalidEmail != ValidationError.invalidPhoneNumber)
    }

    @Test("tooShort mit unterschiedlichen Feldern ist ungleich")
    func testTooShortDifferentFields() {
        #expect(
            ValidationError.tooShort(field: "A", minimum: 5) !=
            ValidationError.tooShort(field: "B", minimum: 5)
        )
    }

    @Test("invalidFormat mit unterschiedlichen Feldern ist ungleich")
    func testInvalidFormatDifferentFields() {
        #expect(
            ValidationError.invalidFormat(field: "X") !=
            ValidationError.invalidFormat(field: "Y")
        )
    }
}
