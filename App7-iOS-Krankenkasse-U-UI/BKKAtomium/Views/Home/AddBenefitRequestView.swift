import SwiftUI
import SwiftData

/// Sheet view for adding a new benefit request.
struct AddBenefitRequestView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = BenefitRequestViewModel()
    @State private var selectedType: BenefitRequestType = .kostenerstattung
    @State private var description = ""
    @State private var amount = ""
    @State private var isSubmitting = false
    @FocusState private var focused: Bool

    private var canSubmit: Bool {
        description.trimmingCharacters(in: .whitespacesAndNewlines).count >= 20
    }

    private var parsedAmount: Double? {
        guard !amount.isEmpty else { return nil }
        return Double(amount.replacingOccurrences(of: ",", with: "."))
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Antragstyp")) {
                    Picker("Typ", selection: $selectedType) {
                        ForEach(BenefitRequestType.allCases, id: \.self) { type in
                            HStack(spacing: AppTheme.spacingS) {
                                Image(systemName: type.icon)
                                    .foregroundStyle(AppTheme.primary)
                                Text(type.localizedName)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.automatic)
                }

                Section(header: Text("Beschreibung")) {
                    TextEditor(text: $description)
                        .focused($focused)
                        .frame(minHeight: 120)
                        .overlay(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Mindestens 20 Zeichen erforderlich...")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }

                    let charCount = description.count
                    Text("\(charCount)/20 Zeichen")
                        .font(.caption)
                        .foregroundStyle(charCount >= 20 ? .green : .secondary)
                }

                Section(header: Text("Betrag (optional)")) {
                    HStack(spacing: 8) {
                        TextField("Betrag in €", text: $amount)
                            .keyboardType(.decimalPad)

                        if !amount.isEmpty && parsedAmount != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else if !amount.isEmpty && parsedAmount == nil {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }

                Section {
                    Button {
                        Task {
                            focused = false
                            isSubmitting = true
                            try? await Task.sleep(for: .milliseconds(800))

                            do {
                                try viewModel.add(
                                    requestType: selectedType.rawValue,
                                    description: description,
                                    amount: parsedAmount
                                )

                                let successMsg = "Antrag '\(selectedType.localizedName)' erstellt!"
                                await appState.showToast(message: successMsg, isSuccess: true)

                                try? await Task.sleep(for: .milliseconds(500))
                                dismiss()
                            } catch {
                                await appState.showToast(
                                    message: "Fehler beim Erstellen des Antrags",
                                    isSuccess: false
                                )
                                isSubmitting = false
                            }
                        }
                    } label: {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Antrag erstellen")
                        }
                    }
                    .primaryButton()
                    .disabled(!canSubmit || isSubmitting)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: AppTheme.spacingM, bottom: 4, trailing: AppTheme.spacingM))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Neuer Antrag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.setup(context: modelContext)
        }
    }
}

#Preview {
    NavigationStack {
        AddBenefitRequestView()
            .environment(\.modelContext, ModelContext(ModelContainer.preview))
            .environment(AppState())
    }
}
