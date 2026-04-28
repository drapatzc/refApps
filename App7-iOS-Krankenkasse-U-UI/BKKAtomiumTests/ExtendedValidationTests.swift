import Testing
@testable import BKKAtomium

// MARK: - Erweiterte Adress-Validierung

@Suite("Erweiterte Adress-Validierung")
struct ExtendedAddressValidationTests {

    @Test("Leere Hausnummer ergibt Fehler")
    func testEmptyHouseNumber() {
        let errors = AddressValidator.validate(
            street: "Teststraße", houseNumber: "",
            postalCode: "45147", city: "Essen", country: "Deutschland"
        )
        #expect(!errors.isEmpty)
    }

    @Test("Leeres Land ergibt Fehler")
    func testEmptyCountry() {
        let errors = AddressValidator.validate(
            street: "Teststraße", houseNumber: "1",
            postalCode: "45147", city: "Essen", country: ""
        )
        #expect(!errors.isEmpty)
    }

    @Test("Nur-Leerzeichen-Straße ergibt empty-Fehler")
    func testWhitespaceOnlyStreet() {
        let errors = AddressValidator.validate(
            street: "   ", houseNumber: "1",
            postalCode: "45147", city: "Essen", country: "Deutschland"
        )
        #expect(!errors.isEmpty)
    }

    @Test("Nicht-deutsche PLZ mit 3-10 Zeichen wird akzeptiert")
    func testNonGermanPostalCode() {
        let errors = AddressValidator.validate(
            street: "Main Street", houseNumber: "42",
            postalCode: "SW1A", city: "London", country: "Großbritannien"
        )
        #expect(errors.isEmpty)
    }

    @Test("6-stellige deutsche PLZ ist ungültig")
    func testSixDigitGermanPostalCode() {
        let errors = AddressValidator.validate(
            street: "Teststraße", houseNumber: "1",
            postalCode: "451470", city: "Essen", country: "Deutschland"
        )
        #expect(errors.contains(.invalidPostalCode))
    }

    @Test("5-stellige PLZ mit Buchstaben ist für Deutschland ungültig")
    func testAlphaGermanPostalCode() {
        let errors = AddressValidator.validate(
            street: "Teststraße", houseNumber: "1",
            postalCode: "4514A", city: "Essen", country: "Deutschland"
        )
        #expect(errors.contains(.invalidPostalCode))
    }

    @Test("Germany (englisch) als Land wird für PLZ-Prüfung wie Deutschland behandelt")
    func testEnglishGermanyPostalCode() {
        let errors = AddressValidator.validate(
            street: "Teststraße", houseNumber: "1",
            postalCode: "45147", city: "Essen", country: "Germany"
        )
        #expect(errors.isEmpty)
    }

    @Test("Straße über 100 Zeichen ist zu lang")
    func testTooLongStreet() {
        let longStreet = String(repeating: "A", count: 101)
        let errors = AddressValidator.validate(
            street: longStreet, houseNumber: "1",
            postalCode: "45147", city: "Essen", country: "Deutschland"
        )
        #expect(!errors.isEmpty)
    }

    @Test("Alle leeren Felder erzeugen mehrere Fehler")
    func testAllEmptyFields() {
        let errors = AddressValidator.validate(
            street: "", houseNumber: "", postalCode: "", city: "", country: ""
        )
        #expect(errors.count >= 4)
    }

    @Test("Nicht-deutsche PLZ unter 3 Zeichen ist ungültig")
    func testTooShortNonGermanPostalCode() {
        let errors = AddressValidator.validate(
            street: "Test St", houseNumber: "1",
            postalCode: "AB", city: "London", country: "Großbritannien"
        )
        #expect(errors.contains(.invalidPostalCode))
    }
}

// MARK: - Erweiterte Telefon-Validierung

@Suite("Erweiterte Telefon-Validierung")
struct ExtendedPhoneValidationTests {

    @Test("Genau 6 Zeichen (Minimum) sind gültig")
    func testExactMinimumLength() {
        let errors = PhoneValidator.validate(number: "123456")
        #expect(errors.isEmpty)
    }

    @Test("Genau 20 Zeichen (Maximum) sind gültig")
    func testExactMaximumLength() {
        let twentyChars = "01234567890123456789" // 20 digits
        let errors = PhoneValidator.validate(number: twentyChars)
        #expect(errors.isEmpty)
    }

    @Test("21 Zeichen überschreiten das Maximum")
    func testTooLongPhoneNumber() {
        let longNumber = String(repeating: "1", count: 21)
        let errors = PhoneValidator.validate(number: longNumber)
        #expect(errors.contains(.tooLong(field: "Rufnummer", maximum: 20)))
    }

    @Test("Nur Leerzeichen ergibt empty-Fehler")
    func testWhitespaceOnlyPhone() {
        let errors = PhoneValidator.validate(number: "   ")
        #expect(!errors.isEmpty)
    }

