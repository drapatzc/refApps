import SwiftUI

struct EGKLostView: View {
    @State private var showBlockConfirm = false
    @State private var showBlockSuccess = false
    @State private var showNewCardConfirm = false
    @State private var showNewCardSuccess = false
    @State private var isBlocked = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    HStack(spacing: AppTheme.spacingM) {
                        Image(systemName: "creditcard.trianglebadge.exclamationmark")
                            .font(.system(size: 36))
                            .foregroundStyle(Color(red: 0.80, green: 0.25, blue: 0.25))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Karte verloren oder gestohlen?")
                                .font(.headline.weight(.bold))
                            Text("Handeln Sie sofort.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text("Sperren Sie Ihre Gesundheitskarte umgehend, um Missbrauch zu verhindern. Anschließend können Sie eine neue Karte beantragen.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, AppTheme.spacingXS)
                .listRowBackground(Color(red: 0.80, green: 0.25, blue: 0.25).opacity(0.06))
            }

            Section(header: Text("Schritt 1 – Karte sperren")) {
                if isBlocked {
                    HStack(spacing: AppTheme.spacingM) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color(red: 0.20, green: 0.60, blue: 0.40))
                            .font(.system(size: 22))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Karte gesperrt")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color(red: 0.20, green: 0.60, blue: 0.40))
                            Text("Ihre Gesundheitskarte wurde erfolgreich gesperrt.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                } else {
                    Button {
                        showBlockConfirm = true
                    } label: {
                        Text("Karte jetzt sperren")
                            .destructiveButton()
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: AppTheme.spacingM, bottom: 4, trailing: AppTheme.spacingM))
                }
            }

            Section(header: Text("Schritt 2 – Neue Karte beantragen")) {
                Button {
                    showNewCardConfirm = true
                } label: {
                    Text("Neue Karte beantragen")
                        .primaryButton()
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: AppTheme.spacingM, bottom: 4, trailing: AppTheme.spacingM))

                HStack(alignment: .top, spacing: AppTheme.spacingS) {
                    Image(systemName: "clock")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    Text("Eine neue Gesundheitskarte wird Ihnen innerhalb von 7–10 Werktagen zugeschickt.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section(header: Text("Sofortmaßnahmen")) {
                InfoRow2(icon: "bell.badge.fill",    title: "Kasse informieren",     detail: "Verlust unverzüglich melden – bereits erledigt mit der Sperrung.")
                InfoRow2(icon: "person.badge.minus", title: "Arztpraxis informieren", detail: "Benachrichtigen Sie Ihre Arztpraxis, wenn Sie dort regelmäßig behandelt werden.")
                InfoRow2(icon: "shield.checkered",   title: "Kein Missbrauch möglich", detail: "Nach der Sperrung ist die Karte für niemanden mehr verwendbar.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "service_egk_lost_title"))
        .navigationBarTitleDisplayMode(.large)
        .confirmationDialog("Karte sperren", isPresented: $showBlockConfirm, titleVisibility: .visible) {
            Button("Karte sperren", role: .destructive) { showBlockSuccess = true }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden. Ihre aktuelle Gesundheitskarte wird dauerhaft gesperrt.")
        }
        .alert("Karte gesperrt", isPresented: $showBlockSuccess) {
            Button("OK") { isBlocked = true }
        } message: {
            Text("Ihre Gesundheitskarte wurde erfolgreich gesperrt. Sie können jetzt eine neue Karte beantragen.")
        }
        .confirmationDialog("Neue Karte beantragen", isPresented: $showNewCardConfirm, titleVisibility: .visible) {
            Button("Beantragen") { showNewCardSuccess = true }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Eine neue Gesundheitskarte wird an Ihre hinterlegte Adresse gesendet.")
        }
        .alert("Neue Karte beantragt", isPresented: $showNewCardSuccess) {
            Button("OK") {}
        } message: {
            Text("Ihre neue Gesundheitskarte wird innerhalb von 7–10 Werktagen zugestellt.")
        }
    }
}

private struct InfoRow2: View {
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
    NavigationStack { EGKLostView() }
}
