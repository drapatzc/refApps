import Foundation

// MARK: - Demo-Datei: Absichtliche Static-Analyzer-Fundstellen
//
// Diese Klasse wurde als Testgrundlage für die Xcode Developer Toolbox
// eingebaut. Sie enthält bewusste Code-Schwächen, die der Static Analyzer
// (Xcode → Product → Analyze) sowie SwiftLint erkennen sollen.
//
// Die Klasse wird von der App NICHT aufgerufen und hat keinen Einfluss
// auf das Laufzeitverhalten. Die App läuft 100 % fehlerfrei.

// MARK: - Klasse mit Static-Analyzer-Fundstellen

/// A deliberately flawed demo class used to demonstrate static-analyzer findings
/// in the Xcode Developer Toolbox.
///
/// **This class is never called by the app at runtime.**
/// Every method contains intentional code weaknesses so that Xcode's Static
/// Analyzer (`Product ▸ Analyze`) and SwiftLint report findings.
/// See the inline comments for the specific issue in each method.
final class InsuranceCalculator {

    // MARK: - Properties

    /// Beitragssatz 2025 (14,9 % allgemein + 1,7 % Zusatzbeitrag BKK Atomium)
    private let baseRate: Double = 0.149

    /// The additional contribution surcharge for BKK Atomium (1.7 %).
    private let surcharge: Double = 0.017

    /// ⚠️ Dead Store — wird nur geschrieben, nie gelesen
    private var lastCalculatedPremium: Double = 0.0

    // MARK: - Beitragsberechnung

    /// Calculates the monthly insurance premium for the given annual gross income.
    ///
    /// **Intentional analyzer findings in this method:**
    /// - `var statusNote` should be `let` — the value is never mutated after assignment.
    /// - `lastCalculatedPremium` is written twice in a row without being read in between (Dead Store).
    ///
    /// - Parameter annualIncome: The insured person's annual gross income in euros.
    /// - Returns: The rounded monthly premium in euros.
    func calculateMonthlyPremium(annualIncome: Double) -> Double {
        // ⚠️ SwiftLint: identifier_name — einbuchstabige Variable
        // ⚠️ Static Analyzer: 'var' nie mutiert → sollte 'let' sein
        var statusNote = "Berechnung gestartet"                      // var, nie geändert
        _ = statusNote.lowercased()                                   // Einmalnutzung

        let monthly = annualIncome / 12.0
        let rate    = baseRate + surcharge

        // ⚠️ Dead Store: lastCalculatedPremium wird in der nächsten Zeile
        // sofort überschrieben, ohne vorher gelesen zu werden.
        lastCalculatedPremium = monthly * rate                        // 1. Zuweisung
        lastCalculatedPremium = (monthly * rate).rounded(.toNearestOrAwayFromZero) // 2. Zuweisung — 1. nie gelesen

        statusNote = "Berechnung abgeschlossen"                       // Neuzuweisung, nie gelesen danach
        return lastCalculatedPremium
    }

    // MARK: - Krankengeld

    /// Calculates the total sick pay for a given number of sick days.
    ///
    /// **Intentional analyzer finding:**
    /// - The expression after `return` is unreachable dead code.
    ///
    /// - Parameters:
    ///   - dailyNetIncome: The insured person's net income per day in euros.
    ///   - days: The number of sick days to calculate pay for.
    /// - Returns: The total sick-pay amount, or `0` if `days` is not positive.
    func calculateSickPay(dailyNetIncome: Double, days: Int) -> Double {
        guard days > 0 else { return 0.0 }

        let rate   = 0.70
        let result = dailyNetIncome * rate * Double(days)
        return result

        // ⚠️ Dead Code — dieser Ausdruck wird niemals ausgeführt
        _ = dailyNetIncome * 0.9                                      // nach return: unreachable
    }

    // MARK: - Beitragsklassen

    /// Returns the contribution class string for a given raw income value.
    ///
    /// **Intentional analyzer finding:**
    /// - `as!` force cast may crash at runtime if `rawIncome` is not a `Double`.
    ///
    /// - Parameter rawIncome: The raw income value; expected to be `Double`.
    /// - Returns: A contribution class string (`"Klasse I"`, `"Klasse II"`, or `"Klasse III"`).
    func contributionClass(for rawIncome: Any) -> String {
        // ⚠️ Force Cast — wird vom Analyzer als potenzielle Absturzquelle markiert
        let income = rawIncome as! Double                             // as! Force cast

        switch income {
        case ..<1_500:  return "Klasse I"
        case 1_500..<3_500: return "Klasse II"
        default:        return "Klasse III"
        }
    }

    // MARK: - Versicherungsnummer

    /// Checks whether two optional insurance numbers are identical (case-insensitive).
    ///
    /// **Intentional analyzer finding:**
    /// - Both parameters are force-unwrapped without a nil guard, which may crash
    ///   if either argument is `nil`.
    ///
    /// - Parameters:
    ///   - first: The first optional insurance number.
    ///   - second: The second optional insurance number.
    /// - Returns: `true` if both uppercased values are equal.
    func insuranceNumbersMatch(_ first: String?, _ second: String?) -> Bool {
        // ⚠️ Force Unwrap — Analyzer: potential nil dereference
        return first!.uppercased() == second!.uppercased()           // force unwrap optionals
    }

