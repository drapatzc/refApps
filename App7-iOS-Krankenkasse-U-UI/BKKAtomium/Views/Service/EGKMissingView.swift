import SwiftUI

enum EGKStep: Int {
    case initial = 0
    case requesting = 1
    case atDoctor = 2
    case requestNewCard = 3
}

struct EGKMissingView: View {
    @Environment(AppState.self) private var appState
    @State private var currentStep: EGKStep = .initial
    @State private var showConfirm = false
    @State private var isSubmitting = false
    @State private var validUntil: Date?

    var body: some View {
        List {
            switch currentStep {
            case .initial:
                initialSection
            case .requesting:
                requestingSection
            case .atDoctor:
                atDoctorSection
            case .requestNewCard:
                requestNewCardSection
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
            Button("Anfordern") {
                Task {
                    isSubmitting = true
                    try? await Task.sleep(for: .milliseconds(800))

                    let isSuccess = Bool.random()
                    let msg = isSuccess ? "Ersatznachweis beantragt" : "Fehler beim Beantragen"
                    await appState.showToast(message: msg, isSuccess: isSuccess)

                    if isSuccess {
                        validUntil = Calendar.current.date(byAdding: .day, value: 10, to: Date())
                        currentStep = .requesting
                        try? await Task.sleep(for: .milliseconds(500))
                        currentStep = .atDoctor
                    }
                    isSubmitting = false
                }
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Ein Ersatznachweis wird erstellt und in Ihr Postfach gesendet.")
        }
    }

    private var initialSection: some View {
        Group {
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
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Ersatznachweis anfordern")
                    }
                }
                .primaryButton()
                .disabled(isSubmitting)
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
    }

    private var requestingSection: some View {
        Group {
            Section {
                VStack(spacing: AppTheme.spacingM) {
                    HStack(spacing: AppTheme.spacingM) {
                        ProgressView()
                            .tint(Color(red: 0.20, green: 0.60, blue: 0.40))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Nachweis wird angefordert")
                                .font(.headline.weight(.semibold))
                            Text("Bitte warten Sie...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listRowBackground(Color(red: 0.20, green: 0.60, blue: 0.40).opacity(0.06))
            }
        }
    }

    private var atDoctorSection: some View {
        Group {
            Section {
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    HStack(spacing: AppTheme.spacingM) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color(red: 0.20, green: 0.60, blue: 0.40))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Bescheinigung liegt vor")
                                .font(.headline.weight(.semibold))
                            Text("Beim Arzt verwendbar")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listRowBackground(Color(red: 0.20, green: 0.60, blue: 0.40).opacity(0.06))
            }

            Section(header: Text("Gültigkeitsdaten")) {
                if let validUntil {
                    HStack {
                        Text("Gültig bis")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(validUntil, style: .date)
                            .font(.subheadline.weight(.semibold))
                    }
                    HStack {
                        Text("Gültig für")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("10 Tage")
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }

            Section(header: Text("Nächste Schritte")) {
                Button {
                    currentStep = .requestNewCard
                } label: {
                    HStack {
                        Text("Neue Karte beantragen")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }

    private var requestNewCardSection: some View {
        Group {
            Section {
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    HStack(spacing: AppTheme.spacingM) {
                        Image(systemName: "creditcard")
                            .font(.system(size: 32))
                            .foregroundStyle(Color(red: 0.10, green: 0.45, blue: 0.55))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Neue Karte beantragen")
                                .font(.headline.weight(.semibold))
                            Text("Permanente Lösung")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text("Beantragen Sie eine neue Gesundheitskarte um wieder vollständig versichert zu sein.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Color(red: 0.10, green: 0.45, blue: 0.55).opacity(0.06))
            }

            Section {
                NavigationLink {
                    EGKLostView()
                } label: {
                    HStack {
                        Text("Zur Kartenverwaltung")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.primary)
                }
            }
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
