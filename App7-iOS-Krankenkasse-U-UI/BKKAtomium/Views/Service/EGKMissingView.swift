import SwiftUI

struct EGKMissingView: View {
    @State private var showConfirm = false
    @State private var showSuccess = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    HStack(spacing: AppTheme.spacingM) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color(red: 0.10, green: 0.45, blue: 0.55))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Karte nicht dabei?")
                                .font(.headline.weight(.bold))
                            Text("Kein Problem – wir helfen Ihnen.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text("Sie haben Ihre Gesundheitskarte vergessen? Mit einem Ersatznachweis können Sie trotzdem Ihren Arzttermin wahrnehmen.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, AppTheme.spacingXS)
                .listRowBackground(Color(red: 0.10, green: 0.45, blue: 0.55).opacity(0.06))
            }

            Section(header: Text("Was ist ein Ersatznachweis?")) {
                InfoRow(icon: "doc.badge.checkmark", title: "Vorläufiges Dokument", detail: "Gilt als temporärer Versicherungsnachweis bei Ärzten und Krankenhäusern.")
                InfoRow(icon: "calendar", title: "Gültigkeitsdauer", detail: "Der Nachweis gilt für maximal 10 Tage ab Ausstellungsdatum.")
                InfoRow(icon: "envelope.fill", title: "Zustellung", detail: "Der Nachweis wird direkt in Ihr digitales Postfach gesendet.")
            }

            Section(header: Text("Nachweis anfordern")) {
                Button {
                    showConfirm = true
                } label: {
                    Text("Ersatznachweis anfordern")
                        .primaryButton()
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: AppTheme.spacingM, bottom: 4, trailing: AppTheme.spacingM))
            }

            Section {
                HStack(alignment: .top, spacing: AppTheme.spacingS) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    Text("Der Ersatznachweis gilt ausschließlich bei deutschen Arztpraxen und Krankenhäusern und ersetzt nicht die eigentliche Gesundheitskarte.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "service_egk_missing_title"))
        .navigationBarTitleDisplayMode(.large)
        .confirmationDialog(
            "Ersatznachweis anfordern",
            isPresented: $showConfirm,
            titleVisibility: .visible
        ) {
            Button("Anfordern") { showSuccess = true }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Ein Ersatznachweis wird erstellt und in Ihr Postfach gesendet.")
        }
        .alert("Ersatznachweis erstellt", isPresented: $showSuccess) {
            Button("OK") {}
        } message: {
            Text("Ihr Ersatznachweis befindet sich jetzt in Ihrem Postfach. Er ist 10 Tage gültig.")
        }
    }
}

private struct InfoRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.spacingM) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.primary)
                .font(.system(size: 16))
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 3)
    }
}

#Preview {
    NavigationStack { EGKMissingView() }
}
