import SwiftUI

// MARK: - Destinations

/// All possible push-navigation destinations within the health tab.
enum HealthDestination: Hashable {
    /// Health data and vitals overview.
    case data
    /// Medication management.
    case medication
    /// Prevention and screening programmes.
    case prevention
    /// Vaccination record.
    case vaccination
    /// Electronic sick note (eAU).
    case eau
    /// Pregnancy information.
    case pregnancy
    /// Co-payment and cost overview.
    case costs
}

/// A value type describing a single navigable health item shown in the list.
struct HealthItem: Identifiable, Hashable {

    /// A stable random identifier for list diffing.
    let id = UUID()

    /// The SF Symbols icon name.
    let icon: String

    /// The tint color applied to the icon and its background.
    let color: Color

    /// The primary title of the health item.
    let title: String

    /// A short descriptive subtitle.
    let subtitle: String

    /// The navigation destination this item pushes to.
    let destination: HealthDestination
}

/// The health information tab showing a list of health topics.
///
/// Each row navigates to a placeholder screen for the selected health destination.
struct HealthView: View {

    /// The ordered list of health items shown in the tab.
    private let items: [HealthItem] = [
        HealthItem(
            icon: "waveform.path.ecg",
            color: Color(red: 0.80, green: 0.25, blue: 0.25),
            title: String(localized: "health_data_title"),
            subtitle: String(localized: "health_data_subtitle"),
            destination: .data
        ),
        HealthItem(
            icon: "pills.fill",
            color: Color(red: 0.55, green: 0.25, blue: 0.75),
            title: String(localized: "health_medication_title"),
            subtitle: String(localized: "health_medication_subtitle"),
            destination: .medication
        ),
        HealthItem(
            icon: "stethoscope",
            color: Color(red: 0.20, green: 0.60, blue: 0.40),
            title: String(localized: "health_prevention_title"),
            subtitle: String(localized: "health_prevention_subtitle"),
            destination: .prevention
        ),
        HealthItem(
            icon: "syringe.fill",
            color: Color(red: 0.11, green: 0.29, blue: 0.50),
            title: String(localized: "health_vaccination_title"),
            subtitle: String(localized: "health_vaccination_subtitle"),
            destination: .vaccination
        ),
        HealthItem(
            icon: "doc.text.fill",
            color: Color(red: 0.10, green: 0.45, blue: 0.55),
            title: String(localized: "health_eau_title"),
            subtitle: String(localized: "health_eau_subtitle"),
            destination: .eau
        ),
        HealthItem(
            icon: "figure.and.child.holdinghands",
            color: Color(red: 0.95, green: 0.55, blue: 0.65),
            title: String(localized: "health_pregnancy_title"),
            subtitle: String(localized: "health_pregnancy_subtitle"),
            destination: .pregnancy
        ),
        HealthItem(
            icon: "eurosign.circle.fill",
            color: Color(red: 0.95, green: 0.65, blue: 0.10),
            title: String(localized: "health_cost_title"),
            subtitle: String(localized: "health_cost_subtitle"),
            destination: .costs
        )
    ]

    /// Renders the health items list inside a navigation stack.
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    NavigationLink(value: item.destination) {
                        HealthRow(item: item)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(String(localized: "health_title"))
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: HealthDestination.self) { destination in
                destinationView(for: destination)
            }
        }
    }

    /// Returns the placeholder destination view for the given health destination.
    ///
    /// - Parameter destination: The tapped `HealthDestination`.
    /// - Returns: A `PlaceholderView` matching the destination.
    @ViewBuilder
    private func destinationView(for destination: HealthDestination) -> some View {
        switch destination {
        case .data:
            HealthDataView()
        case .medication:
            MedicationView()
        case .prevention:
            PreventionView()
        case .vaccination:
            VaccinationView()
        case .eau:
            eAUView()
        case .pregnancy:
            PregnancyView()
        case .costs:
            CostOverviewView()
        }
    }
}

/// A single row in the health list showing a tinted icon, title, and subtitle.
private struct HealthRow: View {

    /// The health item to display.
    let item: HealthItem

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
    HealthView()
        .environment(AppState())
}
