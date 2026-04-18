import SwiftUI

/// The login screen presented when the user is not authenticated.
///
/// `LoginView` renders a full-screen hero background image, a brand header,
/// and a `LoginCard` that collects the password. After a successful login it
/// delegates the session transition to `AppState.login(name:insuranceNumber:)`.
struct LoginView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = LoginViewModel()
    @State private var showPassword = false
    @FocusState private var passwordFocused: Bool

    /// Renders the hero background, branding section, and login card.
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Hintergrundbild — Österreich Sommer ~2500m
                FamilyHeroBackground()
                    .ignoresSafeArea()

                // Dunkler Overlay-Gradient
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.1),
                        Color.black.opacity(0.55),
                        Color.black.opacity(0.75)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Branding
                    VStack(spacing: AppTheme.spacingS) {
                        Image(systemName: "cross.circle.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(.white)
                            .symbolEffect(.pulse, options: .repeating)

                        Text("BKK Atomium")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(String(localized: "login_tagline"))
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.bottom, AppTheme.spacingXXL)

                    // Login-Karte
                    LoginCard(
                        viewModel: viewModel,
                        showPassword: $showPassword,
                        passwordFocused: _passwordFocused
                    )
                    .padding(.horizontal, AppTheme.spacingM)
                    .padding(.bottom, geo.safeAreaInsets.bottom + AppTheme.spacingXXL)
                }
                .offset(y: -100)
            }
            .ignoresSafeArea(.keyboard)
            .onChange(of: viewModel.loginSucceeded) { _, succeeded in
                if succeeded {
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(300))
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            appState.login(name: "Christian Drapatz", insuranceNumber: "A987654321")
                        }
                    }
                }
            }
            .onAppear {
                passwordFocused = true
            }
        }
    }
}

/// The frosted-glass card that houses the password field, error banner, and login button.
struct LoginCard: View {
    /// The view model driving the login form state.
    @Bindable var viewModel: LoginViewModel

    /// Controls whether the password is shown in plain text.
    @Binding var showPassword: Bool

    /// Focus state for the password text field.
    @FocusState var passwordFocused: Bool
    @Environment(\.colorScheme) private var colorScheme

    /// Renders the password field, optional error banner, and the primary login button.
    var body: some View {
        VStack(spacing: AppTheme.spacingL) {
            Text(String(localized: "login_title"))
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Passwort-Feld
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "login_password_label"))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)

                HStack {
                    Group {
                        if showPassword {
                            TextField(String(localized: "login_password_placeholder"), text: $viewModel.password)
                                .accessibilityIdentifier("passwordField")
                        } else {
                            SecureField(String(localized: "login_password_placeholder"), text: $viewModel.password)
                                .accessibilityIdentifier("passwordField")
                        }
                    }
                    .focused($passwordFocused)
                    .textContentType(.password)
                    .submitLabel(.go)
                    .onSubmit {
                        Task { await viewModel.login() }
                    }

                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel(showPassword
                        ? String(localized: "login_hide_password")
                        : String(localized: "login_show_password")
                    )
                }
                .padding(AppTheme.spacingM)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS)
                        .stroke(
                            viewModel.errorMessage != nil ? Color.red.opacity(0.5) : Color(.separator),
                            lineWidth: 0.5
                        )
                )
            }

            // Fehler
            if let error = viewModel.errorMessage {
                ErrorBannerView(message: error) {
                    viewModel.clearError()
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }

            // Login-Button
            Button {
                Task { await viewModel.login() }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.8)
                    } else {
                        Text(String(localized: "login_button"))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .primaryButton()
            .disabled(!viewModel.isLoginButtonEnabled)
            .opacity(viewModel.isLoginButtonEnabled ? 1.0 : 0.6)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isLoginButtonEnabled)
            .accessibilityIdentifier("loginButton")
            .accessibilityLabel(String(localized: "login_button"))
        }
        .padding(AppTheme.spacingL)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusXL))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
    }
}

// MARK: - Hintergrund: Österreich Sommer ~2500m (Alpenwiese + Berge)

/// A full-screen background view that loads a mountain landscape photo asynchronously.
///
/// Renders the local hero image from Assets, stretched to fill the available space.
struct FamilyHeroBackground: View {

    var body: some View {
        GeometryReader { geo in
            Image("hero-login")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
        .accessibilityHidden(true)
    }
}
