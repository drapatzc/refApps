import Foundation
import SwiftUI
import MapKit
import SwiftData
import Combine

@MainActor
final class MapViewModel: ObservableObject {
    @Published var selectedDrink: DrinkType = .beer
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.1374, longitude: 11.5755),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var showLocationDeniedAlert: Bool = false
    @Published var lastAddedEntry: DrinkEntry?
    @Published var toastEntry: DrinkEntry?
    @Published var errorToast: String?

    private let locationService: LocationServiceProtocol
    private let keychainService: KeychainServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    var username: String? {
        UsernameGenerator.validUsername(from: keychainService.load(key: KeychainKeys.username),
                                        keychainService: keychainService)
    }

    init(locationService: LocationServiceProtocol = LocationService.shared,
         keychainService: KeychainServiceProtocol = KeychainService.shared,
         notificationService: NotificationServiceProtocol = NotificationService.shared) {
        self.locationService = locationService
        self.keychainService = keychainService
        self.notificationService = notificationService
        setupBindings()
    }

    private func setupBindings() {
        locationService.authorizationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.authorizationStatus = status
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self?.locationService.startUpdating()
                }
            }
            .store(in: &cancellables)

        locationService.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                withAnimation {
                    self?.region.center = location.coordinate
                }
            }
            .store(in: &cancellables)
    }

    func requestLocationIfNeeded() {
        switch authorizationStatus {
        case .notDetermined:
            locationService.requestAuthorization()
        case .denied, .restricted:
            showLocationDeniedAlert = true
        case .authorizedWhenInUse, .authorizedAlways:
            locationService.startUpdating()
        @unknown default:
            break
        }
    }

    func addDrinkAtCurrentLocation(context: ModelContext) {
        // Standort bestimmen: GPS bevorzugt, sonst Kartenmittelpunkt als Fallback
        let coordinate: CLLocationCoordinate2D
        if let location = locationService.currentLocation {
            coordinate = location.coordinate
        } else if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            // Simulator: Standort noch nicht empfangen → Kartenmittelpunkt nutzen
            coordinate = region.center
            showErrorToast(NSLocalizedString("toast_using_map_center", comment: ""))
        } else {
            requestLocationIfNeeded()
            showErrorToast(NSLocalizedString("toast_no_location", comment: ""))
            return
        }

        let entry = DrinkEntry(
            drinkType: selectedDrink,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            username: username
        )
        context.insert(entry)
        do {
            try context.save()
            lastAddedEntry = entry
            showToast(entry)
            centerOnUserLocation()
            Task {
                await notificationService.scheduleLocalNotification(
                    title: String(format: NSLocalizedString("notification_title", comment: ""), selectedDrink.rawValue),
                    body: String(format: NSLocalizedString("notification_body", comment: ""), username ?? ""),
                    identifier: entry.id.uuidString
                )
            }
        } catch {
            showErrorToast(String(format: NSLocalizedString("toast_save_error", comment: ""), error.localizedDescription))
        }
    }

    private func showErrorToast(_ message: String) {
        withAnimation {
            errorToast = message
        }
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            withAnimation {
                errorToast = nil
            }
        }
    }

    private func showToast(_ entry: DrinkEntry) {
        withAnimation {
            toastEntry = entry
        }
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            withAnimation {
                toastEntry = nil
            }
        }
    }

    func centerOnUserLocation() {
        if let location = locationService.currentLocation {
            withAnimation {
                region.center = location.coordinate
            }
        } else {
            requestLocationIfNeeded()
        }
    }
}
