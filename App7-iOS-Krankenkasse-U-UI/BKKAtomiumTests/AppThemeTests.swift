import Testing
import SwiftUI
@testable import BKKAtomium

@Suite("AppTheme Tests")
struct AppThemeTests {

    // MARK: - Abstände

    @Test("spacingXS ist 4 pt")
    func testSpacingXS() {
        #expect(AppTheme.spacingXS == 4)
    }

    @Test("spacingS ist 8 pt")
    func testSpacingS() {
        #expect(AppTheme.spacingS == 8)
    }

    @Test("spacingM ist 16 pt")
    func testSpacingM() {
        #expect(AppTheme.spacingM == 16)
    }

    @Test("spacingL ist 24 pt")
    func testSpacingL() {
        #expect(AppTheme.spacingL == 24)
    }

    @Test("spacingXL ist 32 pt")
    func testSpacingXL() {
        #expect(AppTheme.spacingXL == 32)
    }

    @Test("spacingXXL ist 48 pt")
    func testSpacingXXL() {
        #expect(AppTheme.spacingXXL == 48)
    }

    @Test("Abstände sind aufsteigend geordnet")
    func testSpacingOrder() {
        #expect(AppTheme.spacingXS < AppTheme.spacingS)
        #expect(AppTheme.spacingS < AppTheme.spacingM)
        #expect(AppTheme.spacingM < AppTheme.spacingL)
        #expect(AppTheme.spacingL < AppTheme.spacingXL)
        #expect(AppTheme.spacingXL < AppTheme.spacingXXL)
    }

    // MARK: - Eckenradien

    @Test("cornerRadiusS ist 8 pt")
    func testCornerRadiusS() {
        #expect(AppTheme.cornerRadiusS == 8)
    }

    @Test("cornerRadiusM ist 12 pt")
    func testCornerRadiusM() {
        #expect(AppTheme.cornerRadiusM == 12)
    }

    @Test("cornerRadiusL ist 16 pt")
    func testCornerRadiusL() {
        #expect(AppTheme.cornerRadiusL == 16)
    }

    @Test("cornerRadiusXL ist 20 pt")
    func testCornerRadiusXL() {
        #expect(AppTheme.cornerRadiusXL == 20)
    }

    @Test("Eckenradien sind aufsteigend geordnet")
    func testCornerRadiusOrder() {
        #expect(AppTheme.cornerRadiusS < AppTheme.cornerRadiusM)
        #expect(AppTheme.cornerRadiusM < AppTheme.cornerRadiusL)
        #expect(AppTheme.cornerRadiusL < AppTheme.cornerRadiusXL)
    }

    // MARK: - Farben

    @Test("primary Farbe ist zugänglich")
    func testPrimaryColorAccessible() {
        let color = AppTheme.primary
        _ = color
        #expect(Bool(true))
    }

    @Test("accent Farbe ist zugänglich")
    func testAccentColorAccessible() {
        let color = AppTheme.accent
        _ = color
        #expect(Bool(true))
    }

    @Test("cardBackground ist zugänglich")
    func testCardBackgroundAccessible() {
        _ = AppTheme.cardBackground
        #expect(Bool(true))
    }

    @Test("sectionBackground ist zugänglich")
    func testSectionBackgroundAccessible() {
        _ = AppTheme.sectionBackground
        #expect(Bool(true))
    }

    @Test("groupedBackground ist zugänglich")
    func testGroupedBackgroundAccessible() {
        _ = AppTheme.groupedBackground
        #expect(Bool(true))
    }

    @Test("primaryGradient ist zugänglich")
    func testPrimaryGradientAccessible() {
        _ = AppTheme.primaryGradient
        #expect(Bool(true))
    }

    @Test("headerGradient ist zugänglich")
    func testHeaderGradientAccessible() {
        _ = AppTheme.headerGradient
        #expect(Bool(true))
    }

    // MARK: - View Modifier

    @Test("appCardStyle() kann auf eine View angewendet werden")
    func testAppCardStyleApplicable() {
        let view = Text("test").appCardStyle()
        _ = view
        #expect(Bool(true))
    }

    @Test("appCardStyle(colorScheme: .dark) kann angewendet werden")
    func testAppCardStyleDarkMode() {
        let view = Text("test").appCardStyle(colorScheme: .dark)
        _ = view
        #expect(Bool(true))
    }

    @Test("primaryButton() kann auf eine View angewendet werden")
    func testPrimaryButtonApplicable() {
        let view = Text("Login").primaryButton()
        _ = view
        #expect(Bool(true))
    }

    @Test("destructiveButton() kann auf eine View angewendet werden")
    func testDestructiveButtonApplicable() {
        let view = Text("Löschen").destructiveButton()
        _ = view
        #expect(Bool(true))
    }
}
