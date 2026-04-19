import Testing
@testable import BKKOrano

// MARK: - Email

@Suite("Email validation")
struct EmailValidationTests {

    @Test("Accepts well-formed addresses")
    func acceptsValid() {
        #expect(EmailValidator.isValidEmail("hello@example.com"))
        #expect(EmailValidator.isValidEmail("first.last+tag@sub.example.co"))
    }

    @Test("Rejects malformed addresses")
    func rejectsInvalid() {
        #expect(!EmailValidator.isValidEmail(""))
        #expect(!EmailValidator.isValidEmail("not-an-email"))
        #expect(!EmailValidator.isValidEmail("a@b"))
        #expect(!EmailValidator.isValidEmail("a@b.c"))
    }

    @Test("Empty email surfaces empty error")
    func emptyEmailSurfacesEmpty() {
        let errors = EmailValidator.validate(email: "   ")
        #expect(errors.contains { if case .empty = $0 { true } else { false } })
    }

    @Test("Invalid format surfaces invalidEmail")
    func invalidFormatSurfacesError() {
        let errors = EmailValidator.validate(email: "nope")
        #expect(errors.contains(.invalidEmail))
    }
}

// MARK: - IBAN

@Suite("IBAN validation")
struct IBANValidationTests {

    @Test("Accepts valid German IBANs")
    func acceptsValidGermanIBANs() {
        #expect(BankAccountValidator.isValidIBAN("DE89370400440532013000"))
        #expect(BankAccountValidator.isValidIBAN("DE44500105175407324931"))
    }

    @Test("Accepts IBAN with spaces (after normalization)")
    func acceptsSpacedIBAN() {
        #expect(BankAccountValidator.isValidIBAN("DE89 3704 0044 0532 0130 00"))
    }

    @Test("Rejects invalid IBANs")
    func rejectsInvalidIBANs() {
        #expect(!BankAccountValidator.isValidIBAN(""))
        #expect(!BankAccountValidator.isValidIBAN("DE0000000000"))
        #expect(!BankAccountValidator.isValidIBAN("XX89370400440532013000"))
    }
}

// MARK: - BIC

@Suite("BIC validation")
struct BICValidationTests {

    @Test("Accepts 8- and 11-char BICs")
    func acceptsValidBICs() {
        #expect(BankAccountValidator.isValidBIC("COBADEFFXXX"))
        #expect(BankAccountValidator.isValidBIC("DEUTDEDB"))
    }

    @Test("Rejects malformed BICs")
    func rejectsInvalidBICs() {
        #expect(!BankAccountValidator.isValidBIC(""))
        #expect(!BankAccountValidator.isValidBIC("ABC"))
        #expect(!BankAccountValidator.isValidBIC("lowercase"))
    }
}

// MARK: - Phone

@Suite("Phone validation")
struct PhoneValidationTests {

    @Test("Accepts typical formats")
    func acceptsTypicalFormats() {
        #expect(PhoneValidator.validate(number: "+49 170 1234567").isEmpty)
        #expect(PhoneValidator.validate(number: "(030) 123-456").isEmpty)
    }

    @Test("Rejects empty and too-short")
    func rejectsInvalid() {
        #expect(!PhoneValidator.validate(number: "").isEmpty)
        #expect(!PhoneValidator.validate(number: "12").isEmpty)
    }

    @Test("Rejects letters in phone number")
    func rejectsLetters() {
        let errors = PhoneValidator.validate(number: "0800ABCDEF")
        #expect(errors.contains(.invalidPhoneNumber))
    }
}

// MARK: - Address

@Suite("Address validation")
struct AddressValidationTests {

    @Test("Accepts full German address")
    func acceptsValidGermanAddress() {
        let errors = AddressValidator.validate(
            street: "Musterstraße",
            houseNumber: "1",
            postalCode: "12345",
            city: "Berlin",
            country: "Deutschland"
        )
        #expect(errors.isEmpty)
    }

    @Test("Rejects wrong German postal-code length")
    func rejectsWrongPostalCode() {
        let errors = AddressValidator.validate(
            street: "Musterstraße",
            houseNumber: "1",
            postalCode: "1234",
            city: "Berlin",
            country: "Deutschland"
        )
        #expect(errors.contains(.invalidPostalCode))
    }
}
