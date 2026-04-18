import Testing
@testable import BKKAtomium

// MARK: - Email Validation Tests

/// Unit tests for `EmailValidator`, covering format validation, empty-field errors, and full validation.
@Suite("Email Validation Tests")
struct EmailValidationTests {

    /// Verifies that syntactically valid email addresses pass `isValidEmail(_:)`.
    @Test("Gültige E-Mail-Adressen werden akzeptiert")
    func testValidEmails() {
        #expect(EmailValidator.isValidEmail("c.drapatz@gmx.de") == true)
        #expect(EmailValidator.isValidEmail("c.drapatz@handelsblatt.de") == true)
        #expect(EmailValidator.isValidEmail("user+tag@domain.org") == true)
        #expect(EmailValidator.isValidEmail("info@bkk-atomium.de") == true)
    }

    /// Verifies that malformed email addresses are rejected by `isValidEmail(_:)`.
    @Test("Ungültige E-Mail-Adressen werden abgelehnt")
    func testInvalidEmails() {
        #expect(EmailValidator.isValidEmail("") == false)
        #expect(EmailValidator.isValidEmail("noDomain") == false)
        #expect(EmailValidator.isValidEmail("@domain.de") == false)
        #expect(EmailValidator.isValidEmail("user@") == false)
        #expect(EmailValidator.isValidEmail("user@domain") == false)
        #expect(EmailValidator.isValidEmail("user @domain.de") == false)
    }

    /// Verifies that `validate(email:)` returns an `.empty` error when the email string is empty.
    @Test("Leere E-Mail ergibt empty-Fehler")
    func testEmptyEmailValidation() {
        let errors = EmailValidator.validate(email: "")
        #expect(errors.contains(.empty(field: "E-Mail")))
    }

    /// Verifies that `validate(email:)` returns `.invalidEmail` for a string without a valid email format.
    @Test("Ungültige E-Mail ergibt invalidEmail-Fehler")
    func testInvalidEmailValidation() {
        let errors = EmailValidator.validate(email: "notanemail")
        #expect(errors.contains(.invalidEmail))
    }

    /// Verifies that `validate(email:)` returns no errors for a valid email address.
    @Test("Gültige E-Mail erzeugt keinen Fehler")
    func testValidEmailValidation() {
        let errors = EmailValidator.validate(email: "c.drapatz@gmx.de")
        #expect(errors.isEmpty)
    }
}

// MARK: - IBAN Validation Tests

/// Unit tests for `BankAccountValidator.isValidIBAN(_:)` and the full `validate(iban:bic:bankName:accountHolder:)` method.
@Suite("IBAN Validation Tests")
struct IBANValidationTests {

    /// Verifies that valid German IBANs (22-character, correct checksum) pass `isValidIBAN(_:)`.
    @Test("Gültige deutsche IBANs werden akzeptiert")
    func testValidGermanIBANs() {
        #expect(BankAccountValidator.isValidIBAN("DE89370400440532013000") == true)
        #expect(BankAccountValidator.isValidIBAN("DE44500105175407324931") == true)
    }

    /// Verifies that empty strings, IBANs with invalid checksums, and non-IBAN strings are rejected.
    @Test("Ungültige IBANs werden abgelehnt")
    func testInvalidIBANs() {
        #expect(BankAccountValidator.isValidIBAN("") == false)
        #expect(BankAccountValidator.isValidIBAN("DE00000000000000000000") == false)
        #expect(BankAccountValidator.isValidIBAN("NOTANIBAN") == false)
        #expect(BankAccountValidator.isValidIBAN("DE8937040044053201300") == false)
    }

    /// Verifies that a formatted IBAN containing spaces is accepted by the full validation method.
    @Test("IBAN mit Leerzeichen wird korrekt validiert")
    func testIBANWithSpaces() {
        let errors = BankAccountValidator.validate(
            iban: "DE89 3704 0044 0532 0130 00",
            bic: "COBADEFFXXX",
            bankName: "Commerzbank AG",
            accountHolder: "Christian Drapatz"
        )
        #expect(errors.isEmpty)
    }
}

// MARK: - BIC Validation Tests

/// Unit tests for `BankAccountValidator.isValidBIC(_:)`.
@Suite("BIC Validation Tests")
struct BICValidationTests {

    /// Verifies that both 8-character and 11-character BICs with valid structure are accepted.
    @Test("Gültige BICs werden akzeptiert")
    func testValidBICs() {
        // 11-stellige BICs (mit Branch-Code)
        #expect(BankAccountValidator.isValidBIC("COBADEFFXXX") == true)  // Commerzbank
        #expect(BankAccountValidator.isValidBIC("SSKMDEMMXXX") == true)  // Stadtsparkasse München
        // 8-stellige BICs (ohne Branch-Code)
        #expect(BankAccountValidator.isValidBIC("DEUTDEDB") == true)     // Deutsche Bank
        #expect(BankAccountValidator.isValidBIC("COBADEFF") == true)     // Commerzbank kurz
        #expect(BankAccountValidator.isValidBIC("BELADEBE") == true)     // Berliner Sparkasse
    }

