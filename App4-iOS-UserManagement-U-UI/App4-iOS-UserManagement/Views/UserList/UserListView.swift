import SwiftUI

struct UserListView: View {
    @ObservedObject var viewModel: UserListViewModel
    let service: UserService

    @State private var showCreateSheet: Bool = false
    @State private var selectedUser: User? = nil
    @State private var showError: Bool = false

    var body: some View {
        NavigationSplitView {
            sidebarContent
                .navigationTitle(String(localized: "app_title"))
                .toolbar { toolbarContent }
                .searchable(
                    text: $viewModel.searchText,
                    prompt: String(localized: "search_placeholder")
                )
                .refreshable {
                    await viewModel.loadUsers()
                }
        } detail: {
            detailContent
        }
        .task {
            await viewModel.loadUsers()
        }
        .sheet(isPresented: $showCreateSheet) {
            let formVM = UserFormViewModel(service: service)
            UserFormView(viewModel: formVM) { newUser in
                viewModel.userWasCreated(newUser)
                selectedUser = newUser
            }
        }
        .confirmationDialog(
            String(localized: "delete_confirmation_title"),
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "button_delete"), role: .destructive) {
                Task { await viewModel.confirmDelete() }
            }
            Button(String(localized: "button_cancel"), role: .cancel) {
                viewModel.cancelDelete()
            }
        } message: {
            if let user = viewModel.userToDelete {
                Text(String(format: NSLocalizedString("delete_user_message", comment: ""), user.fullName))
            }
        }
        .alert(String(localized: "error_title"), isPresented: $showError) {
            Button(String(localized: "button_ok")) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            showError = newValue != nil
        }
#if DEBUG
        .confirmationDialog(
            "🛠 10 Testbenutzer anlegen?",
            isPresented: $viewModel.showSeedConfirmation,
            titleVisibility: .visible
        ) {
            Button("Anlegen", role: .destructive) {
                Task { await viewModel.confirmSeedTestUsers() }
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Es werden 10 vordefinierte Testbenutzer in die Datenbank eingefügt.")
        }
        .confirmationDialog(
            "🛠 Alle Benutzer löschen?",
            isPresented: $viewModel.showDeleteAllConfirmation,
            titleVisibility: .visible
        ) {
            Button("Alle löschen", role: .destructive) {
                Task { await viewModel.confirmDeleteAll() }
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Alle \(viewModel.users.count) Benutzer werden unwiderruflich gelöscht.")
        }
#endif
    }

    // MARK: - Sidebar

    @ViewBuilder
    private var sidebarContent: some View {
        if viewModel.isLoading && viewModel.users.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.users.isEmpty {
            emptyContent
        } else {
            List(viewModel.users, selection: $selectedUser) { user in
                UserRowView(user: user)
                    .tag(user)
                    .accessibilityIdentifier("userRow_\(user.id)")
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            viewModel.requestDelete(user: user)
                        } label: {
                            Label(String(localized: "button_delete"), systemImage: "trash")
                        }
                    }
            }
            .listStyle(.insetGrouped)
            .accessibilityIdentifier("userList")
        }
    }

    @ViewBuilder
    private var emptyContent: some View {
        if viewModel.searchText.isEmpty {
            EmptyStateView(
                title: NSLocalizedString("empty_state_title", comment: ""),
                subtitle: NSLocalizedString("empty_state_subtitle", comment: ""),
                systemImage: "person.3"
            )
        } else {
            EmptyStateView(
                title: NSLocalizedString("empty_search_title", comment: ""),
                subtitle: NSLocalizedString("empty_search_subtitle", comment: ""),
                systemImage: "magnifyingglass"
            )
        }
    }

    // MARK: - Detail (iPad)

    @ViewBuilder
    private var detailContent: some View {
        if let user = selectedUser {
            UserDetailView(
                user: user,
                listViewModel: viewModel,
                service: service,
                onDeleted: { selectedUser = nil }
            )
        } else {
            EmptyStateView(
                title: NSLocalizedString("detail_empty_title", comment: ""),
                subtitle: NSLocalizedString("detail_empty_subtitle", comment: ""),
                systemImage: "person.circle"
            )
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
#if DEBUG
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button {
                    viewModel.showSeedConfirmation = true
                } label: {
                    Label("10 Testbenutzer anlegen", systemImage: "person.3.fill")
                }

                Button(role: .destructive) {
                    viewModel.showDeleteAllConfirmation = true
                } label: {
                    Label("Alle löschen", systemImage: "trash.fill")
                }
            } label: {
                Label("Debug", systemImage: "hammer.fill")
                    .foregroundStyle(.orange)
            }
        }
#endif

        ToolbarItem(placement: .primaryAction) {
            Button {
                showCreateSheet = true
            } label: {
                Label(String(localized: "button_new_user"), systemImage: "person.badge.plus")
            }
            .accessibilityIdentifier("btn_newUser")
        }

        ToolbarItem(placement: .bottomBar) {
            Text(String(format: NSLocalizedString("user_count", comment: ""), viewModel.users.count))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
