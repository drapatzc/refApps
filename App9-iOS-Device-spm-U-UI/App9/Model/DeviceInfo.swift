import Foundation

// MARK: - DeviceInfo Model

struct DeviceInfo: Equatable {
    let name: String
    let systemVersion: String
    let systemName: String
    let modelName: String
    let isSimulator: Bool

    // Screen
    let screenDiagonal: Double
    let screenRatio: ScreenRatio?

    // Battery
    let batteryLevel: Int?
    let batteryState: BatteryStateInfo

    // Orientation
    let orientation: OrientationInfo

    // Features
    let hasBiometricSensor: Bool
    let hasTrueDepthCamera: Bool
    let hasLidarSensor: Bool
    let hasNFC: Bool
    let hasUSBCConnectivity: Bool
    let hasDynamicIsland: Bool

    // Form factor
    let isPhone: Bool
    let isPad: Bool
}

struct ScreenRatio: Equatable {
    let width: Int
    let height: Int
}

// MARK: - Battery State

enum BatteryStateInfo: Equatable {
    case full
    case charging(Int)
    case unplugged(Int)
    case unknown

    var localizedDescription: String {
        switch self {
        case .full:
            return NSLocalizedString("battery_full", comment: "")
        case .charging(let level):
            return String(format: NSLocalizedString("battery_charging", comment: ""), level)
        case .unplugged(let level):
            return String(format: NSLocalizedString("battery_unplugged", comment: ""), level)
        case .unknown:
            return NSLocalizedString("battery_unknown", comment: "")
        }
    }

    var icon: String {
        switch self {
        case .full: return "battery.100.bolt"
        case .charging: return "battery.charging"
        case .unplugged: return "battery.75"
        case .unknown: return "battery.slash"
        }
    }
}

// MARK: - Orientation Info

enum OrientationInfo: Equatable {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
    case faceUp
    case faceDown
    case unknown

    var localizedDescription: String {
        switch self {
        case .portrait: return NSLocalizedString("orientation_portrait", comment: "")
        case .portraitUpsideDown: return NSLocalizedString("orientation_portrait_upside_down", comment: "")
        case .landscapeLeft: return NSLocalizedString("orientation_landscape_left", comment: "")
        case .landscapeRight: return NSLocalizedString("orientation_landscape_right", comment: "")
        case .faceUp: return NSLocalizedString("orientation_face_up", comment: "")
        case .faceDown: return NSLocalizedString("orientation_face_down", comment: "")
        case .unknown: return NSLocalizedString("orientation_unknown", comment: "")
        }
    }

    var icon: String {
        switch self {
        case .portrait, .portraitUpsideDown: return "iphone"
        case .landscapeLeft, .landscapeRight: return "iphone.landscape"
        case .faceUp: return "ipad.landscape"
        case .faceDown: return "ipad.landscape"
        case .unknown: return "questionmark.circle"
        }
    }
}
