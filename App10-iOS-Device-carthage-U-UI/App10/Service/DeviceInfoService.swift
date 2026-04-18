import Foundation
import Combine
import UIKit
import DeviceKit

// MARK: - DeviceInfoService Protocol

protocol DeviceInfoServiceProtocol {
    var deviceInfoPublisher: AnyPublisher<DeviceInfo, Never> { get }
    func refresh()
    func startOrientationMonitoring()
    func stopOrientationMonitoring()
}

// MARK: - DeviceInfoService

final class DeviceInfoService: DeviceInfoServiceProtocol {

    // MARK: - Private Properties

    private let deviceInfoSubject: CurrentValueSubject<DeviceInfo, Never>
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Properties

    var deviceInfoPublisher: AnyPublisher<DeviceInfo, Never> {
        deviceInfoSubject.eraseToAnyPublisher()
    }

    // MARK: - Init

    init() {
        deviceInfoSubject = CurrentValueSubject(DeviceInfoService.buildDeviceInfo())
        setupBatteryMonitoring()
    }

    // MARK: - Public Methods

    func refresh() {
        deviceInfoSubject.send(DeviceInfoService.buildDeviceInfo())
    }

    func startOrientationMonitoring() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.publisher(
            for: UIDevice.orientationDidChangeNotification
        )
        .sink { [weak self] _ in
            self?.refresh()
        }
        .store(in: &cancellables)
    }

    func stopOrientationMonitoring() {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        cancellables.removeAll()
    }

    // MARK: - Private Methods

    private func setupBatteryMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true

        NotificationCenter.default.publisher(
            for: UIDevice.batteryLevelDidChangeNotification
        )
        .merge(with: NotificationCenter.default.publisher(
            for: UIDevice.batteryStateDidChangeNotification
        ))
        .sink { [weak self] _ in
            self?.refresh()
        }
        .store(in: &cancellables)
    }

    private static func buildDeviceInfo() -> DeviceInfo {
        let device = Device.current

        let batteryState = mapBatteryState(device.batteryState)
        let orientation = mapOrientation(UIDevice.current.orientation)
        let batteryLevel = device.batteryLevel

        return DeviceInfo(
            name: device.name ?? UIDevice.current.name,
            systemVersion: device.systemVersion ?? UIDevice.current.systemVersion,
            systemName: device.systemName ?? UIDevice.current.systemName,
            modelName: device.description,
            isSimulator: device.isSimulator,
            screenDiagonal: device.diagonal,
            screenRatio: nil,
            batteryLevel: batteryLevel == -1 ? nil : batteryLevel,
            batteryState: batteryState,
            orientation: orientation,
            hasBiometricSensor: device.hasBiometricSensor,
            hasTrueDepthCamera: false,
            hasLidarSensor: device.hasLidarSensor,
            hasNFC: false,
            hasUSBCConnectivity: device.hasUSBCConnectivity,
            hasDynamicIsland: device.hasDynamicIsland,
            isPhone: device.isPhone,
            isPad: device.isPad
        )
    }

    private static func mapBatteryState(_ state: Device.BatteryState?) -> BatteryStateInfo {
        guard let state = state else { return .unknown }
        switch state {
        case .full:
            return .full
        case .charging(let level):
            return .charging(level)
        case .unplugged(let level):
            return .unplugged(level)
        }
    }

    private static func mapOrientation(_ orientation: UIDeviceOrientation) -> OrientationInfo {
        switch orientation {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        case .faceUp: return .faceUp
        case .faceDown: return .faceDown
        default: return .unknown
        }
    }
}
