import SwiftUI

/// Sick note wizard — four steps with an explicit progress indicator.
///
/// **Redesign vs. reference**
/// - A persistent step indicator at the top lets users see "where they are"
///   without scrolling or reading headers.
/// - Each step's content is a single card with generous spacing, instead of
///   nested view hierarchies.
/// - Transitions slide vertically (upwards) so the motion mirrors the flow
///   of a paper document being handled front-to-back.
struct SickNoteFlowView: View {

    enum Step: Int, CaseIterable {
        case info = 0, scan, edit, submit
    }

    enum Filter: String, CaseIterable {
        case auto, color, bw
        var label: String {
            switch self {
            case .auto: return String(localized: "sick_note_filter_auto")
            case .color: return String(localized: "sick_note_filter_color")
            case .bw: return String(localized: "sick_note_filter_bw")
            }
        }
    }

    @State private var step: Step = .info
    @State private var flashEnabled: Bool = false
    @State private var filter: Filter = .auto
    @State private var isSubmitting = false
    @State private var didSubmit = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            progressBar
            Group {
                switch step {
                case .info:   infoStep
                case .scan:   scanStep
                case .edit:   editStep
                case .submit: submitStep
                }
            }
            .transition(
                .asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle(stepTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: step)
    }

    private var stepTitle: String {
        switch step {
        case .info:   return String(localized: "sick_note_title")
        case .scan:   return String(localized: "sick_note_scanner_title")
        case .edit:   return String(localized: "sick_note_edit_title")
        case .submit: return String(localized: "sick_note_submit_title")
        }
    }

    // MARK: - Progress indicator

