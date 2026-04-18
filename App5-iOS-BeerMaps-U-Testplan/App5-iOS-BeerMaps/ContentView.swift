import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var mapViewModel = MapViewModel()
    @ObservedObject private var pushManager = PushNotificationManager.shared
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                NavigationView {
                    VStack(spacing: 0) {
                        DrinkSelectorView(
                            selectedDrink: $mapViewModel.selectedDrink,
                            onPlace: { drink in
                                mapViewModel.selectedDrink = drink
                                mapViewModel.addDrinkAtCurrentLocation(context: modelContext)
                            }
                        )
                        MapView(viewModel: mapViewModel)
                    }
                    .navigationTitle(NSLocalizedString("app_title", comment: ""))
                    .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label(NSLocalizedString("tab_map", comment: ""), systemImage: "map.fill")
                }

                SettingsView()
                    .tabItem {
                        Label(NSLocalizedString("tab_settings", comment: ""), systemImage: "gear")
                    }
            }

            if let toast = pushManager.toast {
                PushToastView(content: toast) {
                    PushNotificationManager.shared.dismiss()
                }
                .padding(.top, 56)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }
        }
    }
}

struct PushToastView: View {
    let content: PushToastContent
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Header ──
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "bell.badge.fill")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 3) {
                    if !content.title.isEmpty {
                        Text(content.title)
                            .font(.subheadline).bold()
                            .foregroundStyle(Color.primary)
                    }
                    if !content.body.isEmpty {
                        Text(content.body)
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                            .lineLimit(3)
                    }
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.secondary)
                        .padding(6)
                        .background(Color(.tertiarySystemBackground), in: Circle())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            // ── Buttons (falls Kategorie mit Aktionen) ──
            if !content.actions.isEmpty {
                Divider()
                HStack(spacing: 0) {
                    ForEach(Array(content.actions.enumerated()), id: \.element.identifier) { idx, action in
                        Button {
                            onDismiss()
                        } label: {
                            Text(action.title)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(
                                    action.options.contains(.destructive) ? Color.red : Color.accentColor
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                        }
                        if idx < content.actions.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
        .padding(.horizontal, 12)
    }
}
