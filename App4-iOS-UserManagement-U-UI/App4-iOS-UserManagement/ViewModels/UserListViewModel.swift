import Foundation
import SwiftUI

@MainActor
final class UserListViewModel: ObservableObject {

    // MARK: - Published State
    @Published var users: [User] = []
    @Published var searchText: String = "" {
        didSet { scheduleSearch() }
    }
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showDeleteConfirmation: Bool = false
    @Published var userToDelete: User? = nil

    // MARK: - Dependencies
    private let service: UserService
    private var searchTask: Task<Void, Never>?

    // MARK: - Init

    init(service: UserService) {
        self.service = service
    }

    // MARK: - Laden

    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            users = try await service.loadAllUsers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Suche

    private func scheduleSearch() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            // Brief delay for debouncing
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            guard !Task.isCancelled else { return }
            await self?.performSearch()
        }
    }

    private func performSearch() async {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        do {
            if query.isEmpty {
                users = try await service.loadAllUsers()
            } else {
                users = try await service.searchUsers(query: query)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Deleting

    func requestDelete(user: User) {
        userToDelete = user
        showDeleteConfirmation = true
    }

    func confirmDelete() async {
        guard let user = userToDelete else { return }
        do {
            try await service.deleteUser(id: user.id)
            users.removeAll { $0.id == user.id }
            userToDelete = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancelDelete() {
        userToDelete = nil
        showDeleteConfirmation = false
    }

    // MARK: - Debug

#if DEBUG
    @Published var showSeedConfirmation: Bool = false
    @Published var showDeleteAllConfirmation: Bool = false

    func confirmSeedTestUsers() async {
        do {
            let created = try await service.seedTestUsers()
            users.append(contentsOf: created)
            users.sort { $0.lastName < $1.lastName }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func confirmDeleteAll() async {
        do {
            try await service.deleteAllUsers()
            users.removeAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
#endif

    // MARK: - Aktualisierung nach Bearbeitung

    func userWasCreated(_ user: User) {
        users.append(user)
        users.sort { $0.lastName < $1.lastName }
    }

    func userWasUpdated(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        }
        users.sort { $0.lastName < $1.lastName }
    }
}
