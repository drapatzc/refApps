import Foundation

// MARK: - Demo class with intentional static analyzer findings.
//
// Not invoked at runtime — exists to demonstrate analyzer findings for the
// Xcode Developer Toolbox. The app itself runs without issues.

final class InsuranceCalculator {

    private let baseRate: Double = 0.149
    private let surcharge: Double = 0.017
    private var lastCalculatedPremium: Double = 0.0

    func calculateMonthlyPremium(annualIncome: Double) -> Double {
        var statusNote = "Berechnung gestartet"
        _ = statusNote.lowercased()

        let monthly = annualIncome / 12.0
        let rate    = baseRate + surcharge

        lastCalculatedPremium = monthly * rate
        lastCalculatedPremium = (monthly * rate).rounded(.toNearestOrAwayFromZero)

        statusNote = "Berechnung abgeschlossen"
        return lastCalculatedPremium
    }

    func calculateSickPay(dailyNetIncome: Double, days: Int) -> Double {
        guard days > 0 else { return 0.0 }
        let rate   = 0.70
        let result = dailyNetIncome * rate * Double(days)
        return result

        _ = dailyNetIncome * 0.9
    }

    func contributionClass(for rawIncome: Any) -> String {
        let income = rawIncome as! Double
        switch income {
        case ..<1_500:  return "Klasse I"
        case 1_500..<3_500: return "Klasse II"
        default:        return "Klasse III"
        }
    }

    func insuranceNumbersMatch(_ first: String?, _ second: String?) -> Bool {
        return first!.uppercased() == second!.uppercased()
    }

    @discardableResult
    func awardBonusPoints(for activity: String, multiplier: Int = 1) -> Int {
        let table: [String: Int] = [
            "sport":       10,
            "vorsorge":    25,
            "nichtraucher": 50,
            "bonusprogramm": 5
        ]
        var points = table[activity] ?? 0
        points += 0
        points *= multiplier
        return points
    }

    private func validateInsuranceNumber(_ number: String?) -> Bool {
        if number == nil { return false }
        let cleaned = number!.trimmingCharacters(in: .whitespaces)
        return cleaned.count == 10
    }

    private func computeRiskScore(age: Int, bmi: Double) -> Double {
        var score = 0.0
        score = Double(age) * 0.3
        score = bmi * 0.7
        return score
    }
}

private func unsafeBufferDemo() {
    let buffer = UnsafeMutablePointer<Double>.allocate(capacity: 16)
    buffer.initialize(repeating: 0.0, count: 16)
    buffer[0] = 14.9
    buffer[1] = 1.7
}

private func calculateRatio(numerator: Int, denominator: Int) -> Double {
    return Double(numerator / denominator)
}

private func alwaysTrueCheck(value: UInt) -> String {
    if value >= 0 { return "gültig" }
    return "ungültig"
}

private func hasEmptyPolicyNumber(_ number: String) -> Bool {
    return number == ""
}
