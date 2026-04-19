import SwiftUI

struct CertificateType: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct CertificateRequestView: View {
    @State private var requestedCert: CertificateType? = nil
    @State private var showSuccess = false

    private let types: [CertificateType] = [
        CertificateType(title: "Mitgliedsbescheinigung",        subtitle: "Nachweis der Krankenversicherung",         icon: "person.text.rectangle.fill", color: Color(red: 0.11, green: 0.29, blue: 0.50)),
        CertificateType(title: "Beitragsbescheinigung",         subtitle: "Für Steuer und Arbeitgeber",              icon: "banknote.fill",              color: Color(red: 0.95, green: 0.65, blue: 0.10)),
        CertificateType(title: "Zuzahlungsbefreiung",           subtitle: "Befreiung von Zuzahlungen",               icon: "checkmark.seal.fill",        color: Color(red: 0.20, green: 0.60, blue: 0.40)),
        CertificateType(title: "Familienversicherungsnachweis", subtitle: "Nachweis für Familienangehörige",          icon: "figure.2.and.child.holdinghands", color: Color(red: 0.95, green: 0.55, blue: 0.65)),
        CertificateType(title: "Arbeitgeberbescheinigung",      subtitle: "Entgeltersatzleistungen",                 icon: "building.2.fill",            color: Color(red: 0.55, green: 0.25, blue: 0.75)),
        CertificateType(title: "Auslandskrankenschein",         subtitle: "Für Reisen innerhalb der EU",             icon: "globe.europe.africa.fill",   color: Color(red: 0.10, green: 0.45, blue: 0.55))
    ]

    var body: some View {
        List {
            Section {
                Text("Fordern Sie offizielle Bescheinigungen Ihrer Krankenversicherung an. Die Zusendung erfolgt in der Regel innerhalb von 3–5 Werktagen per Post.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }

            Section(header: Text("Verfügbare Bescheinigungen")) {
                ForEach(types) { cert in
                    Button {
                        requestedCert = cert
                    } label: {
                        HStack(spacing: AppTheme.spacingM) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(cert.color.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: cert.icon)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(cert.color)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(cert.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(cert.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            Section {
                HStack(alignment: .top, spacing: AppTheme.spacingS) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(AppTheme.primary.opacity(0.7))
                        .font(.subheadline)
                    Text("Für digitale Zustellung melden Sie sich bitte telefonisch unter 0800 1111 2222 oder über das Kontaktformular.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(AppTheme.primary.opacity(0.05))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "service_request_certificates_title"))
        .navigationBarTitleDisplayMode(.large)
        .confirmationDialog(
            requestedCert.map { "\($0.title) anfordern" } ?? "",
            isPresented: Binding(get: { requestedCert != nil }, set: { if !$0 { requestedCert = nil } }),
            titleVisibility: .visible
        ) {
            Button("Anfordern") { showSuccess = true; requestedCert = nil }
            Button("Abbrechen", role: .cancel) { requestedCert = nil }
        } message: {
            Text("Die Bescheinigung wird Ihnen innerhalb von 3–5 Werktagen per Post zugestellt.")
        }
        .alert("Bescheinigung angefordert", isPresented: $showSuccess) {
            Button("OK") {}
        } message: {
            Text("Ihre Anfrage wurde erfolgreich übermittelt. Die Bescheinigung wird Ihnen in Kürze zugestellt.")
        }
    }
}

#Preview {
    NavigationStack { CertificateRequestView() }
}