    /// Verifies that empty strings, wrong lengths, numeric prefixes, and BICs between 8 and 11 characters are rejected.
    @Test("Ungültige BICs werden abgelehnt")
    func testInvalidBICs() {
        // Leer
        #expect(BankAccountValidator.isValidBIC("") == false)
        // Zu kurz: < 8 Zeichen
        #expect(BankAccountValidator.isValidBIC("COBAD") == false)       // 5 Zeichen
        #expect(BankAccountValidator.isValidBIC("COBADE") == false)      // 6 Zeichen
        #expect(BankAccountValidator.isValidBIC("COBADEFF1") == false)   // 9 Zeichen (zwischen 8 und 11)
        #expect(BankAccountValidator.isValidBIC("COBADEFF12") == false)  // 10 Zeichen (zwischen 8 und 11)
        // Erste 6 Zeichen müssen Buchstaben sein
        #expect(BankAccountValidator.isValidBIC("123ABCDE") == false)    // beginnt mit Ziffern
        #expect(BankAccountValidator.isValidBIC("COBA1EFF") == false)    // Ziffer an Position 5
        // Zu lang: > 11 Zeichen
        #expect(BankAccountValidator.isValidBIC("TOOLONGBICCODE123") == false)
    }
}

// MARK: - Phone Validation Tests

/// Unit tests for `PhoneValidator.validate(number:)`.
@Suite("Phone Validation Tests")
struct PhoneValidationTests {

    /// Verifies that phone numbers in various common formats (international, local, with separators) pass validation.
    @Test("Gültige Rufnummern werden akzeptiert")
    func testValidPhoneNumbers() {
        #expect(PhoneValidator.validate(number: "+49 170 9876543").isEmpty)
        #expect(PhoneValidator.validate(number: "0201 1234567").isEmpty)
        #expect(PhoneValidator.validate(number: "+49-201-12345678").isEmpty)
        #expect(PhoneValidator.validate(number: "(0201) 123456").isEmpty)
    }

    /// Verifies that an empty phone number string produces a validation error.
    @Test("Leere Rufnummer ergibt Fehler")
    func testEmptyPhoneNumber() {
        let errors = PhoneValidator.validate(number: "")
        #expect(!errors.isEmpty)
    }

    /// Verifies that a phone number shorter than the minimum length produces a `.tooShort` error.
    @Test("Zu kurze Rufnummer ergibt Fehler")
    func testTooShortPhoneNumber() {
        let errors = PhoneValidator.validate(number: "123")
        #expect(errors.contains(.tooShort(field: "Rufnummer", minimum: 6)))
    }

    /// Verifies that a phone number containing alphabetic characters produces a validation error.
    @Test("Rufnummer mit ungültigen Zeichen ergibt Fehler")
    func testPhoneWithInvalidChars() {
        let errors = PhoneValidator.validate(number: "abc123def")
        #expect(!errors.isEmpty)
    }
}

// MARK: - Address Validation Tests

/// Unit tests for `AddressValidator.validate(street:houseNumber:postalCode:city:country:)`.
@Suite("Address Validation Tests")
struct AddressValidationTests {

    /// Verifies that a fully specified valid German address produces no validation errors.
    @Test("Gültige Adresse wird akzeptiert")
    func testValidAddress() {
        let errors = AddressValidator.validate(
            street: "Am Mühlenbach",
            houseNumber: "105",
            postalCode: "45147",
            city: "Essen",
            country: "Deutschland"
        )
        #expect(errors.isEmpty)
    }

    /// Verifies that an empty street field produces a validation error.
    @Test("Leere Straße ergibt Fehler")
    func testEmptyStreet() {
        let errors = AddressValidator.validate(
            street: "",
            houseNumber: "105",
            postalCode: "45147",
            city: "Essen",
            country: "Deutschland"
        )
        #expect(!errors.isEmpty)
    }

    /// Verifies that a four-digit postal code (invalid for Germany) produces an `.invalidPostalCode` error.
    @Test("Ungültige PLZ ergibt Fehler")
    func testInvalidPostalCode() {
        let errors = AddressValidator.validate(
            street: "Am Mühlenbach",
            houseNumber: "105",
            postalCode: "4514",   // nur 4 Ziffern — ungültig für DE
            city: "Essen",
            country: "Deutschland"
        )
        #expect(errors.contains(.invalidPostalCode))
    }

    /// Verifies that an empty city field produces a validation error.
    @Test("Leerer Ort ergibt Fehler")
    func testEmptyCity() {
        let errors = AddressValidator.validate(
            street: "Am Mühlenbach",
            houseNumber: "105",
            postalCode: "45147",
            city: "",
            country: "Deutschland"
        )
        #expect(!errors.isEmpty)
    }
}

// MARK: - BankAccount Full Validation

/// Unit tests for `BankAccountValidator.validate(iban:bic:bankName:accountHolder:)`.
@Suite("BankAccount Full Validation Tests")
struct BankAccountFullValidationTests {

    /// Verifies that a fully specified, valid bank account produces no validation errors.
    @Test("Vollständige Bankdaten ohne Fehler")
    func testValidBankAccount() {
        let errors = BankAccountValidator.validate(
            iban: "DE89370400440532013000",
            bic: "COBADEFFXXX",
            bankName: "Commerzbank AG",
            accountHolder: "Christian Drapatz"
        )
        #expect(errors.isEmpty)
    }

    /// Verifies that an empty account holder field produces a validation error.
    @Test("Leerer Kontoinhaber ergibt Fehler")
    func testEmptyAccountHolder() {
        let errors = BankAccountValidator.validate(
            iban: "DE89370400440532013000",
            bic: "COBADEFFXXX",
            bankName: "Commerzbank AG",
            accountHolder: ""
        )
        #expect(!errors.isEmpty)
    }

    /// Verifies that an empty bank name field produces a validation error.
    @Test("Leere Bank ergibt Fehler")
    func testEmptyBankName() {
        let errors = BankAccountValidator.validate(
            iban: "DE89370400440532013000",
            bic: "COBADEFFXXX",
            bankName: "",
            accountHolder: "Christian Drapatz"
        )
        #expect(!errors.isEmpty)
    }
}