    private var progressBar: some View {
        HStack(spacing: AppTheme.spaceS) {
            ForEach(Step.allCases, id: \.self) { s in
                Capsule()
                    .fill(s.rawValue <= step.rawValue
                          ? AppTheme.primary
                          : AppTheme.peach.opacity(0.5))
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.25), value: step)
            }
        }
        .padding(.horizontal, AppTheme.spaceL)
        .padding(.vertical, AppTheme.spaceS)
    }

    // MARK: - Step 1: Info

    private var infoStep: some View {
        ScrollView {
            VStack(spacing: AppTheme.spaceL) {
                infoHero
                instructionCard(
                    number: 1,
                    icon: "doc.viewfinder.fill",
                    title: String(localized: "sick_note_step1_title"),
                    body: String(localized: "sick_note_step1_body")
                )
                instructionCard(
                    number: 2,
                    icon: "rectangle.dashed",
                    title: String(localized: "sick_note_step2_title"),
                    body: String(localized: "sick_note_step2_body")
                )
                Button {
                    step = .scan
                } label: {
                    Label(String(localized: "sick_note_start_scan"),
                          systemImage: "camera.viewfinder")
                }
                .oranoPrimaryButton()
                .padding(.top, AppTheme.spaceS)
            }
            .padding(AppTheme.spaceL)
        }
    }

    private var infoHero: some View {
        VStack(spacing: AppTheme.spaceM) {
            ZStack {
                Circle()
                    .fill(AppTheme.heroGradient)
                    .frame(width: 112, height: 112)
                    .shadow(color: AppTheme.primaryDeep.opacity(0.3), radius: 14, x: 0, y: 6)
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text(String(localized: "sick_note_info_title"))
                .font(.system(.title2, design: .serif, weight: .semibold))
                .foregroundStyle(AppTheme.ink)
            Text(String(localized: "sick_note_info_subtitle"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.spaceM)
        .frame(maxWidth: .infinity)
    }

    private func instructionCard(number: Int, icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: AppTheme.spaceM) {
            ZStack {
                Circle()
                    .fill(AppTheme.peach.opacity(0.6))
                    .frame(width: 40, height: 40)
                Text("\(number)")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primary)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: AppTheme.spaceS) {
                    Image(systemName: icon)
                        .foregroundStyle(AppTheme.primary)
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                }
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(AppTheme.spaceM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .shadow(color: AppTheme.primaryDeep.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    // MARK: - Step 2: Scan simulation

    private var scanStep: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(red: 0.1, green: 0.06, blue: 0.04)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Scan frame with corner marks.
                scanFrame

                VStack {
                    Spacer()
                    Text(String(localized: "sick_note_scanner_hint"))
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.bottom, AppTheme.spaceL)
                }
            }
            .ignoresSafeArea(edges: .horizontal)

            scanControls
                .padding(.horizontal, AppTheme.spaceL)
                .padding(.vertical, AppTheme.spaceL)
                .background(AppTheme.canvas)
        }
    }

    private var scanFrame: some View {
        GeometryReader { geo in
            let w = geo.size.width * 0.8
            let h = w * 1.41
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1.5)
                    .frame(width: w, height: h)

                // corner accents
                ForEach(Array(cornerPositions.enumerated()), id: \.offset) { _, corner in
                    cornerMark
                        .offset(x: corner.x * w / 2 - corner.x * 8,
                                y: corner.y * h / 2 - corner.y * 8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var cornerMark: some View {
        Rectangle()
            .fill(AppTheme.accent)
            .frame(width: 18, height: 3)
    }

    private var cornerPositions: [(x: CGFloat, y: CGFloat)] {
        [(-1, -1), (1, -1), (-1, 1), (1, 1)]
    }

    private var scanControls: some View {
        HStack(spacing: AppTheme.spaceL) {
            // Filter picker
            HStack(spacing: 4) {
                ForEach(Filter.allCases, id: \.self) { f in
                    Button { filter = f } label: {
                        Text(f.label)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(filter == f ? AppTheme.primary : Color.clear)
                            .foregroundStyle(filter == f ? .white : .secondary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(4)
            .background(AppTheme.peach.opacity(0.35))
            .clipShape(Capsule())

            Spacer()

            Button { flashEnabled.toggle() } label: {
                Image(systemName: flashEnabled ? "bolt.fill" : "bolt.slash.fill")
                    .font(.title3)
                    .foregroundStyle(flashEnabled ? .white : AppTheme.primary)
                    .frame(width: 44, height: 44)
                    .background(flashEnabled ? AppTheme.primary : AppTheme.peach.opacity(0.5))
                    .clipShape(Circle())
            }
            .accessibilityLabel(String(localized: "sick_note_flash"))

            Button { step = .edit } label: {
                ZStack {
                    Circle()
                        .fill(AppTheme.actionGradient)
                        .frame(width: 72, height: 72)
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 3)
                        .frame(width: 64, height: 64)
                }
            }
            .accessibilityLabel(String(localized: "sick_note_capture"))
            .accessibilityIdentifier("capture_button")
        }
    }

    // MARK: - Step 3: Edit

    private var editStep: some View {
        VStack(spacing: AppTheme.spaceL) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.radiusL)
                    .fill(Color(white: 0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.radiusL)
                            .strokeBorder(AppTheme.accent, lineWidth: 2)
                    )
                    .aspectRatio(0.71, contentMode: .fit)
                    .shadow(color: AppTheme.primaryDeep.opacity(0.3), radius: 16, x: 0, y: 8)

                VStack(spacing: AppTheme.spaceS) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.white.opacity(0.6))
                    Text("Arbeitsunfähigkeitsbescheinigung")
                        .font(.caption)
                        .foregroundStyle(Color.white.opacity(0.7))
                }

                // Crop corner handles.
                ForEach(Array(cornerPositions.enumerated()), id: \.offset) { _, corner in
                    Circle()
                        .fill(AppTheme.accent)
                        .frame(width: 18, height: 18)
                        .offset(x: corner.x * 125, y: corner.y * 170)
                }
            }
            .padding(.horizontal, AppTheme.spaceL)
            .padding(.top, AppTheme.spaceL)

            HStack(spacing: AppTheme.spaceXL) {
                editTool(icon: "crop", label: String(localized: "sick_note_edit_crop"))
                editTool(icon: "slider.horizontal.3", label: String(localized: "sick_note_edit_adjust"))
                editTool(icon: "rotate.right", label: String(localized: "sick_note_edit_rotate"))
            }
            .padding(.horizontal, AppTheme.spaceL)

            Spacer()

            Button { step = .submit } label: {
                Text(String(localized: "sick_note_edit_next"))
            }
            .oranoPrimaryButton()
            .padding(.horizontal, AppTheme.spaceL)
            .padding(.bottom, AppTheme.spaceL)
        }
    }

    private func editTool(icon: String, label: String) -> some View {
        VStack(spacing: AppTheme.spaceXS) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppTheme.primary)
                .frame(width: 52, height: 52)
                .background(AppTheme.peach.opacity(0.5))
                .clipShape(Circle())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Step 4: Submit / Success

    private var submitStep: some View {
        VStack(spacing: AppTheme.spaceL) {
            if didSubmit {
                successCard
            } else {
                summaryCard
                submitButton
            }
            Spacer(minLength: 0)
        }
        .padding(AppTheme.spaceL)
    }

    private var summaryCard: some View {
        VStack(spacing: AppTheme.spaceM) {
            ZStack {
                Circle()
                    .fill(AppTheme.heroGradient)
                    .frame(width: 112, height: 112)
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
            }
            Text(String(localized: "sick_note_submit_summary"))
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
            Text(String(localized: "sick_note_submit_description"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.spaceL)
    }

    private var submitButton: some View {
        Button(action: performSubmit) {
            if isSubmitting {
                ProgressView().tint(.white)
            } else {
                Text(String(localized: "sick_note_submit_confirm"))
            }
        }
        .oranoPrimaryButton()
        .disabled(isSubmitting)
        .accessibilityIdentifier("submit_sick_note_button")
    }

    private var successCard: some View {
        VStack(spacing: AppTheme.spaceM) {
            ZStack {
                Circle()
                    .fill(AppTheme.success.opacity(0.15))
                    .frame(width: 132, height: 132)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(AppTheme.success)
            }
            Text(String(localized: "sick_note_submit_success_title"))
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
            Text(String(localized: "sick_note_submit_success_body"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button { dismiss() } label: {
                Text(String(localized: "sick_note_done"))
            }
            .oranoPrimaryButton()
            .padding(.top, AppTheme.spaceM)
        }
        .padding(AppTheme.spaceL)
    }

    private func performSubmit() {
        isSubmitting = true
        Task {
            try? await Task.sleep(for: .milliseconds(800))
            await MainActor.run {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    isSubmitting = false
                    didSubmit = true
                }
            }
        }
    }
}
