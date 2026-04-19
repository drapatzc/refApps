import SwiftUI

struct AddMeasureView: View {
    @Environment(\.dismiss) private var dismiss
    var onAdd: (BonusMeasure) -> Void

    private let availableMeasures: [(title: String, points: Int, icon: String, color: Color)] = [
        ("Gesundheits-Check-up",      30, "stethoscope",       Color(red: 0.20, green: 0.60, blue: 0.40)),
        ("Zahnvorsorge",              30, "cross.case.fill",   Color(red: 0.11, green: 0.29, blue: 0.50)),
        ("Sportabzeichen",            30, "figure.run",        Color(red: 0.80, green: 0.55, blue: 0.15)),
        ("Fitnessstudio-Nachweis",    25, "dumbbell.fill",     Color(red: 0.55, green: 0.25, blue: 0.75)),
        ("Schutzimpfung",             20, "syringe.fill",      Color(red: 0.10, green: 0.45, blue: 0.55)),
        ("Nichtraucherkurs",          30, "nosign",            Color(red: 0.80, green: 0.25, blue: 0.25)),
        ("Ernährungskurs",            25, "fork.knife",        Color(red: 0.95, green: 0.65, blue: 0.10)),
        ("Krebsfrüherkennungsnachweis", 30, "magnifyingglass.circle.fill", Color(red: 0.20, green: 0.45, blue: 0.60))
    ]

    @State private var selectedIndex: Int? = nil
    @State private var showConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Wählen Sie eine gesundheitsfördernde Maßnahme aus, für die Sie einen Nachweis einreichen möchten.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }

                Section(header: Text("Verfügbare Maßnahmen")) {
                    ForEach(Array(availableMeasures.enumerated()), id: \.offset) { index, measure in
                        Button {
                            selectedIndex = index
                        } label: {
                            HStack(spacing: AppTheme.spacingM) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(measure.color.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: measure.icon)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(measure.color)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(measure.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text("+\(measure.points) €")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(measure.color)
                                }
                                Spacer()
                                if selectedIndex == index {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(AppTheme.primary)
                                        .font(.system(size: 20))
                                }
                            }
                            .padding(.vertical, 3)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                if selectedIndex != nil {
                    Section {
                        Button {
                            showConfirm = true
                        } label: {
                            Text("Maßnahme einreichen")
                                .primaryButton()
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: AppTheme.spacingM, bottom: 4, trailing: AppTheme.spacingM))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Neue Maßnahme")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common_cancel")) { dismiss() }
                }
            }
            .confirmationDialog("Maßnahme einreichen", isPresented: $showConfirm, titleVisibility: .visible) {
                Button("Einreichen") {
                    if let idx = selectedIndex {
                        let m = availableMeasures[idx]
                        let newMeasure = BonusMeasure(
                            title: m.title,
                            points: m.points,
                            date: Date(),
                            icon: m.icon,
                            color: m.color
                        )
                        onAdd(newMeasure)
                        dismiss()
                    }
                }
                Button(String(localized: "common_cancel"), role: .cancel) {}
            } message: {
                if let idx = selectedIndex {
                    Text("'\(availableMeasures[idx].title)' wird eingereicht. Ihr Konto wird nach Prüfung gutgeschrieben.")
                }
            }
        }
    }
}

#Preview {
    AddMeasureView(onAdd: { _ in })
}
