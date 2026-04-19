import SwiftUI

struct DepartmentContact: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let phone: String
    let color: Color
}

struct MoreContactsView: View {
    private let departments: [DepartmentContact] = [
        DepartmentContact(name: "Leistungsabteilung",         description: "Erstattungen, Leistungsanträge",           phone: "0800 1111 3333", color: Color(red: 0.11, green: 0.29, blue: 0.50)),
        DepartmentContact(name: "Beitragsabteilung",          description: "Beiträge, Kontoführung",                  phone: "0800 1111 4444", color: Color(red: 0.20, green: 0.60, blue: 0.40)),
        DepartmentContact(name: "Rentenversicherung",         description: "Meldungen, Renteninformationen",           phone: "0800 1111 5555", color: Color(red: 0.55, green: 0.25, blue: 0.75)),
        DepartmentContact(name: "Auslandsreiseschutz",        description: "Versicherungsschutz im Ausland",           phone: "0800 1111 6666", color: Color(red: 0.10, green: 0.45, blue: 0.55)),
        DepartmentContact(name: "Bonusprogramm",              description: "Prämien, Maßnahmen, Auszahlungen",         phone: "0800 1111 7777", color: Color(red: 0.95, green: 0.65, blue: 0.10)),
        DepartmentContact(name: "Pflegeversicherung",         description: "Pflegegeld, Pflegeleistungen",             phone: "0800 1111 8888", color: Color(red: 0.80, green: 0.45, blue: 0.15))
    ]

    var body: some View {
        List {
            Section {
                Text("Unsere Fachabteilungen helfen Ihnen bei spezifischen Anliegen. Alle Nummern sind kostenfrei (Mo–Fr 8–20 Uhr).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }

            Section(header: Text("Fachabteilungen")) {
                ForEach(departments) { dept in
                    DepartmentRow(dept: dept)
                }
            }

            Section(header: Text("Zentrale")) {
                if let url = URL(string: "tel:080011112222") {
                    Link(destination: url) {
                        HStack(spacing: AppTheme.spacingM) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppTheme.primary.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(AppTheme.primary)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Servicenummer")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text("0800 1111 2222 · 24/7 kostenlos")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "contact_more_contacts_title"))
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct DepartmentRow: View {
    let dept: DepartmentContact
    private var callURL: URL? { URL(string: "tel:\(dept.phone.filter { $0.isNumber })") }

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(dept.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "building.2.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(dept.color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(dept.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(dept.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let url = callURL {
                    Link(dept.phone, destination: url)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(dept.color)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack { MoreContactsView() }
}
