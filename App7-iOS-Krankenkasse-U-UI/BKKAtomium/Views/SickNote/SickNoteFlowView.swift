import SwiftUI

// MARK: - Flow Coordinator

/// The four sequential steps of the sick-note submission flow.
enum SickNoteStep: Int, CaseIterable {
    /// Introductory information screen.
    case info
    /// Simulated document scanner screen.
    case scanner
    /// Crop and adjust the scanned document.
    case edit
    /// Review and submit the sick note.
    case submit
}

/// The observable state shared across all steps of the sick-note flow.
///
/// Mutations on any property trigger re-renders in all views that observe this object.
@Observable
final class SickNoteFlowState {

    /// The currently active step in the four-step flow.
    var step: SickNoteStep = .info

    /// When `true`, the simulated flash is turned on in the scanner view.
    var flashEnabled: Bool = false

    /// The image filter selected for the scanned document.
    var selectedFilter: SickNoteFilter = .auto

    /// `true` while the submission network request (simulated) is in progress.
    var isSubmitting: Bool = false

    /// `true` after a successful simulated submission.
    var submissionSuccess: Bool = false
}

/// Available image processing filters for the sick-note scanner.
enum SickNoteFilter: String, CaseIterable {

    /// Automatic filter selection.
    case auto

    /// Colour scan.
    case color

    /// Black-and-white scan.
    case bw

    /// The localized display name for each filter option.
    var localizedTitle: String {
        switch self {
        case .auto: return String(localized: "sick_note_filter_auto")
        case .color: return String(localized: "sick_note_filter_color")
        case .bw: return String(localized: "sick_note_filter_bw")
        }
    }
}

// MARK: - Flow Entry View

/// The root container view for the sick-note submission flow.
///
/// Manages a shared `SickNoteFlowState` and switches between the four step views
/// (`SickNoteInfoView`, `SickNoteScannerView`, `SickNoteEditView`, `SickNoteSubmitView`)
/// with animated slide transitions. The back button in the navigation bar steps one level back;
/// the tab bar is hidden for full-screen focus.
struct SickNoteFlowView: View {

    /// The shared observable state that all step views read and write.
    @State private var state = SickNoteFlowState()
    @Environment(\.dismiss) private var dismiss

