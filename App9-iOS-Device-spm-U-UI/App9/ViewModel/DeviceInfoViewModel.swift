import Foundation
import Combine

// MARK: - DeviceInfoViewModel

final class DeviceInfoViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var deviceInfo: DeviceInfo?
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var lastUpdated: Date = Date()

    // MARK: - Private

    private let service: DeviceInfoServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(service: DeviceInfoServiceProtocol = DeviceInfoService()) {
        self.service = service
        setupBindings()
    }

    // MARK: - Lifecycle

    func onAppear() {
        service.startOrientationMonitoring()
    }

    func onDisappear() {
        service.stopOrientationMonitoring()
    }

    // MARK: - Actions

    func refresh() {
        isLoading = true
        service.refresh()
    }

    // MARK: - Computed Properties

    var deviceIconName: String {
        guard let info = deviceInfo else { return "iphone" }
        if info.isPad { return "ipad" }
        if info.isPhone { return "iphone" }
        return "desktopcomputer"
    }

    var formattedScreenDiagonal: String {
        guard let info = deviceInfo else { return "-" }
        return String(format: "%.1f\"", info.screenDiagonal)
    }

    // MARK: - Private Methods

    private func setupBindings() {
        service.deviceInfoPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                self?.deviceInfo = info
                self?.isLoading = false
                self?.lastUpdated = Date()
            }
            .store(in: &cancellables)
    }
}
