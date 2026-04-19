import SwiftUI

/// Login screen — bold dark-orange hero with a layered glass card.
///
/// UX differs from the reference app: no full-screen photo background,
/// instead a painterly gradient with a serif "Orano" wordmark sitting
/// above a translucent card. Focus handling and error animation stay
/// close to the reference.
struct LoginView: View {

    @Environment(AppState.self) private var appState
    @State private var viewModel = LoginViewModel()
    @State private var showPassword: Bool = false
    @FocusState private var passwordFocused: Bool
    @State private var logoAppeared = false

    var body: some View {
        ZStack {
            OranoHeroBackground()

            VStack(spacing: AppTheme.spaceXL) {
                Spacer(minLength: 40)
                logo
                Spacer(minLength: 20)
                card
                Spacer(minLength: 30)
                footer
            }
            .padding(.horizontal, AppTheme.spaceL)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                logoAppeared = true
            }
            // Auto-focus the password field slightly delayed for a natural feel.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
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

    // MARK: - Logo & brand mark

    private var logo: some View {
        VStack(spacing: AppTheme.spaceM) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 112, height: 112)
                    .blur(radius: 18)
                Circle()
                    .strokeBorder(Color.white.opacity(0.6), lineWidth: 1.5)
                    .frame(width: 96, height: 96)
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(.white)
            }
            .scaleEffect(logoAppeared ? 1 : 0.6)
            .opacity(logoAppeared ? 1 : 0)

            VStack(spacing: 4) {
                Text("BKK Orano")
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, y: 2)
                Text(String(localized: "login_tagline"))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .opacity(logoAppeared ? 1 : 0)
            .offset(y: logoAppeared ? 0 : 20)
        }
    }

    // MARK: - Card

    private var card: some View {
        VStack(alignment: .leading, spacing: AppTheme.spaceM) {
            Text(String(localized: "login_title"))
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppTheme.ink)

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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.radiusXL, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusXL, style: .continuous)
                .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: AppTheme.primaryDeep.opacity(0.3), radius: 20, x: 0, y: 10)
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
        }
    }

    private var footer: some View {
        HStack(spacing: AppTheme.spaceS) {
            Image(systemName: "shield.lefthalf.filled")
            Text("Verschlüsselte Verbindung")
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(.white.opacity(0.7))
        .padding(.bottom, AppTheme.spaceM)
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
