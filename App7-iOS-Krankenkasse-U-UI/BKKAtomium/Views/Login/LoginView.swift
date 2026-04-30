import SwiftUI

/// The login screen presented when the user is not authenticated.
struct LoginView: View {
    @Environment(AppState.self) private var appState
    @Environment(AppThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = LoginViewModel()
    @State private var showPassword = false
    @State private var showsDebugSheet = false
    @FocusState private var passwordFocused: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // iOS 18+: Animiertes MeshGradient-Hintergrund
                // iOS 17: Fotorealistisches Alpenbild
                if #available(iOS 18, *) {
                    AnimatedMeshBackground()
                        .ignoresSafeArea()
                } else {
                    FamilyHeroBackground()
                        .ignoresSafeArea()
                }

                // Dunkler Overlay-Gradient für Lesbarkeit
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.05),
                        Color.black.opacity(0.45),
                        Color.black.opacity(0.70)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Branding — 3-Sekunden-Langdruck öffnet das Debug-Theme-Menü
                    VStack(spacing: AppTheme.spacingS) {
                        // iOS 18: .breathe für lebendigen Puls-Effekt
                        // iOS 17: .pulse als Fallback
                        if #available(iOS 18, *) {
                            Image(systemName: "cross.circle.fill")
                                .font(.system(size: 52))
                                .foregroundStyle(.white)
                                .symbolEffect(.breathe, options: .repeating)
                                .onLongPressGesture(minimumDuration: 3) {
                                    showsDebugSheet = true
                                }
                        } else {
                            Image(systemName: "cross.circle.fill")
                                .font(.system(size: 52))
                                .foregroundStyle(.white)
                                .symbolEffect(.pulse, options: .repeating)
                                .onLongPressGesture(minimumDuration: 3) {
                                    showsDebugSheet = true
                                }
                        }

                        Text("BKK Atomium")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(String(localized: "login_tagline"))
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.bottom, AppTheme.spacingXXL)
                    .sheet(isPresented: $showsDebugSheet) {
                        DebugThemeSheetView(isPresented: $showsDebugSheet)
                    }

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
            .sensoryFeedback(.success, trigger: viewModel.loginSucceeded) { _, new in new }
            .sensoryFeedback(.error, trigger: viewModel.errorMessage) { _, new in new != nil }
            .onChange(of: viewModel.loginSucceeded) { _, succeeded in
                if succeeded {
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(300))
                        withAnimation(.spring(duration: 0.4, bounce: 0.1)) {
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

// MARK: - Login Card

struct LoginCard: View {
    @Bindable var viewModel: LoginViewModel
    @Binding var showPassword: Bool
    @FocusState var passwordFocused: Bool
    @Environment(\.colorScheme) private var colorScheme

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

            // Fehler-Banner
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
            .animation(AppTheme.animationSnappy, value: viewModel.isLoginButtonEnabled)
            .accessibilityIdentifier("loginButton")
            .accessibilityLabel(String(localized: "login_button"))
        }
        .padding(AppTheme.spacingL)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusXL))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .animation(AppTheme.animationSnappy, value: viewModel.errorMessage)
    }
}

// MARK: - Animated Mesh Background (iOS 18+)

/// Sanft animierter MeshGradient in der BKK-Atomium Farbpalette (Dunkelblau / Dunkelgrün).
/// Nutzt TimelineView für flüssige 60 fps Animation ohne Battery-Drain durch withAnimation-Loop.
@available(iOS 18.0, *)
struct AnimatedMeshBackground: View {
    var body: some View {
        TimelineView(.animation) { context in
            let t = Float(context.date.timeIntervalSinceReferenceDate * 0.22)
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0,       0.5 + 0.09 * sin(t)       ],
                    [0.5 + 0.05 * cos(t * 0.75), 0.5    ],
                    [1,       0.5 - 0.07 * sin(t * 1.1) ],
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: [
                    Color(red: 0.04, green: 0.12, blue: 0.28),
                    Color(red: 0.08, green: 0.22, blue: 0.42),
                    Color(red: 0.05, green: 0.16, blue: 0.34),
                    Color(red: 0.07, green: 0.22, blue: 0.36),
                    Color(red: 0.10, green: 0.30, blue: 0.32),
                    Color(red: 0.08, green: 0.24, blue: 0.36),
                    Color(red: 0.04, green: 0.13, blue: 0.24),
                    Color(red: 0.08, green: 0.32, blue: 0.22),
                    Color(red: 0.06, green: 0.22, blue: 0.18)
                ]
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Foto-Hintergrund (iOS 17 Fallback)

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
