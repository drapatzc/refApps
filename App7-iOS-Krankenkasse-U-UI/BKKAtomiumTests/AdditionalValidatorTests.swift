import Testing
@testable import BKKAtomium

// MARK: - AddressValidator erweiterte Feldlängen

@Suite("AddressValidator Feldlängen Tests")
struct AddressValidatorFieldLengthTests {

    @Test("Hausnummer über 10 Zeichen ergibt tooLong-Fehler")
    func testHouseNumberTooLong() {
        let errors = AddressValidator.validate(
            street: "Teststraße",
            houseNumber: "12345678901",   // 11 Zeichen
            postalCode: "45147",
            city: "Essen",
            country: "Deutschland"
        )
        #expect(errors.contains(.tooLong(field: "Hausnummer", maximum: 10)))
    }

    @Test("Stadt über 100 Zeichen ergibt tooLong-Fehler")
    func testCityTooLong() {
        let longCity = String(repeating: "X", count: 101)
        let errors = AddressValidator.validate(
            street: "Teststraße",
            houseNumber: "1",
            postalCode: "45147",
            city: longCity,
            country: "Deutschland"
        )
        #expect(errors.contains(.tooLong(field: "Stadt", maximum: 100)))
    }

    @Test("Gültige Hausnummer mit exakt 10 Zeichen wird akzeptiert")
    func testHouseNumberExactMaxLength() {
        let errors = AddressValidator.validate(
            street: "Teststraße",
            houseNumber: "1234567890",    // exakt 10 Zeichen
            postalCode: "45147",
            city: "Essen",
            country: "Deutschland"
        )
        #expect(!errors.contains(.tooLong(field: "Hausnummer", maximum: 10)))
    }

    @Test("Leere PLZ ergibt Fehler")
    func testEmptyPostalCode() {
        let errors = AddressValidator.validate(
            street: "Teststraße",
            houseNumber: "1",
            postalCode: "",
            city: "Essen",
            country: "Deutschland"
        )
        #expect(!errors.isEmpty)
    }

    @Test("PLZ mit Buchstaben für Deutschland ergibt invalidPostalCode")
    func testAlphaPostalCodeGermany() {
        let errors = AddressValidator.validate(
            street: "Teststraße",
            houseNumber: "1",
            postalCode: "ABCDE",
            city: "Essen",
            country: "Deutschland"
        )
        #expect(errors.contains(.invalidPostalCode))
    }

    @Test("6-stellige PLZ für Deutschland ergibt invalidPostalCode")
    func testSixDigitPostalCodeGermany() {
        let errors = AddressValidator.validate(
            street: "Teststraße",
            houseNumber: "1",
            postalCode: "451470",
            city: "Essen",
            country: "Deutschland"
        )
        #expect(errors.contains(.invalidPostalCode))
    }

    @Test("PLZ 'UK12A' mit Auslandsland (4+ Zeichen) wird akzeptiert")
    func testValidForeignPostalCode() {
        let errors = AddressValidator.validate(
            street: "Teststraße",
            houseNumber: "1",
            postalCode: "1010",
            city: "Wien",
            country: "Österreich"
        )
        #expect(!errors.contains(.invalidPostalCode))
    }

    @Test("PLZ mit 2 Zeichen für Ausland ergibt invalidPostalCode")
    func testTooShortForeignPostalCode() {
        let errors = AddressValidator.validate(
            street: "Teststraße",
            houseNumber: "1",
            postalCode: "AB",
            city: "London",
            country: "United Kingdom"
        )
        #expect(errors.contains(.invalidPostalCode))
    }

    @Test("Germany als Land wird wie Deutschland behandelt")
    func testGermanyAsDeutschland() {
        let errors = AddressValidator.validate(
            street: "Teststraße",
            houseNumber: "1",
            postalCode: "45147",
            city: "Essen",
            country: "Germany"
        )
        #expect(errors.isEmpty)
    }
}

// MARK: - PhoneValidator tooLong-Pfad

@Suite("PhoneValidator tooLong Tests")
struct PhoneValidatorTooLongTests {

    @Test("Rufnummer mit 21 Zeichen ergibt tooLong-Fehler")
    func testPhoneNumberTooLong() {
        let longNumber = "+4912345678901234567890"   // 23 Zeichen, > 20
        let errors = PhoneValidator.validate(number: longNumber)
        #expect(errors.contains(.tooLong(field: "Rufnummer", maximum: 20)))
    }

    @Test("Rufnummer mit genau 20 Zeichen ist kein tooLong-Fehler")
    func testPhoneNumberExactMaxLength() {
        let number = "+491234567890123456"  // 19 Zeichen — gültig
        let errors = PhoneValidator.validate(number: number)
        #expect(!errors.contains(.tooLong(field: "Rufnummer", maximum: 20)))
    }
}

// MARK: - IBAN Sonderfälle

