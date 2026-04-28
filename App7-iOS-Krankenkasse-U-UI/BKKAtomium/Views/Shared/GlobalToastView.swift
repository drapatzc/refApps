import SwiftUI

/// A floating toast notification view that displays success/error messages.
///
/// Appears at the top of the screen with a colored banner (green for success,
/// red for error), animates in and out, and automatically dismisses after 3 seconds.
struct GlobalToastView: View {
    let message: ToastMessage

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: AppTheme.spacingM) {
                Image(systemName: message.isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)

                Text(message.message)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Spacer()
            }
            .padding(AppTheme.spacingM)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(message.isSuccess ? Color.green : Color.red)
            .cornerRadius(AppTheme.cornerRadiusM)
            .padding(AppTheme.spacingM)

            Spacer()
        }
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
    }
}

#Preview {
    VStack {
        GlobalToastView(message: ToastMessage(message: "Nachricht erfolgreich versendet!", isSuccess: true))
        Spacer()
    }
}
