import SwiftUI

@main
struct App4_iOS_UserManagementApp: App {

    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            if let service = container.userService {
                UserListView(
                    viewModel: UserListViewModel(service: service),
                    service: service
                )
            } else if let error = container.initializationError {
                ErrorStartupView(message: error)
            } else {
                ProgressView(String(localized: "loading_database"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - AppContainer

@MainActor
final class AppContainer: ObservableObject {
    @Published private(set) var userService: UserService? = nil
    @Published private(set) var initializationError: String? = nil

    init() {
        do {
            let isUITesting = ProcessInfo.processInfo.arguments.contains("-UITesting")
            let dbManager = try isUITesting
                ? DatabaseManager(path: ":memory:")
                : DatabaseManager()
            let repository = UserRepository(db: dbManager)
            userService = UserService(repository: repository)
        } catch {
            initializationError = error.localizedDescription
        }
    }
}

// MARK: - Fehleranzeige beim Start

struct ErrorStartupView: View {
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.red)

            Text(String(localized: "startup_error_title"))
                .font(.title2)
                .fontWeight(.bold)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
