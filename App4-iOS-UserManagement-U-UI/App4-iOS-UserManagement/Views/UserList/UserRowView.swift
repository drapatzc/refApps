import SwiftUI

struct UserRowView: View {
    let user: User

    var body: some View {
        HStack(spacing: 14) {
            avatarView

            VStack(alignment: .leading, spacing: 3) {
                Text(user.fullName)
                    .font(.headline)
                    .lineLimit(1)

                Text(user.formattedAddress)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                if !user.email.isEmpty {
                    Label(user.email, systemImage: "envelope")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(avatarColor.gradient)
                .frame(width: 46, height: 46)

            Text(initials)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var initials: String {
        let first = user.firstName.first.map(String.init) ?? ""
        let last = user.lastName.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }

    private var avatarColor: Color {
        // Konsistente Farbe basierend auf Initialen
        let seed = (user.firstName + user.lastName).unicodeScalars.reduce(0) { $0 + $1.value }
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .teal, .indigo, .pink]
        return colors[Int(seed) % colors.count]
    }
}

#Preview {
    List {
        UserRowView(user: User(
            id: 1,
            salutation: .mr,
            firstName: "Max",
            lastName: "Mustermann",
            street: "Musterstraße",
            houseNumber: "42",
            postalCode: "12345",
            city: "Berlin",
            country: "Deutschland",
            email: "max@example.com"
        ))
    }
}