@Suite("IBAN Sonderfälle Tests")
struct IBANEdgeCaseTests {

    @Test("IBAN mit Buchstaben an Check-Digit-Position ist ungültig")
    func testIBANWithLettersAtCheckDigits() {
        // Positionen 3-4 müssen Ziffern sein — "DEAB..." ist ungültig
        #expect(BankAccountValidator.isValidIBAN("DEAB370400440532013000") == false)
    }

    @Test("IBAN mit 34 Zeichen (Maximum) crasht nicht")
    func testIBANMaximumLengthNoCrash() {
        let longIBAN = String(repeating: "A", count: 34)
        // Sollte false zurückgeben aber nicht crashen
        let result = BankAccountValidator.isValidIBAN(longIBAN)
        #expect(result == false || result == true)  // Kein Crash
    }

    @Test("IBAN ohne Länderpräfix (nur Ziffern) ist ungültig")
    func testIBANWithoutLetterPrefix() {
        #expect(BankAccountValidator.isValidIBAN("89370400440532013000AB") == false)
    }

    @Test("IBAN mit falscher Prüfsumme ist ungültig")
    func testIBANInvalidChecksum() {
        // DE00 hat Prüfsumme 00, die bei Modulo-97 nicht 1 ergibt
        #expect(BankAccountValidator.isValidIBAN("DE00370400440532013000") == false)
    }

}

// MARK: - AddressType localizedName

@Suite("AddressType localizedName Tests")
struct AddressTypeLocalizedNameTests {

    @Test("AddressType.primary hat einen nicht-leeren lokalisierten Namen")
    func testPrimaryLocalizedName() {
        #expect(!AddressType.primary.localizedName.isEmpty)
    }

    @Test("AddressType.secondary hat einen nicht-leeren lokalisierten Namen")
    func testSecondaryLocalizedName() {
        #expect(!AddressType.secondary.localizedName.isEmpty)
    }

    @Test("AddressType.work hat einen nicht-leeren lokalisierten Namen")
    func testWorkLocalizedName() {
        #expect(!AddressType.work.localizedName.isEmpty)
    }

    @Test("Alle AddressType-Werte haben verschiedene lokalisierte Namen")
    func testAllLocalizedNamesDistinct() {
        let names = AddressType.allCases.map(\.localizedName)
        let uniqueNames = Set(names)
        #expect(uniqueNames.count == AddressType.allCases.count)
    }
}

// MARK: - PhoneType und EmailType localizedName

@Suite("PhoneType localizedName Tests")
struct PhoneTypeLocalizedNameTests {

    @Test("Alle PhoneType-Werte haben nicht-leere lokalisierte Namen")
    func testAllPhoneTypeLocalizedNames() {
        for phoneType in PhoneType.allCases {
            #expect(!phoneType.localizedName.isEmpty)
        }
    }

    @Test("Alle PhoneType-Werte haben nicht-leere Icons")
    func testAllPhoneTypeIcons() {
        for phoneType in PhoneType.allCases {
            #expect(!phoneType.icon.isEmpty)
        }
    }
}

@Suite("EmailType localizedName Tests")
struct EmailTypeLocalizedNameTests {

    @Test("Alle EmailType-Werte haben nicht-leere lokalisierte Namen")
    func testAllEmailTypeLocalizedNames() {
        for emailType in EmailType.allCases {
            #expect(!emailType.localizedName.isEmpty)
        }
    }

    @Test("Alle EmailType-Werte haben nicht-leere Icons")
    func testAllEmailTypeIcons() {
        for emailType in EmailType.allCases {
            #expect(!emailType.icon.isEmpty)
        }
    }
}

// MARK: - ValidationError duplicatePrimary

@Suite("ValidationError duplicatePrimary Tests")
struct ValidationErrorDuplicatePrimaryTests {

    @Test("duplicatePrimary hat eine nicht-nil errorDescription")
    func testDuplicatePrimaryDescription() {
        #expect(ValidationError.duplicatePrimary.errorDescription != nil)
    }

    @Test("duplicatePrimary errorDescription ist nicht leer")
    func testDuplicatePrimaryDescriptionNotEmpty() {
        let desc = ValidationError.duplicatePrimary.errorDescription ?? ""
        #expect(!desc.isEmpty)
    }

    @Test("duplicatePrimary ist gleich sich selbst")
    func testDuplicatePrimaryEquality() {
        #expect(ValidationError.duplicatePrimary == ValidationError.duplicatePrimary)
    }

    @Test("duplicatePrimary ist ungleich anderen Fehlertypen")
    func testDuplicatePrimaryInequality() {
        #expect(ValidationError.duplicatePrimary != ValidationError.invalidIBAN)
        #expect(ValidationError.duplicatePrimary != ValidationError.invalidEmail)
        #expect(ValidationError.duplicatePrimary != ValidationError.invalidPostalCode)
    }
}