    @Test("Telefonnummer mit @ ist ungültig")
    func testAtSignInPhone() {
        let errors = PhoneValidator.validate(number: "+49@12345")
        #expect(!errors.isEmpty)
    }

    @Test("Telefonnummer mit Buchstaben ist ungültig")
    func testLettersInPhone() {
        let errors = PhoneValidator.validate(number: "0201abc456")
        #expect(errors.contains(.invalidPhoneNumber))
    }

    @Test("Telefonnummer mit gültigen Sonderzeichen ist gültig")
    func testValidSpecialChars() {
        let errors = PhoneValidator.validate(number: "(0201) 123-456")
        #expect(errors.isEmpty)
    }
}

// MARK: - Erweiterte E-Mail-Validierung

@Suite("Erweiterte E-Mail-Validierung")
struct ExtendedEmailValidationTests {

    @Test("E-Mail über 254 Zeichen ergibt tooLong-Fehler")
    func testTooLongEmail() {
        let longLocal = String(repeating: "a", count: 250)
        let longEmail = "\(longLocal)@t.de" // 255 Zeichen > 254
        let errors = EmailValidator.validate(email: longEmail)
        #expect(!errors.isEmpty)
    }

    @Test("Nur Leerzeichen ergibt empty-Fehler")
    func testWhitespaceOnlyEmail() {
        let errors = EmailValidator.validate(email: "   ")
        #expect(errors.contains(.empty(field: "E-Mail")))
    }

    @Test("E-Mail mit Subdomain wird akzeptiert")
    func testSubdomainEmail() {
        #expect(EmailValidator.isValidEmail("user@mail.example.de") == true)
    }

    @Test("E-Mail ohne TLD wird abgelehnt")
    func testEmailWithoutTLD() {
        #expect(EmailValidator.isValidEmail("user@domain") == false)
    }

    @Test("E-Mail mit Leerzeichen im Domain wird abgelehnt")
    func testEmailWithSpaceInDomain() {
        #expect(EmailValidator.isValidEmail("user@do main.de") == false)
    }

    @Test("isValidEmail mit führendem Leerzeichen gibt false zurück")
    func testEmailWithLeadingSpace() {
        #expect(EmailValidator.isValidEmail(" user@domain.de") == false)
    }
}

// MARK: - Erweiterte IBAN/BIC-Validierung

@Suite("Erweiterte IBAN/BIC-Validierung")
struct ExtendedBankValidationTests {

    @Test("IBAN mit falscher Prüfsumme ist ungültig")
    func testIBANWrongChecksum() {
        #expect(BankAccountValidator.isValidIBAN("DE00370400440532013000") == false)
    }

    @Test("IBAN unter 15 Zeichen ist ungültig")
    func testTooShortIBAN() {
        #expect(BankAccountValidator.isValidIBAN("DE893704") == false)
    }

    @Test("IBAN über 34 Zeichen ist ungültig")
    func testTooLongIBAN() {
        let longIBAN = "DE" + String(repeating: "1", count: 33)
        #expect(BankAccountValidator.isValidIBAN(longIBAN) == false)
    }

    @Test("IBAN ohne Länderkennzeichen-Buchstaben ist ungültig")
    func testIBANWithoutLetterPrefix() {
        #expect(BankAccountValidator.isValidIBAN("1289370400440532013000") == false)
    }

    @Test("Leere IBAN ergibt empty(IBAN)-Fehler bei validate()")
    func testEmptyIBANInValidate() {
        let errors = BankAccountValidator.validate(
            iban: "", bic: "COBADEFFXXX",
            bankName: "Test Bank", accountHolder: "Test User"
        )
        #expect(errors.contains(.empty(field: "IBAN")))
    }

    @Test("Leere BIC ergibt empty(BIC)-Fehler bei validate()")
    func testEmptyBICInValidate() {
        let errors = BankAccountValidator.validate(
            iban: "DE89370400440532013000", bic: "",
            bankName: "Test Bank", accountHolder: "Test User"
        )
        #expect(errors.contains(.empty(field: "BIC")))
    }

    @Test("Konto-Inhaber über 100 Zeichen ergibt Fehler")
    func testTooLongAccountHolder() {
        let longName = String(repeating: "A", count: 101)
        let errors = BankAccountValidator.validate(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Test Bank", accountHolder: longName
        )
        #expect(!errors.isEmpty)
    }

    @Test("BIC mit Leerzeichen im Prefix ist ungültig")
    func testBICWithSpaceInPrefix() {
        #expect(BankAccountValidator.isValidBIC("COBA DEFF") == false)
    }

    @Test("Ungültige IBAN ergibt invalidIBAN-Fehler bei validate()")
    func testInvalidIBANInValidate() {
        let errors = BankAccountValidator.validate(
            iban: "NOTANIBAN", bic: "COBADEFFXXX",
            bankName: "Test Bank", accountHolder: "Test User"
        )
        #expect(errors.contains(.invalidIBAN))
    }
}
