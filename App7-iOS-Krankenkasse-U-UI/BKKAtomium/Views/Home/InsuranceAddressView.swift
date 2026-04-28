import SwiftUI
import MapKit

/// View showing the insurance company's address with Maps integration.
struct InsuranceAddressView: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.4556, longitude: 7.0116),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    private let insuranceLocation = CLLocationCoordinate2D(latitude: 51.4556, longitude: 7.0116)
    private let insuranceName = "BKK Atomium"
    private let insuranceAddress = "Musterstraße 1, 45147 Essen, Deutschland"

    var body: some View {
        VStack(spacing: 0) {
            // Map
            Map(position: $position) {
                Annotation(insuranceName, coordinate: insuranceLocation) {
                    Image(systemName: "building.2.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                        .padding(4)
                        .background(Color.white)
                        .cornerRadius(4)
                }
            }
            .frame(height: 300)
            .mapStyle(.standard)

            // Address Info
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                    Text(insuranceName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(insuranceAddress)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .padding(.vertical, AppTheme.spacingS)

                HStack(spacing: AppTheme.spacingM) {
                    Button {
                        openMaps()
                    } label: {
                        Label("In Maps öffnen", systemImage: "map.fill")
                            .frame(maxWidth: .infinity)
                            .primaryButton()
                    }
                }
            }
            .padding(AppTheme.spacingM)
            .background(AppTheme.sectionBackground)

            Spacer()
        }
        .navigationTitle("Krankenkasse Adresse")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func openMaps() {
        let address = insuranceAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        // Try Apple Maps first
        if let url = URL(string: "http://maps.apple.com/?q=\(address)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NavigationStack {
        InsuranceAddressView()
    }
}