    /// Renders the current step view with an asymmetric slide-and-fade transition.
    var body: some View {
        ZStack {
            Group {
                switch state.step {
                case .info:
                    SickNoteInfoView(state: state)
                case .scanner:
                    SickNoteScannerView(state: state)
                case .edit:
                    SickNoteEditView(state: state)
                case .submit:
                    SickNoteSubmitView(state: state, onFinish: { dismiss() })
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        }
        .animation(.easeInOut(duration: 0.35), value: state.step)
        .navigationTitle(title(for: state.step))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if state.step != .info {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            goBack()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                    }
                    .accessibilityLabel(String(localized: "common_cancel"))
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    /// Returns the localized navigation title for the given step.
    ///
    /// - Parameter step: The current `SickNoteStep`.
    /// - Returns: A localized title string.
    private func title(for step: SickNoteStep) -> String {
        switch step {
        case .info: return String(localized: "sick_note_title")
        case .scanner: return String(localized: "sick_note_scanner_title")
        case .edit: return String(localized: "sick_note_edit_title")
        case .submit: return String(localized: "sick_note_submit_title")
        }
    }

    /// Moves the flow back one step by decrementing the raw value of `state.step`.
    ///
    /// Does nothing if the current step is already the first step.
    private func goBack() {
        guard let previous = SickNoteStep(rawValue: state.step.rawValue - 1) else { return }
        state.step = previous
    }
}

// MARK: - Step 1: Info

/// The first step of the sick-note flow, providing instructions before scanning.
///
/// Displays an illustration, a headline, two `InstructionCard` views, and a "Start Scan" button.
struct SickNoteInfoView: View {

    /// The shared flow state used to advance to the scanner step.
    let state: SickNoteFlowState

    /// Renders the illustration, titles, instruction cards, and start button.
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingL) {
                // Illustration
                ZStack {
                    Circle()
                        .fill(Color(red: 0.20, green: 0.60, blue: 0.40).opacity(0.12))
                        .frame(width: 140, height: 140)
                    Image(systemName: "doc.viewfinder.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color(red: 0.20, green: 0.60, blue: 0.40))
                }
                .padding(.top, AppTheme.spacingL)

                VStack(spacing: AppTheme.spacingS) {
                    Text(String(localized: "sick_note_info_title"))
                        .font(.title2.weight(.bold))
                    Text(String(localized: "sick_note_info_subtitle"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.spacingL)
                }

                // Zwei Anweisungen
                VStack(spacing: AppTheme.spacingM) {
                    InstructionCard(
                        number: 1,
                        icon: "square.on.square",
                        title: String(localized: "sick_note_step1_title"),
                        text: String(localized: "sick_note_step1_body")
                    )
                    InstructionCard(
                        number: 2,
                        icon: "viewfinder",
                        title: String(localized: "sick_note_step2_title"),
                        text: String(localized: "sick_note_step2_body")
                    )
                }
                .padding(.horizontal, AppTheme.spacingM)

                Spacer(minLength: AppTheme.spacingL)

                Button {
                    withAnimation {
                        state.step = .scanner
                    }
                } label: {
                    Text(String(localized: "sick_note_start_scan"))
                        .primaryButton()
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.bottom, AppTheme.spacingL)
            }
        }
        .background(AppTheme.groupedBackground)
    }
}

/// A numbered instruction card shown on the info step of the sick-note flow.
private struct InstructionCard: View {

    /// The step number displayed in the leading circle.
    let number: Int

    /// The SF Symbols icon shown next to the title.
    let icon: String

    /// The instruction title.
    let title: String

    /// The detailed instruction body text.
    let text: String

    /// Renders the number circle, icon, title, and body in a horizontal card layout.
    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.spacingM) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary.opacity(0.10))
                    .frame(width: 44, height: 44)
                Text("\(number)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: AppTheme.spacingS) {
                    Image(systemName: icon)
                        .foregroundStyle(AppTheme.primary)
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                }
                Text(text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(AppTheme.spacingM)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Step 2: Scanner

/// The second step of the sick-note flow, simulating a document camera scanner.
///
/// Displays a dark viewfinder with a scan frame, filter selection buttons, a flash toggle,
/// and a capture button that advances to the edit step.
struct SickNoteScannerView: View {

    /// The shared flow state used to toggle flash, select a filter, and advance to the edit step.
    let state: SickNoteFlowState

    /// Renders the simulated camera background, scan frame, filter controls, and capture bar.
    var body: some View {
        ZStack {
            // Simulierter Kamera-Hintergrund
            LinearGradient(
                colors: [Color.black, Color(white: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Scan-Rahmen
            VStack {
                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL)
                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                        .frame(width: 280, height: 380)

                    // Ecken-Akzente
                    ForEach(0..<4, id: \.self) { i in
                        CornerMark()
                            .rotationEffect(.degrees(Double(i) * 90))
                            .offset(x: i == 1 || i == 2 ? 130 : -130, y: i >= 2 ? 180 : -180)
                    }

                    Image(systemName: "doc.text")
                        .font(.system(size: 70))
                        .foregroundStyle(Color.white.opacity(0.2))
                }

                Text(String(localized: "sick_note_scanner_hint"))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.top, AppTheme.spacingL)
                    .padding(.horizontal, AppTheme.spacingL)
                    .multilineTextAlignment(.center)

                Spacer()

                // Filter-Auswahl
                HStack(spacing: AppTheme.spacingS) {
                    ForEach(SickNoteFilter.allCases, id: \.self) { filter in
                        Button {
                            state.selectedFilter = filter
                        } label: {
                            Text(filter.localizedTitle)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(state.selectedFilter == filter ? .black : .white)
                                .padding(.horizontal, AppTheme.spacingM)
                                .padding(.vertical, AppTheme.spacingS)
                                .background(
                                    Capsule()
                                        .fill(state.selectedFilter == filter ? Color.white : Color.white.opacity(0.15))
                                )
                        }
                    }
                }
                .padding(.bottom, AppTheme.spacingL)

                // Aufnehmen-Leiste
                HStack(spacing: AppTheme.spacingXL) {
                    Button {
                        state.flashEnabled.toggle()
                    } label: {
                        Image(systemName: state.flashEnabled ? "bolt.fill" : "bolt.slash.fill")
                            .font(.title3)
                            .foregroundStyle(state.flashEnabled ? .yellow : .white)
                            .frame(width: 48, height: 48)
                            .background(Circle().fill(Color.white.opacity(0.15)))
                    }
                    .accessibilityLabel(String(localized: "sick_note_flash"))

                    Button {
                        withAnimation {
                            state.step = .edit
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 78, height: 78)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 64, height: 64)
                        }
                    }
                    .accessibilityLabel(String(localized: "sick_note_capture"))

                    // Platzhalter für Symmetrie
                    Color.clear
                        .frame(width: 48, height: 48)
                }
                .padding(.bottom, AppTheme.spacingXL)
            }
        }
    }
}

/// An L-shaped corner accent mark used inside the scanner frame to highlight the scan area.
private struct CornerMark: View {

    /// Draws an L-shaped path representing one corner of the scan frame.
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 20))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 20, y: 0))
        }
        .stroke(Color.white, lineWidth: 4)
        .frame(width: 20, height: 20)
    }
}

// MARK: - Step 3: Edit

