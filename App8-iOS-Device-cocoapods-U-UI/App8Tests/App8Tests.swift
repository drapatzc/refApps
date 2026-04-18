import XCTest
import Combine
@testable import App8

// MARK: - Mock Service

final class MockDeviceInfoService: DeviceInfoServiceProtocol {
    private let subject = PassthroughSubject<DeviceInfo, Never>()

    var deviceInfoPublisher: AnyPublisher<DeviceInfo, Never> {
        subject.eraseToAnyPublisher()
    }

    func refresh() {}
    func startOrientationMonitoring() {}
    func stopOrientationMonitoring() {}
}

// MARK: - Unit Tests

final class App8Tests: XCTestCase {

    // MARK: - DeviceInfo Equatable

    func testDeviceInfoEquality() {
        let info1 = makeDeviceInfo()
        let info2 = makeDeviceInfo()
        XCTAssertEqual(info1, info2)
    }

    func testDeviceInfoInequality() {
        let info1 = makeDeviceInfo(name: "iPhone 15")
        let info2 = makeDeviceInfo(name: "iPhone 14")
        XCTAssertNotEqual(info1, info2)
    }

    // MARK: - BatteryStateInfo Icons

    func testBatteryIconFull() {
        XCTAssertEqual(BatteryStateInfo.full.icon, "battery.100.bolt")
    }

    func testBatteryIconCharging() {
        XCTAssertEqual(BatteryStateInfo.charging(80).icon, "battery.charging")
    }

    func testBatteryIconUnplugged() {
        XCTAssertEqual(BatteryStateInfo.unplugged(50).icon, "battery.75")
    }

    func testBatteryIconUnknown() {
        XCTAssertEqual(BatteryStateInfo.unknown.icon, "battery.slash")
    }

    // MARK: - OrientationInfo Icons

    func testOrientationIconPortrait() {
        XCTAssertEqual(OrientationInfo.portrait.icon, "iphone")
        XCTAssertEqual(OrientationInfo.portraitUpsideDown.icon, "iphone")
    }

    func testOrientationIconLandscape() {
        XCTAssertEqual(OrientationInfo.landscapeLeft.icon, "iphone.landscape")
        XCTAssertEqual(OrientationInfo.landscapeRight.icon, "iphone.landscape")
    }

    // MARK: - DeviceInfoViewModel

    func testViewModelDeviceIconNameWithoutData() {
        let viewModel = DeviceInfoViewModel(service: MockDeviceInfoService())
        XCTAssertEqual(viewModel.deviceIconName, "iphone")
    }

    func testViewModelFormattedScreenDiagonalWithoutData() {
        let viewModel = DeviceInfoViewModel(service: MockDeviceInfoService())
        XCTAssertEqual(viewModel.formattedScreenDiagonal, "-")
    }

    // MARK: - Helpers

    private func makeDeviceInfo(name: String = "iPhone 15") -> DeviceInfo {
        DeviceInfo(
            name: name,
            systemVersion: "18.0",
            systemName: "iOS",
            modelName: "iPhone15,2",
            isSimulator: true,
            screenDiagonal: 6.1,
            screenRatio: ScreenRatio(width: 19, height: 9),
            batteryLevel: 80,
            batteryState: .unplugged(80),
            orientation: .portrait,
            hasBiometricSensor: true,
            hasTrueDepthCamera: true,
            hasLidarSensor: false,
            hasNFC: true,
            hasUSBCConnectivity: true,
            hasDynamicIsland: false,
            isPhone: true,
            isPad: false
        )
    }
}
