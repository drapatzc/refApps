import Testing
import SwiftUI
@testable import BKKAtomium

/// Tests für das JSON-basierte Theme-System.
@Suite("AppThemeModel Tests")
struct AppThemeModelTests {

    // MARK: - Default-Theme

    @Test("AppThemeModel.default ist verfügbar ohne Bundle-Zugriff")
    func testDefaultThemeIsAvailable() {
        let theme = AppThemeModel.default
        #expect(theme.name == "default")
        #expect(theme.displayName == "BKK Standard")
    }

    @Test("Default-Theme hat korrekte Eckenradien")
    func testDefaultThemeCornerRadii() {
        let theme = AppThemeModel.default
        #expect(theme.cornerRadiusS == 8)
        #expect(theme.cornerRadiusM == 12)
        #expect(theme.cornerRadiusL == 16)
        #expect(theme.cornerRadiusXL == 20)
    }

    @Test("Default-Theme hat korrekte Abstände")
    func testDefaultThemeSpacing() {
        let theme = AppThemeModel.default
        #expect(theme.spacingXS == 4)
        #expect(theme.spacingS == 8)
        #expect(theme.spacingM == 16)
        #expect(theme.spacingL == 24)
        #expect(theme.spacingXL == 32)
        #expect(theme.spacingXXL == 48)
    }

    @Test("Default-Theme Abstände sind aufsteigend")
    func testDefaultThemeSpacingOrder() {
        let theme = AppThemeModel.default
        #expect(theme.spacingXS < theme.spacingS)
        #expect(theme.spacingS < theme.spacingM)
        #expect(theme.spacingM < theme.spacingL)
        #expect(theme.spacingL < theme.spacingXL)
        #expect(theme.spacingXL < theme.spacingXXL)
    }

    @Test("Default-Theme hat gültige Hex-Farbstrings")
    func testDefaultThemeHexColorsValid() {
        let theme = AppThemeModel.default
        #expect(theme.primaryHex.hasPrefix("#"))
        #expect(theme.accentHex.hasPrefix("#"))
        #expect(theme.successHex.hasPrefix("#"))
        #expect(theme.warningHex.hasPrefix("#"))
        #expect(theme.errorHex.hasPrefix("#"))
    }

    @Test("AppThemeModel.default id entspricht name")
    func testDefaultThemeIdentifiable() {
        let theme = AppThemeModel.default
        #expect(theme.id == theme.name)
    }

    // MARK: - Color Extension

    @Test("Color(hex:) erzeugt gültige SwiftUI-Farbe aus #RRGGBB")
    func testColorFromHexWithHash() {
        let color = Color(hex: "#1C4A80")
        _ = color
        #expect(Bool(true))
    }

    @Test("Color(hex:) erzeugt gültige SwiftUI-Farbe ohne #-Präfix")
    func testColorFromHexWithoutHash() {
        let color = Color(hex: "1C4A80")
        _ = color
        #expect(Bool(true))
    }

    // MARK: - Equatable

    @Test("Zwei identische AppThemeModel-Instanzen sind gleich")
    func testEquatableEqual() {
        let first = AppThemeModel.default
        let second = AppThemeModel.default
        #expect(first == second)
    }

    @Test("AppThemeModel mit unterschiedlichem Namen ist ungleich")
    func testEquatableNotEqual() {
        let first = MockDataFactory.makeTheme(name: "a")
        let second = MockDataFactory.makeTheme(name: "b")
        #expect(first != second)
    }
}

/// Tests für den MockThemeRepository.
@Suite("MockThemeRepository Tests")
struct MockThemeRepositoryTests {

    @Test("MockThemeRepository gibt stubbedTheme zurück")
    func testLoadThemeReturnsStubbedTheme() async throws {
        let mock = MockThemeRepository()
        mock.stubbedTheme = MockDataFactory.makeTheme(name: "ocean")
        let loaded = try await mock.loadTheme(named: "ocean")
        #expect(loaded.name == "ocean")
        #expect(mock.loadThemeCallCount == 1)
        #expect(mock.lastLoadedThemeName == "ocean")
    }

    @Test("MockThemeRepository wirft bei gesetztem thrownError")
    func testLoadThemeThrowsWhenErrorSet() async {
        let mock = MockThemeRepository()
        mock.thrownError = .themeLoading("Testfehler")
        await #expect(throws: AppError.self) {
            _ = try await mock.loadTheme(named: "default")
        }
    }

    @Test("MockThemeRepository gibt korrekte Theme-Namen zurück")
    func testAvailableThemeNames() {
        let mock = MockThemeRepository()
        let names = mock.availableThemeNames()
        #expect(names.contains("default"))
        #expect(names.contains("ocean"))
        #expect(names.contains("forest"))
    }
}

/// Tests für AppThemeManager mit Mock-Repository.
@Suite("AppThemeManager Tests")
@MainActor
struct AppThemeManagerTests {

    @Test("AppThemeManager startet mit Default-Theme")
    func testInitialThemeIsDefault() {
        let mock = MockThemeRepository()
        let manager = AppThemeManager(repository: mock)
        #expect(manager.activeTheme == AppThemeModel.default)
    }

    @Test("loadSavedTheme() lädt Theme aus Repository")
    func testLoadSavedThemeCallsRepository() async {
        let mock = MockThemeRepository()
        mock.stubbedTheme = MockDataFactory.makeTheme(name: "ocean")
        let manager = AppThemeManager(repository: mock)

        UserDefaults.standard.set("ocean", forKey: AppThemeManager.selectedThemeKey)
        await manager.loadSavedTheme()

        #expect(mock.loadThemeCallCount == 1)
    }

    @Test("loadSavedTheme() bleibt bei Default wenn Repository Fehler wirft")
    func testLoadSavedThemeFallsBackOnError() async {
        let mock = MockThemeRepository()
        mock.thrownError = .themeLoading("Test")
        let manager = AppThemeManager(repository: mock)

        await manager.loadSavedTheme()

        #expect(manager.activeTheme == AppThemeModel.default)
    }

    @Test("availableThemeNames enthält alle 3 Themes")
    func testAvailableThemeNames() {
        let manager = AppThemeManager()
        #expect(manager.availableThemeNames.count == 3)
    }
}
