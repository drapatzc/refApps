import Foundation
import CoreLocation
import Combine
@testable import App5_iOS_BeerMaps

final class MockLocationService: LocationServiceProtocol {
    var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    var currentLocation: CLLocation? = CLLocation(latitude: 48.1374, longitude: 11.5755)

    private let locationSubject = PassthroughSubject<CLLocation, Never>()
    private let authSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(.authorizedWhenInUse)

    var locationPublisher: AnyPublisher<CLLocation, Never> { locationSubject.eraseToAnyPublisher() }
    var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> { authSubject.eraseToAnyPublisher() }

    var requestAuthorizationCalled = false
    var startUpdatingCalled = false
    var stopUpdatingCalled = false

    func requestAuthorization() { requestAuthorizationCalled = true }
    func startUpdating() { startUpdatingCalled = true }
    func stopUpdating() { stopUpdatingCalled = true }

    func simulateLocation(_ location: CLLocation) {
        currentLocation = location
        locationSubject.send(location)
    }

    func simulateAuthorizationChange(_ status: CLAuthorizationStatus) {
        authorizationStatus = status
        authSubject.send(status)
    }
}
