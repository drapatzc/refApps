import SwiftUI

enum FeedbackType: String, CaseIterable {
    case praise      = "Lob"
    case complaint   = "Beschwerde"
    case suggestion  = "Verbesserungsvorschlag"

    var icon: String {
        switch self {
        case .praise:     return "hand.thumbsup.fill"
        case .complaint:  return "exclamationmark.bubble.fill"
        case .suggestion: return "lightbulb.fill"
        }
    }

    var color: Color {
        switch self {
        case .praise:     return Color(red: 0.20, green: 0.60, blue: 0.40)
        case .complaint:  return Color(red: 0.80, green: 0.25, blue: 0.25)
        case .suggestion: return Color(red: 0.95, green: 0.65, blue: 0.10)
        }
    }
}

struct PraiseComplaintsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: FeedbackType = .praise
    @State private var message = ""
    @State private var isSubmitting = false
    @FocusState private var focused: Bool

    private var canSend: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        List {
            Section(header: Text("Art des Anliegens")) {
                ForEach(FeedbackType.allCases, id: \.self) { type in
                    Button {
                        selectedType = type
                    } label: {
                        HStack(spacing: AppTheme.spacingM) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(type.color.opacity(0.15))
                                    .frame(width: 34, height: 34)
                                Image(systemName: type.icon)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(type.color)
                            }
                            Text(type.rawValue)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Spacer()
                            if selectedType == type {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(AppTheme.primary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Section(header: Text("Ihre Nachricht")) {
                TextEditor(text: $message)
                    .focused($focused)
                    .frame(minHeight: 140)
                    .overlay(alignment: .topLeading) {
                        if message.isEmpty {
                            Text("Was möchten Sie uns mitteilen?")
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
            }

            Section {
                Button {
                    Task {
                        focused = false
                        isSubmitting = true
                        try? await Task.sleep(for: .milliseconds(800))

                        let isSuccess = Bool.random()
                        let feedbackMsg = "\(selectedType.rawValue) erfolgreich versendet!"
                        await appState.showToast(message: feedbackMsg, isSuccess: isSuccess)

                        if isSuccess {
                            message = ""
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                dismiss()
                            }
                        }
                        isSubmitting = false
                    }
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Absenden")
                    }
                }
                .primaryButton()
                .disabled(!canSend || isSubmitting)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: AppTheme.spacingM, bottom: 4, trailing: AppTheme.spacingM))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "contact_praise_complaint_title"))
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack { PraiseComplaintsView() }
}
