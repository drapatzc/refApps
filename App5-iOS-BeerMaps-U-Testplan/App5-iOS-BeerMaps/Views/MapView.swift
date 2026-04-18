import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @ObservedObject var viewModel: MapViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [DrinkEntry]

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: entries) { entry in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: entry.latitude, longitude: entry.longitude)) {
                    DrinkMarkerView(drinkType: entry.drinkType)
                }
            }
            .ignoresSafeArea(edges: .bottom)

            // Erfolgs-Toast
            if let entry = viewModel.toastEntry {
                DrinkToast(entry: entry)
                    .padding(.bottom, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Fehler-Toast
            if let error = viewModel.errorToast {
                ErrorToast(message: error)
                    .padding(.bottom, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Locate-Button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        viewModel.centerOnUserLocation()
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.title3)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .alert(NSLocalizedString("location_denied_title", comment: ""), isPresented: $viewModel.showLocationDeniedAlert) {
            Button(NSLocalizedString("open_settings", comment: "")) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
        } message: {
            Text(NSLocalizedString("location_denied_message", comment: ""))
        }
        .onAppear {
            viewModel.requestLocationIfNeeded()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.toastEntry?.id)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.errorToast)
    }
}

struct ErrorToast: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title3)
            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct DrinkToast: View {
    let entry: DrinkEntry

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(entry.drinkType.color)
                    .frame(width: 36, height: 36)
                Image(systemName: entry.drinkType.symbolName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(NSLocalizedString("marker_placed", comment: ""))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(NSLocalizedString(entry.drinkType.localizedKey, comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
