import SwiftUI

struct UserDetailView: View {
    let user: User
    @ObservedObject var listViewModel: UserListViewModel
    let service: UserService
    let onDeleted: () -> Void

    @State private var showEditSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var currentUser: User

    init(user: User, listViewModel: UserListViewModel, service: UserService, onDeleted: @escaping () -> Void = {}) {
        self.user = user
        self.listViewModel = listViewModel
        self.service = service
        self.onDeleted = onDeleted
        _currentUser = State(initialValue: user)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                addressSection
                contactSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(currentUser.fullName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(String(localized: "button_edit")) {
                    showEditSheet = true
                }
                .accessibilityIdentifier("btn_edit")
            }
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
                .accessibilityIdentifier("btn_deleteUser")
            }
        }
        .sheet(isPresented: $showEditSheet) {
            let formVM = UserFormViewModel(service: service, user: currentUser)
            UserFormView(viewModel: formVM) { updatedUser in
                currentUser = updatedUser
                listViewModel.userWasUpdated(updatedUser)
            }
        }
        .confirmationDialog(
            String(localized: "delete_confirmation_title"),
            isPresented: $showDeleteAlert,
            titleVisibility: .visible
        ) {
            Button(String(localized: "button_delete"), role: .destructive) {
                Task { await deleteUser() }
            }
            Button(String(localized: "button_cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "delete_confirmation_message"))
        }
        // User was deleted externally (e.g. via swipe in the list on iPad)
        .onChange(of: listViewModel.users) { _, updatedUsers in
            if !updatedUsers.contains(where: { $0.id == currentUser.id }) {
                showEditSheet = false
                onDeleted()
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 16) {
            avatarView

            VStack(spacing: 4) {
                Text(currentUser.salutation.localizedLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(currentUser.firstName) \(currentUser.lastName)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(avatarColor.gradient)
                .frame(width: 80, height: 80)

            Text(initials)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    private var addressSection: some View {
        DetailSection(title: String(localized: "section_address"), systemImage: "house") {
            DetailRow(
                label: String(localized: "field_street"),
                value: "\(currentUser.street) \(currentUser.houseNumber)"
            )
            DetailRow(
                label: String(localized: "field_postal_code_city"),
                value: "\(currentUser.postalCode) \(currentUser.city)"
            )
            DetailRow(
                label: String(localized: "field_country"),
                value: currentUser.country
            )
        }
    }

    private var contactSection: some View {
        DetailSection(title: String(localized: "section_contact"), systemImage: "envelope") {
            if currentUser.email.isEmpty {
                Text(String(localized: "no_email"))
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                DetailRow(
                    label: String(localized: "field_email"),
                    value: currentUser.email,
                    link: URL(string: "mailto:\(currentUser.email)")
                )
            }
        }
    }

    // MARK: - Hilfsmethoden

    private var initials: String {
        let first = currentUser.firstName.first.map(String.init) ?? ""
        let last = currentUser.lastName.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }

    private var avatarColor: Color {
        let seed = (currentUser.firstName + currentUser.lastName).unicodeScalars.reduce(0) { $0 + $1.value }
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .teal, .indigo, .pink]
        return colors[Int(seed) % colors.count]
    }

    private func deleteUser() async {
        do {
            try await service.deleteUser(id: currentUser.id)
            showEditSheet = false
            listViewModel.users.removeAll { $0.id == currentUser.id }
            // onDeleted() is triggered by .onChange(of: listViewModel.users)
        } catch {
            // Error handling in the ViewModel
        }
    }
}

// MARK: - Hilfskonstrukte

private struct DetailSection<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    var link: URL? = nil

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .leading)

            if let link {
                Link(value, destination: link)
                    .font(.subheadline)
                    .lineLimit(2)
            } else {
                Text(value)
                    .font(.subheadline)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Divider()
                .padding(.leading, 16)
        }
    }
}
