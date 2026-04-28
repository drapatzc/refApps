import Testing
@testable import BKKAtomium

@Suite("InsuranceCalculator Tests")
struct InsuranceCalculatorTests {

    let calculator = InsuranceCalculator()

    // MARK: - Monatsbeitrag

    @Test("calculateMonthlyPremium für 60.000 € Jahresgehalt ergibt 830 €")
    func testMonthlyPremium60k() {
        // (60000 / 12) * (0.149 + 0.017) = 5000 * 0.166 = 830.0
        let premium = calculator.calculateMonthlyPremium(annualIncome: 60_000)
        #expect(premium == 830.0)
    }

    @Test("calculateMonthlyPremium für 0 € ergibt 0 €")
    func testMonthlyPremiumZero() {
        let premium = calculator.calculateMonthlyPremium(annualIncome: 0)
        #expect(premium == 0.0)
    }

    @Test("calculateMonthlyPremium für 12.000 € ergibt 166 €")
    func testMonthlyPremium12k() {
        // (12000 / 12) * 0.166 = 1000 * 0.166 = 166.0
        let premium = calculator.calculateMonthlyPremium(annualIncome: 12_000)
        #expect(premium == 166.0)
    }

    // MARK: - Krankengeld

    @Test("calculateSickPay für 0 Tage ergibt 0")
    func testSickPayZeroDays() {
        let pay = calculator.calculateSickPay(dailyNetIncome: 100.0, days: 0)
        #expect(pay == 0.0)
    }

    @Test("calculateSickPay für negative Tage ergibt 0")
    func testSickPayNegativeDays() {
        let pay = calculator.calculateSickPay(dailyNetIncome: 100.0, days: -5)
        #expect(pay == 0.0)
    }

    @Test("calculateSickPay für 10 Tage bei 100 €/Tag ergibt 700 €")
    func testSickPayTenDays() {
        // 100 * 0.70 * 10 = 700.0
        let pay = calculator.calculateSickPay(dailyNetIncome: 100.0, days: 10)
        #expect(pay == 700.0)
    }

    @Test("calculateSickPay für 1 Tag ergibt 70% des Tageseinkommens")
    func testSickPayOneDay() {
        let pay = calculator.calculateSickPay(dailyNetIncome: 200.0, days: 1)
        #expect(pay == 140.0)
    }

    // MARK: - Bonuspunkte

    @Test("awardBonusPoints für bekannte Aktivitäten gibt korrekte Punkte zurück")
    func testBonusPointsKnownActivities() {
        #expect(calculator.awardBonusPoints(for: "sport") == 10)
        #expect(calculator.awardBonusPoints(for: "vorsorge") == 25)
        #expect(calculator.awardBonusPoints(for: "nichtraucher") == 50)
        #expect(calculator.awardBonusPoints(for: "bonusprogramm") == 5)
    }

    @Test("awardBonusPoints für unbekannte Aktivität ergibt 0")
    func testBonusPointsUnknownActivity() {
        #expect(calculator.awardBonusPoints(for: "unbekannt") == 0)
        #expect(calculator.awardBonusPoints(for: "") == 0)
    }

    @Test("awardBonusPoints mit Multiplikator 2 verdoppelt Punkte")
    func testBonusPointsWithMultiplier2() {
        #expect(calculator.awardBonusPoints(for: "sport", multiplier: 2) == 20)
        #expect(calculator.awardBonusPoints(for: "vorsorge", multiplier: 2) == 50)
        #expect(calculator.awardBonusPoints(for: "nichtraucher", multiplier: 2) == 100)
    }

    @Test("awardBonusPoints mit Multiplikator 0 ergibt 0")
    func testBonusPointsWithZeroMultiplier() {
        #expect(calculator.awardBonusPoints(for: "sport", multiplier: 0) == 0)
        #expect(calculator.awardBonusPoints(for: "vorsorge", multiplier: 0) == 0)
    }

    // MARK: - Beitragsklassen

    @Test("contributionClass gibt Klasse I für Einkommen unter 1.500 €")
    func testContributionClassI() {
        #expect(calculator.contributionClass(for: 0.0) == "Klasse I")
        #expect(calculator.contributionClass(for: 1_000.0) == "Klasse I")
        #expect(calculator.contributionClass(for: 1_499.99) == "Klasse I")
    }

    @Test("contributionClass gibt Klasse II für Einkommen 1.500 € bis unter 3.500 €")
    func testContributionClassII() {
        #expect(calculator.contributionClass(for: 1_500.0) == "Klasse II")
        #expect(calculator.contributionClass(for: 2_500.0) == "Klasse II")
        #expect(calculator.contributionClass(for: 3_499.99) == "Klasse II")
    }

    @Test("contributionClass gibt Klasse III für Einkommen ab 3.500 €")
    func testContributionClassIII() {
        #expect(calculator.contributionClass(for: 3_500.0) == "Klasse III")
        #expect(calculator.contributionClass(for: 10_000.0) == "Klasse III")
        #expect(calculator.contributionClass(for: 100_000.0) == "Klasse III")
    }

    // MARK: - Versicherungsnummern-Vergleich

    @Test("insuranceNumbersMatch vergleicht zwei gleiche Nummern case-insensitiv")
    func testInsuranceNumbersMatchEqual() {
        #expect(calculator.insuranceNumbersMatch("A987654321", "a987654321") == true)
        #expect(calculator.insuranceNumbersMatch("A987654321", "A987654321") == true)
    }

    @Test("insuranceNumbersMatch erkennt verschiedene Nummern")
    func testInsuranceNumbersMatchDifferent() {
        #expect(calculator.insuranceNumbersMatch("A987654321", "B123456789") == false)
    }
}
