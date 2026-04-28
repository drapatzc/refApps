import SwiftUI

struct ApplyBonusView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let currentPoints: Double

    @State private var selectedOption: BonusOption = .transfer
    @State private var ibanInput = ""
    @State private var isSubmitting = false

    enum BonusOption: String, CaseIterable {
        case transfer = "Überweisung"
        case voucher = "Gutschein"
        case contribution = "Beitrag reduzieren"

        var description: String {
            switch self {
            case .transfer:
                return "Geld direkt auf Ihr Konto"
            case .voucher:
                return "Gutschein für Apotheken"
            case .contribution:
                return "Reduzieren Sie Ihren Versicherungsbeitrag"
            }
        }
    }

    private var canSubmit: Bool {
        switch selectedOption {
        case .transfer:
            return !ibanInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .voucher, .contribution:
            return true
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                        Text("Aktuelles Guthaben")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.2f €", currentPoints))
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.primary)
                    }
                    .listRowBackground(Color(red: 0.20, green: 0.60, blue: 0.40).opacity(0.08))
                }

                Section(header: Text("Wie möchten Sie die Prämie nutzen?")) {
                    ForEach(BonusOption.allCases, id: \.self) { option in
                        VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(option.rawValue)
                                        .font(.subheadline.weight(.semibold))
                                    Text(option.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: selectedOption == option ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedOption == option ? Color(red: 0.20, green: 0.60, blue: 0.40) : .secondary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedOption = option
                        }
                    }
                }

                if selectedOption == .transfer {
                    Section(header: Text("Kontodetails")) {
                        TextField("IBAN eingeben", text: $ibanInput)
                            .font(.monospaced(.subheadline)())
                    }
                }

                Section {
                    Button {
                        Task {
                            isSubmitting = true
                            try? await Task.sleep(for: .milliseconds(800))

                            let isSuccess = Bool.random()
                            let msg = isSuccess ? "Prämie erfolgreich beantragt" : "Fehler beim Beantragen"
                            await appState.showToast(message: msg, isSuccess: isSuccess)

                            if isSuccess {
                                try? await Task.sleep(for: .milliseconds(500))
                                dismiss()
                            }
                            isSubmitting = false
                        }
                    } label: {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Beantragen")
                        }
                    }
                    .primaryButton()
                    .disabled(!canSubmit || isSubmitting)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: AppTheme.spacingM, bottom: 4, trailing: AppTheme.spacingM))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Prämie beantragen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common_close")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ApplyBonusView(currentPoints: 150.50)
        .environment(AppState())
}
