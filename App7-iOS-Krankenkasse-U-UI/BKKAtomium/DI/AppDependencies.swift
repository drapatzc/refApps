import Foundation
import SwiftData

/// Zentraler Dependency-Injection-Container der App.
///
/// `AppDependencies` hält alle App-weiten Abhängigkeiten (Services, Repository-Factories)
/// und stellt sie über Protokolle bereit. ViewModels und Views greifen auf diesen Container
/// über die SwiftUI-Environment zu.
///
/// **Verantwortung:** Konsequente DI-Verdrahtung ohne direkte Singleton-Zugriffe in
/// ViewModels. Alle Abhängigkeiten sind über Protokolle abstrahiert und damit
/// in Tests durch Mocks ersetzbar.
///
/// **Testbarkeit:** Im Test-Target können Mocks injiziert werden:
/// ```swift
/// let dependencies = AppDependencies(
///     authService: MockAuthService(),
///     themeRepository: MockThemeRepository()
/// )
/// ```
@Observable
final class AppDependencies {

    // MARK: - Services

    /// Der Authentifizierungsdienst (Passwort & Biometrie).
    let authService: AuthServiceProtocol

    /// Das Theme-Repository für asynchrones Laden von Theme-Konfigurationen.
    let themeRepository: ThemeRepositoryProtocol

    // MARK: - Initialisierung

    /// Erstellt einen Dependency-Container mit den angegebenen Abhängigkeiten.
    ///
    /// - Parameters:
    ///   - authService: Authentifizierungsdienst; Standard ist `AuthService.shared`.
    ///   - themeRepository: Theme-Repository; Standard ist `ThemeRepository()`.
    init(
        authService: AuthServiceProtocol = AuthService.shared,
        themeRepository: ThemeRepositoryProtocol = ThemeRepository()
    ) {
        self.authService = authService
        self.themeRepository = themeRepository
    }

    // MARK: - Repository-Factories

    /// Erstellt ein `AddressRepository` für den gegebenen `ModelContext`.
    ///
    /// Da Repositories den `ModelContext` benötigen (der pro View-Kontext variieren kann),
    /// werden sie per Factory erstellt statt als Singletons gehalten.
    func makeAddressRepository(context: ModelContext) -> AddressRepositoryProtocol {
        AddressRepository(context: context)
    }

    /// Erstellt ein `PhoneRepository` für den gegebenen `ModelContext`.
    func makePhoneRepository(context: ModelContext) -> PhoneRepositoryProtocol {
        PhoneRepository(context: context)
    }

    /// Erstellt ein `EmailRepository` für den gegebenen `ModelContext`.
    func makeEmailRepository(context: ModelContext) -> EmailRepositoryProtocol {
        EmailRepository(context: context)
    }

    /// Erstellt ein `BankAccountRepository` für den gegebenen `ModelContext`.
    func makeBankAccountRepository(context: ModelContext) -> BankAccountRepositoryProtocol {
        BankAccountRepository(context: context)
    }

    /// Erstellt ein `InvoiceRepository` für den gegebenen `ModelContext`.
    func makeInvoiceRepository(context: ModelContext) -> InvoiceRepositoryProtocol {
        InvoiceRepository(context: context)
    }

    /// Erstellt ein `DocumentRepository` für den gegebenen `ModelContext`.
    func makeDocumentRepository(context: ModelContext) -> DocumentRepositoryProtocol {
        DocumentRepository(context: context)
    }

    /// Erstellt ein `BenefitRequestRepository` für den gegebenen `ModelContext`.
    func makeBenefitRequestRepository(context: ModelContext) -> BenefitRequestRepositoryProtocol {
        BenefitRequestRepository(context: context)
    }
}
