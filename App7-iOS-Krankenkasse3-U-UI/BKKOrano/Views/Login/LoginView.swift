import SwiftUI

/// Login screen — v2 redesign.
///
/// Evolution from v1:
/// - Full-width landscape photograph (`hero-login`) replaces the painterly
///   gradient. A horizon line divides sky and foreground, signalling "open,
///   friendly, grounded".
/// - Brand mark drops the serif wordmark in favor of a rounded sans-serif
///   wordmark that reads as a digital-first product.
/// - The translucent card becomes a crisp white Material card with a
///   distinct elevation (Google Material style) instead of a frosted glass.
/// - The primary CTA is solid blue with a subtle shadow — no orange mix on
///   the button itself; orange is reserved for discovery and highlights.
struct LoginView: View {

    @Environment(AppState.self) private var appState
    @State private var viewModel = LoginViewModel()
    @State private var showPassword: Bool = false
    @FocusState private var passwordFocused: Bool
    @State private var cardAppeared = false

    var body: some View {
        ZStack(alignment: .top) {
            // Landscape hero image fills the screen; a blue-to-transparent
            // gradient at the bottom guarantees legibility for the card.
            GeometryReader { geo in
                Image("hero-login")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.clear, AppTheme.primaryDeep.opacity(0.35), AppTheme.primaryDeep.opacity(0.65)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                brandMark
                    .padding(.top, 70)
                Spacer()
                card
                    .padding(.horizontal, AppTheme.spaceL)
                    .padding(.bottom, AppTheme.spaceXL)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.15)) {
                cardAppeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                passwordFocused = true
            }
        }
        .onChange(of: viewModel.loginSucceeded) { _, succeeded in
            if succeeded {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    appState.login(
                        name: "Christian Drapatz",
                        insuranceNumber: "A987654321"
                    )
                }
            }
        }
    }

    // MARK: - Brand mark

    private var brandMark: some View {
        VStack(spacing: AppTheme.spaceS) {
            HStack(spacing: 10) {
                // Rounded wordmark square
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 52, height: 52)
                        .shadow(color: .black.opacity(0.18), radius: 8, y: 3)
                    Text("O")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.heroGradient)
                }
                Text(String(localized: "login_v2_app_name"))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 4, y: 1)
            }
            Text(String(localized: "login_v2_tagline"))
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.92))
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
        }
    }

    // MARK: - Card

    private var card: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceM) {
            Text(String(localized: "login_title"))
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.ink)

            Text(String(localized: "login_v2_hint"))
                .font(.footnote)
                .foregroundStyle(.secondary)

            passwordField

            if let message = viewModel.errorMessage {
                OranoErrorBanner(message: message, onDismiss: viewModel.clearError)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            Button(action: performLogin) {
                ZStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text(String(localized: "login_button"))
                    }
                }
            }
            .oranoPrimaryButton()
            .opacity(viewModel.isLoginButtonEnabled ? 1.0 : 0.55)
            .disabled(!viewModel.isLoginButtonEnabled)
            .accessibilityIdentifier("login_button")
        }
        .padding(AppTheme.spaceL)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusXL, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 22, y: 10)
        .offset(y: cardAppeared ? 0 : 40)
        .opacity(cardAppeared ? 1 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.errorMessage)
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "login_password_label"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(spacing: AppTheme.spaceS) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(AppTheme.primary)
                Group {
                    if showPassword {
                        TextField(String(localized: "login_password_placeholder"),
                                  text: $viewModel.password)
                    } else {
                        SecureField(String(localized: "login_password_placeholder"),
                                    text: $viewModel.password)
                    }
                }
                .font(.body)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.go)
                .onSubmit(performLogin)
                .focused($passwordFocused)
                .accessibilityIdentifier("login_password_field")

                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel(showPassword
                                    ? String(localized: "login_hide_password")
                                    : String(localized: "login_show_password"))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, AppTheme.spaceM)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous)
                    .strokeBorder(passwordFocused ? AppTheme.primary : .clear, lineWidth: 1.5)
                    .animation(.easeInOut(duration: 0.15), value: passwordFocused)
            )
        }
    }

    // MARK: - Actions

    private func performLogin() {
        passwordFocused = false
        Task { await viewModel.login() }
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
