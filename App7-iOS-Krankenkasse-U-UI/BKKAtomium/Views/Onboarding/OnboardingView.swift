import SwiftUI

// MARK: - Onboarding-Seite

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let gradientStart: Color
    let gradientEnd: Color
    let title: String
    let body: String
    let tag: Int
}

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        icon: "house.fill",
        gradientStart: Color(red: 0.08, green: 0.22, blue: 0.45),
        gradientEnd:   Color(red: 0.10, green: 0.38, blue: 0.28),
        title: "Ihr persönliches Dashboard",
        body:  "Behalten Sie den Überblick über alle Leistungen, Anträge und Dokumente — jederzeit und auf einen Blick.",
        tag: 0
    ),
    OnboardingPage(
        icon: "doc.text.fill",
        gradientStart: Color(red: 0.12, green: 0.50, blue: 0.30),
        gradientEnd:   Color(red: 0.06, green: 0.32, blue: 0.20),
        title: "Krankmeldung in 4 Schritten",
        body:  "Scannen Sie Ihre Arbeitsunfähigkeitsbescheinigung und reichen Sie sie verschlüsselt in wenigen Sekunden ein.",
        tag: 1
    ),
    OnboardingPage(
        icon: "star.fill",
        gradientStart: Color(red: 0.80, green: 0.50, blue: 0.10),
        gradientEnd:   Color(red: 0.55, green: 0.28, blue: 0.05),
        title: "Punkte sammeln, Prämien sichern",
        body:  "Werden Sie für gesundheitsbewusstes Verhalten belohnt. Jede Maßnahme bringt Sie Ihrer Prämie näher.",
        tag: 2
    )
]

// MARK: - Onboarding View

/// Vollbild-Onboarding, das beim ersten App-Start nach dem Login einmalig angezeigt wird.
struct OnboardingView: View {
    /// Callback, der nach Abschluss des Onboardings aufgerufen wird.
    let onFinish: () -> Void

    @State private var currentPage = 0

    private var isLastPage: Bool { currentPage == onboardingPages.count - 1 }

    var body: some View {
        ZStack {
            // Hintergrund-Gradient wechselt animiert mit der Seite
            LinearGradient(
                colors: [
                    onboardingPages[currentPage].gradientStart,
                    onboardingPages[currentPage].gradientEnd
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.45), value: currentPage)

            VStack(spacing: 0) {
                // Überspringen-Button
                HStack {
                    Spacer()
                    if !isLastPage {
                        Button("Überspringen") {
                            onFinish()
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.80))
                        .padding(.trailing, 24)
                        .padding(.top, 16)
                    }
                }

                Spacer()

                // Seiten-Inhalt (swipebar via TabView)
                TabView(selection: $currentPage) {
                    ForEach(onboardingPages) { page in
                        OnboardingPageView(page: page)
                            .tag(page.tag)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(duration: 0.5, bounce: 0.15), value: currentPage)

                Spacer()

                // Untere Navigationsleiste
                VStack(spacing: 28) {
                    // Punkte-Indikator
                    HStack(spacing: 8) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            Capsule()
                                .fill(.white.opacity(index == currentPage ? 1 : 0.35))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(duration: 0.35, bounce: 0.2), value: currentPage)
                        }
                    }

                    // Primär-Button
                    Button {
                        if isLastPage {
                            onFinish()
                        } else {
                            withAnimation(.spring(duration: 0.4, bounce: 0.1)) {
                                currentPage += 1
                            }
                        }
                    } label: {
                        Text(isLastPage ? "Jetzt starten" : "Weiter")
                            .font(.headline)
                            .foregroundStyle(onboardingPages[currentPage].gradientStart)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 32)
                    .sensoryFeedback(.impact(weight: .medium), trigger: currentPage)
                }
                .padding(.bottom, 48)
            }
        }
    }
}

// MARK: - Einzelne Onboarding-Seite

private struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 32) {
            // Icon-Kreis
            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 140, height: 140)
                Circle()
                    .fill(.white.opacity(0.10))
                    .frame(width: 110, height: 110)
                Image(systemName: page.icon)
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: appeared)
            }
            .scaleEffect(appeared ? 1 : 0.7)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(duration: 0.6, bounce: 0.3).delay(0.1), value: appeared)

            // Text
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(duration: 0.5).delay(0.2), value: appeared)

                Text(page.body)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.spring(duration: 0.5).delay(0.3), value: appeared)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            appeared = false
            // Kurze Verzögerung damit die Animation beim Seitenwechsel sichtbar ist
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                appeared = true
            }
        }
        .onDisappear { appeared = false }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
