import SwiftUI

// MARK: - Destinations

/// All possible push-navigation destinations within the service tab.
enum ServiceDestination: Hashable {
    /// Request a replacement for a missing eGK (health card).
    case egkMissing
    /// Report a lost eGK.
    case egkLost
    /// Request official health insurance certificates.
    case certificates
}

// MARK: - Row Model

/// A value type describing a single navigable service item shown in the list.
struct ServiceItem: Identifiable, Hashable {

    /// A stable random identifier for list diffing.
    let id = UUID()

    /// The SF Symbols icon name.
    let icon: String

    /// The tint color applied to the icon and its background.
    let color: Color

    /// The primary title of the service item.
    let title: String

    /// A short descriptive subtitle.
    let subtitle: String

    /// The navigation destination this item pushes to.
    let destination: ServiceDestination
}

// MARK: - Service View

/// The service (eGK and certificates) tab screen.
///
/// Displays two grouped sections — eGK requests and certificate requests — each containing
/// `ServiceItem` rows that navigate to placeholder screens.
struct ServiceView: View {

    /// Service items relating to the electronic health card (eGK).
    private let egkItems: [ServiceItem] = [
        ServiceItem(
            icon: "creditcard.fill",
            color: Color(red: 0.10, green: 0.45, blue: 0.55),
            title: String(localized: "service_egk_missing_title"),
            subtitle: String(localized: "service_egk_missing_subtitle"),
            destination: .egkMissing
        ),
        ServiceItem(
            icon: "creditcard.trianglebadge.exclamationmark",
            color: Color(red: 0.80, green: 0.25, blue: 0.25),
            title: String(localized: "service_egk_lost_title"),
            subtitle: String(localized: "service_egk_lost_subtitle"),
            destination: .egkLost
        )
    ]

    /// Service items relating to certificate requests.
    private let requestItems: [ServiceItem] = [
        ServiceItem(
            icon: "doc.badge.plus",
            color: Color(red: 0.20, green: 0.60, blue: 0.40),
            title: String(localized: "service_request_certificates_title"),
            subtitle: String(localized: "service_request_certificates_subtitle"),
            destination: .certificates
        )
    ]

    /// Renders the eGK and request sections in a navigation stack with type-safe destinations.
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text(String(localized: "service_section_egk"))) {
                    ForEach(egkItems) { item in
                        NavigationLink(value: item.destination) {
                            ServiceRow(item: item)
                        }
                    }
                }

                Section(header: Text(String(localized: "service_section_request"))) {
                    ForEach(requestItems) { item in
                        NavigationLink(value: item.destination) {
                            ServiceRow(item: item)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(String(localized: "service_title"))
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: ServiceDestination.self) { destination in
                destinationView(for: destination)
            }
        }
    }

    /// Returns the placeholder destination view for the given service destination.
    ///
    /// - Parameter destination: The tapped `ServiceDestination`.
    /// - Returns: A `PlaceholderView` matching the destination.
    @ViewBuilder
    private func destinationView(for destination: ServiceDestination) -> some View {
        switch destination {
        case .egkMissing:
            PlaceholderView(
                title: String(localized: "service_egk_missing_title"),
                icon: "creditcard.fill"
            )
        case .egkLost:
            PlaceholderView(
                title: String(localized: "service_egk_lost_title"),
                icon: "creditcard.trianglebadge.exclamationmark"
            )
        case .certificates:
            PlaceholderView(
                title: String(localized: "service_request_certificates_title"),
                icon: "doc.badge.plus"
            )
        }
    }
}

// MARK: - Row

/// A single row in the service list showing a tinted icon, title, and subtitle.
private struct ServiceRow: View {

    /// The service item to display.
    let item: ServiceItem

    /// Renders the icon container and text stack in a horizontal layout.
    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(item.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: item.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(item.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title): \(item.subtitle)")
    }
}

#Preview {
    ServiceView()
        .environment(AppState())
}