    // MARK: - Bonusprogramm

    /// Awards bonus points for a named activity and returns the total.
    ///
    /// **Intentional analyzer finding:**
    /// - `points += 0` is a dead operation with no effect on the result.
    ///
    /// - Parameters:
    ///   - activity: The activity key to look up in the points table
    ///     (e.g. `"sport"`, `"vorsorge"`, `"nichtraucher"`, `"bonusprogramm"`).
    ///   - multiplier: A multiplier applied to the base points; defaults to 1.
    /// - Returns: The final bonus points for the activity.
    @discardableResult
    func awardBonusPoints(for activity: String, multiplier: Int = 1) -> Int {
        let table: [String: Int] = [
            "sport":       10,
            "vorsorge":    25,
            "nichtraucher": 50,
            "bonusprogramm": 5
        ]

        var points = table[activity] ?? 0
        // ⚠️ Dead Operation — addiert 0, keine Auswirkung
        points += 0                                                   // nutzlose Operation
        points *= multiplier

        return points
    }

    // MARK: - Interne Hilfsmethoden (nie aufgerufen)

    /// Validates an optional insurance number string.
    ///
    /// **Intentional analyzer findings:**
    /// - Comparing an optional to `nil` with `==` is redundant; `guard let` is preferred.
    /// - The force unwrap immediately after the nil check should use `if let` instead.
    ///
    /// - Parameter number: The optional insurance number to validate.
    /// - Returns: `true` if the trimmed number has exactly 10 characters.
    private func validateInsuranceNumber(_ number: String?) -> Bool {
        // ⚠️ Redundanter nil-Vergleich — Analyzer empfiehlt guard/if-let
        if number == nil {
            return false
        }
        // ⚠️ Force Unwrap unmittelbar nach nil-Check — sollte if-let verwenden
        let cleaned = number!.trimmingCharacters(in: .whitespaces)   // force unwrap
        return cleaned.count == 10
    }

    /// Computes a simplified risk score from age and BMI.
    ///
    /// **Intentional analyzer findings:**
    /// - `score` is assigned three times; the first two assignments are dead stores
    ///   because each value is immediately overwritten without being read.
    ///
    /// - Parameters:
    ///   - age: The person's age in years.
    ///   - bmi: The person's body mass index.
    /// - Returns: The computed risk score (BMI × 0.7).
    private func computeRiskScore(age: Int, bmi: Double) -> Double {
        var score = 0.0                                               // ⚠️ Dead Store (Initialwert)
        score = Double(age) * 0.3                                     // ⚠️ Dead Store (sofort überschrieben)
        score = bmi * 0.7                                             // letzter Wert, dieser wird genutzt
        return score
    }
}

// MARK: - Freistehende Funktionen (nie aufgerufen)

/// Demonstrates a memory leak caused by an `UnsafeMutablePointer` that is never deallocated.
///
/// **Analyzer finding:**
/// - `UnsafeMutablePointer` is allocated but `.deallocate()` is never called.
///   Xcode Static Analyzer (Clang) reports: "Potential leak of memory pointed to by 'buffer'".
private func unsafeBufferDemo() {
    // ⚠️ Memory Leak — kein buffer.deallocate() am Ende
    let buffer = UnsafeMutablePointer<Double>.allocate(capacity: 16)
    buffer.initialize(repeating: 0.0, count: 16)
    buffer[0] = 14.9   // Beitragssatz
    buffer[1] = 1.7    // Zusatzbeitrag
    // Fehlend: buffer.deallocate()  ← Static Analyzer meldet Leak
}

/// Divides two integers without guarding against a zero denominator.
///
/// **Analyzer finding:**
/// - No guard or check prevents `denominator == 0`, which causes a division-by-zero crash.
///
/// - Parameters:
///   - numerator: The dividend.
///   - denominator: The divisor; must not be zero.
/// - Returns: The integer quotient converted to `Double`.
private func calculateRatio(numerator: Int, denominator: Int) -> Double {
    // ⚠️ Mögliche Division durch 0 — kein Guard/Prüfung
    return Double(numerator / denominator)
}

/// Returns a validity string for a `UInt` value.
///
/// **Analyzer findings:**
/// - `value >= 0` is always `true` for a `UInt` — the condition is redundant.
/// - The `else` branch is therefore unreachable dead code.
///
/// - Parameter value: A non-negative unsigned integer.
/// - Returns: Always `"gültig"` for any `UInt` input.
private func alwaysTrueCheck(value: UInt) -> String {
    // ⚠️ Condition always true: UInt ist per Definition >= 0
    if value >= 0 {
        return "gültig"
    }
    // ⚠️ Unreachable code — dieser Zweig kann niemals erreicht werden
    return "ungültig"
}

/// Returns whether a policy number string is empty.
///
/// **SwiftLint finding (rule: `empty_string`):**
/// - Uses `== ""` instead of the idiomatic `.isEmpty` property.
///
/// - Parameter number: The policy number string to check.
/// - Returns: `true` if `number` is the empty string.
private func hasEmptyPolicyNumber(_ number: String) -> Bool {
    // ⚠️ SwiftLint: empty_string — nutze .isEmpty statt == ""
    return number == ""
}
