import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = LottoViewModel()

    var body: some View {
        ZStack {
            backgroundGradient
            VStack(spacing: 48) {
                headerSection
                ballSection
                superNumberSection
                generateButton
            }
            .padding(.horizontal, 24)
        }
        .ignoresSafeArea()
    }

    // MARK: – Sections

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.08, green: 0.08, blue: 0.22),
                     Color(red: 0.14, green: 0.06, blue: 0.32)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(NSLocalizedString("lotto_title", comment: ""))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(NSLocalizedString("lotto_subtitle", comment: ""))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.top, 80)
    }

    private var ballSection: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("main_numbers_label", comment: ""))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .textCase(.uppercase)
                .kerning(1.5)

            if viewModel.mainNumbers.isEmpty {
                placeholderBalls
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                    ForEach(viewModel.mainNumbers, id: \.self) { number in
                        LottoBall(number: number, style: .main)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.mainNumbers)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var placeholderBalls: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
            ForEach(0..<6, id: \.self) { _ in
                LottoBall(number: nil, style: .placeholder)
            }
        }
    }

    private var superNumberSection: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString("super_number_label", comment: ""))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .textCase(.uppercase)
                    .kerning(1.5)
                Text(NSLocalizedString("super_number_hint", comment: ""))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.3))
            }
            Spacer()
            if viewModel.mainNumbers.isEmpty {
                LottoBall(number: nil, style: .super_placeholder)
            } else {
                LottoBall(number: viewModel.superNumber, style: .superNumber)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.superNumber)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var generateButton: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                viewModel.generate()
            }
        } label: {
            HStack(spacing: 12) {
                if viewModel.isAnimating {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "dice.fill")
                        .font(.title3)
                }
                Text(NSLocalizedString("generate_button", comment: ""))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.9, green: 0.3, blue: 0.1),
                             Color(red: 0.8, green: 0.1, blue: 0.4)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .shadow(color: .red.opacity(0.4), radius: 12, y: 6)
        }
        .disabled(viewModel.isAnimating)
        .scaleEffect(viewModel.isAnimating ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: viewModel.isAnimating)
    }
}

// MARK: – Lotto Ball

enum BallStyle {
    case main, placeholder, superNumber, super_placeholder
}

struct LottoBall: View {

    let number: Int?
    let style: BallStyle

    private var ballColor: LinearGradient {
        switch style {
        case .main:
            guard let n = number else { return grayGradient }
            return ballGradient(for: n)
        case .superNumber:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.8, blue: 0.0),
                         Color(red: 1.0, green: 0.5, blue: 0.0)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .placeholder, .super_placeholder:
            return grayGradient
        }
    }

    private var grayGradient: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.12), Color.white.opacity(0.05)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private func ballGradient(for number: Int) -> LinearGradient {
        let palette: [(Color, Color)] = [
            (Color(red: 0.2, green: 0.6, blue: 1.0), Color(red: 0.1, green: 0.3, blue: 0.8)),
            (Color(red: 0.3, green: 0.85, blue: 0.5), Color(red: 0.1, green: 0.6, blue: 0.3)),
            (Color(red: 1.0, green: 0.4, blue: 0.2), Color(red: 0.8, green: 0.1, blue: 0.1)),
            (Color(red: 0.8, green: 0.3, blue: 1.0), Color(red: 0.5, green: 0.1, blue: 0.7)),
            (Color(red: 0.2, green: 0.8, blue: 0.9), Color(red: 0.1, green: 0.5, blue: 0.7)),
            (Color(red: 1.0, green: 0.6, blue: 0.1), Color(red: 0.9, green: 0.3, blue: 0.0)),
            (Color(red: 0.9, green: 0.2, blue: 0.5), Color(red: 0.6, green: 0.1, blue: 0.3)),
        ]
        let idx = ((number - 1) / 7) % palette.count
        return LinearGradient(
            colors: [palette[idx].0, palette[idx].1],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(ballColor)
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.3), .clear],
                                center: UnitPoint(x: 0.35, y: 0.3),
                                startRadius: 0,
                                endRadius: 20
                            )
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 4, y: 3)

            if let n = number {
                Text("\(n)")
                    .font(.system(size: style == .superNumber ? 20 : 16,
                                  weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            } else {
                Text("?")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .frame(width: style == .superNumber ? 56 : 48,
               height: style == .superNumber ? 56 : 48)
    }
}

#Preview {
    ContentView()
}
