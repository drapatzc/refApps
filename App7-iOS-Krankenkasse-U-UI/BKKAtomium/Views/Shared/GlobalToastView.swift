#if canImport(UIKit)
import UIKit
import SwiftUI

// MARK: - Manager

/// Renders toast notifications in a dedicated UIWindow above all other views,
/// including sheets, alerts, and other modal presentations.
final class ToastOverlayManager {
    static let shared = ToastOverlayManager()
    private var overlayWindow: UIWindow?
    private init() {}

    @MainActor
    func show(toast: ToastMessage) {
        overlayWindow?.isHidden = true
        overlayWindow = nil

        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else { return }

        let window = PassthroughWindow(windowScene: scene)
        window.windowLevel = .statusBar + 1
        window.backgroundColor = .clear
        window.isUserInteractionEnabled = false

        let hosting = UIHostingController(rootView: ToastWindowContent(message: toast))
        hosting.view.backgroundColor = .clear
        window.rootViewController = hosting
        window.makeKeyAndVisible()

        self.overlayWindow = window
    }

    @MainActor
    func hide() {
        let window = overlayWindow
        self.overlayWindow = nil
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            window?.alpha = 0
        } completion: { _ in
            window?.isHidden = true
        }
    }
}

// MARK: - Passthrough Window

private final class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hit = super.hitTest(point, with: event) else { return nil }
        return hit == rootViewController?.view ? nil : hit
    }
}

// MARK: - Toast Content View

private struct ToastWindowContent: View {
    let message: ToastMessage
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: AppTheme.spacingM) {
                Image(systemName: message.isSuccess
                    ? "checkmark.circle.fill"
                    : "exclamationmark.triangle.fill"
                )
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .symbolEffect(.bounce, options: .nonRepeating)

                Text(message.message)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Spacer()
            }
            .padding(AppTheme.spacingM)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM)
                    .fill(message.isSuccess ? Color.green : Color.red)
                    .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.top, AppTheme.spacingS)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : -80)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(duration: 0.45, bounce: 0.2)) {
                appeared = true
            }
        }
    }
}
#endif