/// The third step of the sick-note flow, simulating document crop and adjustment.
///
/// Shows a dark preview area with a simulated scan result, crop handles, and tool buttons
/// for crop, adjust, and rotate. Tapping "Next" advances to the submit step.
struct SickNoteEditView: View {

    /// The shared flow state used to advance to the submit step.
    let state: SickNoteFlowState

    /// Renders the dark preview area, crop frame, and editing toolbar.
    var body: some View {
        VStack(spacing: 0) {
            // Preview
            ZStack {
                Rectangle()
                    .fill(Color(white: 0.08))

                VStack(spacing: AppTheme.spacingM) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.white.opacity(0.85))
                    Text("Arbeitsunfähigkeitsbescheinigung")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.7))
                }

                // Zuschnitt-Rahmen
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.yellow, lineWidth: 2)
                    .padding(AppTheme.spacingXL)

                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 12, height: 12)
                        .offset(
                            x: i % 2 == 0 ? -120 : 120,
                            y: i < 2 ? -200 : 200
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bearbeitungsleiste
            VStack(spacing: AppTheme.spacingM) {
                HStack(spacing: AppTheme.spacingXL) {
                    EditToolButton(icon: "crop", label: String(localized: "sick_note_edit_crop"))
                    EditToolButton(icon: "slider.horizontal.3", label: String(localized: "sick_note_edit_adjust"))
                    EditToolButton(icon: "rotate.right", label: String(localized: "sick_note_edit_rotate"))
                }
                .padding(.top, AppTheme.spacingM)

                Button {
                    withAnimation {
                        state.step = .submit
                    }
                } label: {
                    Text(String(localized: "sick_note_edit_next"))
                        .primaryButton()
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.bottom, AppTheme.spacingL)
            }
            .background(Color(.systemBackground))
        }
        .background(Color.black.ignoresSafeArea())
    }
}

/// A labelled tool button shown in the editing toolbar of `SickNoteEditView`.
private struct EditToolButton: View {

    /// The SF Symbols icon name.
    let icon: String

    /// The label text shown below the icon.
    let label: String

    /// Renders the icon and label in a vertical stack. Button action is intentionally a no-op (demo).
    var body: some View {
        Button {
            // Mock — no action
        } label: {
            VStack(spacing: AppTheme.spacingXS) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(AppTheme.primary)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(width: 80, height: 60)
        }
    }
}

// MARK: - Step 4: Submit

/// The fourth and final step of the sick-note flow.
///
/// Shows a confirmation view (preview icon, description, submit button with loading state)
/// and transitions to a success view once the simulated submission completes.
struct SickNoteSubmitView: View {

    /// The shared flow state read for `isSubmitting` and `submissionSuccess`, and written on submit.
    let state: SickNoteFlowState

    /// Called when the user taps "Done" on the success screen.
    let onFinish: () -> Void

    /// Renders either the confirmation content or the success content based on `state.submissionSuccess`.
    var body: some View {
        VStack(spacing: AppTheme.spacingL) {
            Spacer()

            if state.submissionSuccess {
                successContent
            } else {
                confirmContent
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.groupedBackground)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: state.submissionSuccess)
    }

    /// The confirmation view asking the user to submit the scanned document.
    private var confirmContent: some View {
        VStack(spacing: AppTheme.spacingL) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary.opacity(0.10))
                    .frame(width: 140, height: 140)
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(AppTheme.primary)
            }

            VStack(spacing: AppTheme.spacingS) {
                Text(String(localized: "sick_note_submit_summary"))
                    .font(.title2.weight(.bold))
                Text(String(localized: "sick_note_submit_description"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.spacingL)
            }

            Button {
                state.isSubmitting = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    state.submissionSuccess = true
                    state.isSubmitting = false
                }
            } label: {
                HStack(spacing: AppTheme.spacingS) {
                    if state.isSubmitting {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(String(localized: "sick_note_submit_confirm"))
                }
                .primaryButton()
            }
            .disabled(state.isSubmitting)
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.top, AppTheme.spacingM)
        }
    }

    /// The success view shown after the simulated submission completes.
    private var successContent: some View {
        VStack(spacing: AppTheme.spacingL) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.20, green: 0.60, blue: 0.40).opacity(0.12))
                    .frame(width: 140, height: 140)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color(red: 0.20, green: 0.60, blue: 0.40))
            }
            .transition(.scale.combined(with: .opacity))

            VStack(spacing: AppTheme.spacingS) {
                Text(String(localized: "sick_note_submit_success_title"))
                    .font(.title2.weight(.bold))
                Text(String(localized: "sick_note_submit_success_body"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.spacingL)
            }

            Button {
                onFinish()
            } label: {
                Text(String(localized: "sick_note_done"))
                    .primaryButton()
            }
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.top, AppTheme.spacingM)
        }
    }
}

#Preview {
    NavigationStack {
        SickNoteFlowView()
    }
}
