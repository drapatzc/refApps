import SwiftUI

/// Codierbare Datenstruktur für eine Theme-Konfigurationsdatei.
///
/// `AppThemeModel` wird aus JSON-Dateien im App-Bundle geladen und enthält alle
/// visuellen Designwerte der App: Farben, Farbverläufe, Schriftgrößen, Abstände,
/// Eckenradien, Button- und Card-Stile sowie Statusfarben.
///
/// **Verantwortung:** Reine Datenstruktur ohne Geschäftslogik.
/// Die Konvertierung in SwiftUI-Typen (z. B. `Color`, `LinearGradient`) erfolgt
/// über computed properties in der `Extension`.
///
/// **Testbarkeit:** Über `AppThemeModel.default` ist ein Fallback-Theme ohne
/// Dateiladung verfügbar, was Tests ohne Bundle-Zugriff ermöglicht.
struct AppThemeModel: Codable, Identifiable, Equatable {

    // MARK: - Identifikation

    /// Technischer Bezeichner (z. B. "default", "ocean", "forest").
    let name: String

    /// Anzeigename für das Debug-Menü (z. B. "BKK Standard").
    let displayName: String

    // MARK: - Primärfarben (Hex-Strings, z. B. "#1C4A80")

    /// Hauptfarbe der App (Primärfarbe für Buttons, Icons, Akzente).
    let primaryHex: String

    /// Akzentfarbe (ergänzt die Primärfarbe, z. B. für sekundäre Elemente).
    let accentHex: String

    // MARK: - Farbverläufe

    /// Startfarbe des primären Verlaufs (von oben links).
    let gradientStartHex: String

    /// Endfarbe des primären Verlaufs (nach unten rechts).
    let gradientEndHex: String

    /// Startfarbe des Header-Verlaufs.
    let headerGradientStartHex: String

    /// Endfarbe des Header-Verlaufs.
    let headerGradientEndHex: String

    // MARK: - Dark-Mode-Farben

    /// Primärfarbe im Dark Mode.
    let primaryDarkHex: String

    /// Akzentfarbe im Dark Mode.
    let accentDarkHex: String

    // MARK: - Statusfarben

    /// Farbe für Erfolgshinweise (z. B. Grün).
    let successHex: String

    /// Farbe für Warnhinweise (z. B. Orange).
    let warningHex: String

    /// Farbe für Fehlerhinweise (z. B. Rot).
    let errorHex: String

    // MARK: - Eckenradien

    let cornerRadiusS: CGFloat
    let cornerRadiusM: CGFloat
    let cornerRadiusL: CGFloat
    let cornerRadiusXL: CGFloat

    // MARK: - Abstände

    let spacingXS: CGFloat
    let spacingS: CGFloat
    let spacingM: CGFloat
    let spacingL: CGFloat
    let spacingXL: CGFloat
    let spacingXXL: CGFloat

    // MARK: - Schriftgrößen

    let fontSizeCaption: CGFloat
    let fontSizeBody: CGFloat
    let fontSizeTitle: CGFloat
    let fontSizeHeadline: CGFloat

    // MARK: - Identifiable

    /// Eindeutiger Bezeichner basierend auf dem technischen Namen.
    var id: String { name }
}

// MARK: - SwiftUI-Konvertierungen

extension AppThemeModel {

    /// Primärfarbe als SwiftUI `Color`.
    var primaryColor: Color { Color(hex: primaryHex) }

    /// Akzentfarbe als SwiftUI `Color`.
    var accentColor: Color { Color(hex: accentHex) }

    /// Primärfarbe im Dark Mode als SwiftUI `Color`.
    var primaryDarkColor: Color { Color(hex: primaryDarkHex) }

    /// Akzentfarbe im Dark Mode als SwiftUI `Color`.
    var accentDarkColor: Color { Color(hex: accentDarkHex) }

    /// Erfolgsfarbe als SwiftUI `Color`.
    var successColor: Color { Color(hex: successHex) }

    /// Warnfarbe als SwiftUI `Color`.
    var warningColor: Color { Color(hex: warningHex) }

    /// Fehlerfarbe als SwiftUI `Color`.
    var errorColor: Color { Color(hex: errorHex) }

    /// Primärer Farbverlauf als `LinearGradient`.
    var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: gradientStartHex), Color(hex: gradientEndHex)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Header-Farbverlauf als `LinearGradient`.
    var headerGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: headerGradientStartHex), Color(hex: headerGradientEndHex)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Standard-Fallback

extension AppThemeModel {

    /// Statisches Standard-Theme mit den Originalwerten aus `AppTheme.swift`.
    ///
    /// Wird verwendet wenn die JSON-Datei nicht geladen werden kann, und als
    /// Initialwert für `AppThemeManager` vor dem asynchronen Ladevorgang.
    static let `default` = AppThemeModel(
        name: "default",
        displayName: "BKK Standard",
        primaryHex: "#1C4A80",
        accentHex: "#1A613D",
        gradientStartHex: "#14386B",
        gradientEndHex: "#1A6147",
        headerGradientStartHex: "#0F2E5C",
        headerGradientEndHex: "#174D38",
        primaryDarkHex: "#4A7AB5",
        accentDarkHex: "#3A9463",
        successHex: "#34C759",
        warningHex: "#FF9500",
        errorHex: "#FF3B30",
        cornerRadiusS: 8,
        cornerRadiusM: 12,
        cornerRadiusL: 16,
        cornerRadiusXL: 20,
        spacingXS: 4,
        spacingS: 8,
        spacingM: 16,
        spacingL: 24,
        spacingXL: 32,
        spacingXXL: 48,
        fontSizeCaption: 12,
        fontSizeBody: 16,
        fontSizeTitle: 22,
        fontSizeHeadline: 28
    )
}

// MARK: - Color Hex Extension

extension Color {

    /// Erzeugt eine `Color` aus einem Hex-String im Format `"#RRGGBB"` oder `"RRGGBB"`.
    ///
    /// - Parameter hex: Der Hex-String (z. B. "#1C4A80" oder "1C4A80").
    ///
    /// Eingabebeispiel: `"#1C4A80"` → R=0x1C, G=0x4A, B=0x80
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                         .replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)
        let red   = Double((rgb >> 16) & 0xFF) / 255
        let green = Double((rgb >> 8)  & 0xFF) / 255
        let blue  = Double( rgb        & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}
