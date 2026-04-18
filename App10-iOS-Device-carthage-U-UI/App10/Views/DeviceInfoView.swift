import SwiftUI

// MARK: - DeviceInfoView

struct DeviceInfoView: View {

    @StateObject private var viewModel = DeviceInfoViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let info = viewModel.deviceInfo {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            deviceHeaderSection(info)
                            systemSection(info)
                            batterySection(info)
                            orientationSection(info)
                            screenSection(info)
                            featuresSection(info)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(NSLocalizedString("app_title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
    }

    // MARK: - Sections

    @ViewBuilder
    private func deviceHeaderSection(_ info: DeviceInfo) -> some View {
        VStack(spacing: 8) {
            Image(systemName: viewModel.deviceIconName)
                .font(.system(size: 64))
                .foregroundStyle(.blue)
            Text(info.modelName)
                .font(.title2.bold())
            if info.isSimulator {
                Label(NSLocalizedString("simulator", comment: ""), systemImage: "laptopcomputer")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func systemSection(_ info: DeviceInfo) -> some View {
        InfoCard(title: NSLocalizedString("section_system", comment: ""), icon: "gearshape.fill") {
            InfoRow(label: NSLocalizedString("label_device_name", comment: ""), value: info.name, icon: "person.crop.circle")
            InfoRow(label: NSLocalizedString("label_system", comment: ""), value: "\(info.systemName) \(info.systemVersion)", icon: "apple.logo")
        }
    }

    @ViewBuilder
    private func batterySection(_ info: DeviceInfo) -> some View {
        InfoCard(title: NSLocalizedString("section_battery", comment: ""), icon: "battery.100") {
            if let level = info.batteryLevel {
                InfoRow(
                    label: NSLocalizedString("label_battery_level", comment: ""),
                    value: "\(level)%",
                    icon: "battery.75"
                )
                BatteryBar(level: level)
                    .padding(.vertical, 4)
            }
            InfoRow(
                label: NSLocalizedString("label_battery_state", comment: ""),
                value: info.batteryState.localizedDescription,
                icon: info.batteryState.icon
            )
        }
    }

    @ViewBuilder
    private func orientationSection(_ info: DeviceInfo) -> some View {
        InfoCard(title: NSLocalizedString("section_orientation", comment: ""), icon: "rotate.right") {
            InfoRow(
                label: NSLocalizedString("label_orientation", comment: ""),
                value: info.orientation.localizedDescription,
                icon: info.orientation.icon
            )
        }
    }

    @ViewBuilder
    private func screenSection(_ info: DeviceInfo) -> some View {
        InfoCard(title: NSLocalizedString("section_screen", comment: ""), icon: "rectangle.on.rectangle") {
            InfoRow(label: NSLocalizedString("label_diagonal", comment: ""), value: viewModel.formattedScreenDiagonal, icon: "ruler")
        }
    }

    @ViewBuilder
    private func featuresSection(_ info: DeviceInfo) -> some View {
        InfoCard(title: NSLocalizedString("section_features", comment: ""), icon: "star.fill") {
            FeatureRow(label: NSLocalizedString("feature_biometric", comment: ""), available: info.hasBiometricSensor, icon: "faceid")
            FeatureRow(label: NSLocalizedString("feature_true_depth", comment: ""), available: info.hasTrueDepthCamera, icon: "camera.aperture")
            FeatureRow(label: NSLocalizedString("feature_lidar", comment: ""), available: info.hasLidarSensor, icon: "lifepreserver")
            FeatureRow(label: NSLocalizedString("feature_nfc", comment: ""), available: info.hasNFC, icon: "wave.3.right")
            FeatureRow(label: NSLocalizedString("feature_usbc", comment: ""), available: info.hasUSBCConnectivity, icon: "cable.connector")
            FeatureRow(label: NSLocalizedString("feature_dynamic_island", comment: ""), available: info.hasDynamicIsland, icon: "oval.portrait")
        }
    }
}

// MARK: - InfoCard

private struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(.primary)
            content
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - InfoRow

private struct InfoRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(.primary)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

// MARK: - FeatureRow

private struct FeatureRow: View {
    let label: String
    let available: Bool
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(available ? .blue : .secondary)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(available ? .primary : .secondary)
            Spacer()
            Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(available ? .green : .red)
        }
        .font(.subheadline)
    }
}

// MARK: - BatteryBar

private struct BatteryBar: View {
    let level: Int

    private var color: Color {
        switch level {
        case 0..<20: return .red
        case 20..<50: return .orange
        default: return .green
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(level) / 100, height: 8)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Preview

#Preview {
    DeviceInfoView()
}
