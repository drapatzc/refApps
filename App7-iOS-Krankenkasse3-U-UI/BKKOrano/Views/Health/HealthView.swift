import SwiftUI

/// Health tab — themed hub bundling Bonus, Service and Health topics.
///
/// UX rationale: the reference app had 3 separate tabs (Service, Health,
/// Bonus) for related concerns. The new app groups them as one cohesive
/// "Gesundheit" tab with three clearly labelled areas.
struct HealthView: View {

    enum Destination: Hashable {
        case topic(HealthTopic)
        case bonus
        case service
    }

    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spaceL) {
                    heroHeader
                    featuredCards
                    topicsSection
                }
                .padding(.vertical, AppTheme.spaceL)
            }
            .background(AppTheme.canvas.ignoresSafeArea())
            .navigationTitle(String(localized: "tab_health"))
            .navigationDestination(for: Destination.self) { dest in
                switch dest {
                case .topic(let topic):
                    OranoPlaceholder(icon: topic.icon, title: topic.title)
                case .bonus:
                    BonusView()
                case .service:
                    ServiceView()
                }
            }
        }
    }

    // MARK: - Hero

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceXS) {
            Text("Ihr Gesundheitsjahr")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text("Alles, was Sie brauchen,\nauf einem Blick.")
                .font(.system(.title, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.ink)
        }
        .padding(.horizontal, AppTheme.spaceL)
    }

    // MARK: - Featured cards (Bonus + Service hub)

    private var featuredCards: some View {
        VStack(spacing: AppTheme.spaceM) {
            Button { path.append(Destination.bonus) } label: {
                featuredCard(
                    title: String(localized: "widget_bonus_title"),
                    subtitle: String(localized: "widget_bonus_subtitle"),
                    icon: "star.fill",
                    gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .buttonStyle(.plain)

            Button { path.append(Destination.service) } label: {
                featuredCard(
                    title: String(localized: "service_title"),
                    subtitle: String(localized: "service_request_certificates_subtitle"),
                    icon: "headphones.circle.fill",
                    gradient: LinearGradient(
                        colors: [AppTheme.primaryDeep, AppTheme.primary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppTheme.spaceL)
    }

    private func featuredCard(title: String, subtitle: String, icon: String, gradient: LinearGradient) -> some View {
        HStack(alignment: .center, spacing: AppTheme.spaceM) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 76, height: 76)
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "arrow.right.circle.fill")
                .font(.title)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(AppTheme.spaceM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .shadow(color: AppTheme.primaryDeep.opacity(0.25), radius: 14, x: 0, y: 6)
    }

    // MARK: - Topics

    private var topicsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceS) {
            OranoSectionHeader(
                title: String(localized: "health_title"),
                icon: "heart.fill"
            )
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.spaceM) {
                ForEach(HealthTopic.all) { topic in
                    Button {
                        path.append(Destination.topic(topic))
                    } label: {
                        topicTile(topic)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.spaceL)
        }
    }

    private func topicTile(_ topic: HealthTopic) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceM) {
            Image(systemName: topic.icon)
                .font(.title2)
                .foregroundStyle(topic.tint)
                .frame(width: 44, height: 44)
                .background(topic.tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusS, style: .continuous))
            Spacer(minLength: AppTheme.spaceS)
            Text(topic.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(2)
            Text(topic.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(AppTheme.spaceM)
        .frame(height: 160, alignment: .topLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .shadow(color: AppTheme.primaryDeep.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Health topic model

struct HealthTopic: Identifiable, Hashable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let tintHex: UInt32

    var tint: Color {
        Color(
            red: Double((tintHex >> 16) & 0xff) / 255,
            green: Double((tintHex >> 8) & 0xff) / 255,
            blue: Double(tintHex & 0xff) / 255
        )
    }

    static let all: [HealthTopic] = [
        HealthTopic(id: "data",
                    icon: "waveform.path.ecg",
                    title: String(localized: "health_data_title"),
                    subtitle: String(localized: "health_data_subtitle"),
                    tintHex: 0xD65519),
        HealthTopic(id: "medication",
                    icon: "pills.fill",
                    title: String(localized: "health_medication_title"),
                    subtitle: String(localized: "health_medication_subtitle"),
                    tintHex: 0xA93B10),
        HealthTopic(id: "prevention",
                    icon: "stethoscope",
                    title: String(localized: "health_prevention_title"),
                    subtitle: String(localized: "health_prevention_subtitle"),
                    tintHex: 0xF29948),
        HealthTopic(id: "vaccination",
                    icon: "syringe.fill",
                    title: String(localized: "health_vaccination_title"),
                    subtitle: String(localized: "health_vaccination_subtitle"),
                    tintHex: 0xC66E2F),
        HealthTopic(id: "eau",
                    icon: "doc.text.fill",
                    title: String(localized: "health_eau_title"),
                    subtitle: String(localized: "health_eau_subtitle"),
                    tintHex: 0x7A4019),
        HealthTopic(id: "pregnancy",
                    icon: "figure.and.child.holdinghands",
                    title: String(localized: "health_pregnancy_title"),
                    subtitle: String(localized: "health_pregnancy_subtitle"),
                    tintHex: 0xE67A3B),
        HealthTopic(id: "cost",
                    icon: "eurosign.circle.fill",
                    title: String(localized: "health_cost_title"),
                    subtitle: String(localized: "health_cost_subtitle"),
                    tintHex: 0xB8521A)
    ]
}

#Preview {
    HealthView()
}
