import Foundation
import CoreLocation
import Combine

protocol LocationServiceProtocol: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var currentLocation: CLLocation? { get }
    var locationPublisher: AnyPublisher<CLLocation, Never> { get }
    var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
    func requestAuthorization()
    func startUpdating()
    func stopUpdating()
}

final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    static let shared = LocationService()

    private let locationManager = CLLocationManager()
    private let locationSubject = PassthroughSubject<CLLocation, Never>()
    private let authSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(.notDetermined)

    var authorizationStatus: CLAuthorizationStatus { authSubject.value }
    var currentLocation: CLLocation? { locationManager.location }
    var locationPublisher: AnyPublisher<CLLocation, Never> { locationSubject.eraseToAnyPublisher() }
    var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> { authSubject.eraseToAnyPublisher() }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authSubject.send(locationManager.authorizationStatus)
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationSubject.send(location)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authSubject.send(manager.authorizationStatus)
    }
}
