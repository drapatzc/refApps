import SwiftUI

struct DrinkSelectorView: View {
    @Binding var selectedDrink: DrinkType
    let onPlace: (DrinkType) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(DrinkType.allCases, id: \.self) { drink in
                    DrinkButton(
                        drink: drink,
                        isSelected: selectedDrink == drink,
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedDrink = drink
                            }
                        },
                        onLongPress: {
                            selectedDrink = drink
                            onPlace(drink)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }
}

struct DrinkButton: View {
    let drink: DrinkType
    let isSelected: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void

    @State private var pressing = false
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?

    private let holdDuration: Double = 1.5

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Hintergrundkreis
                Circle()
                    .fill(isSelected ? drink.color : Color(.systemGray5))
                    .frame(width: 56, height: 56)
                    .shadow(color: isSelected ? drink.color.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)

                // Fortschrittsring beim Long-Press
                if pressing {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 3)
                        .frame(width: 64, height: 64)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(drink.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                }

                Image(systemName: drink.symbolName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .white : .secondary)
            }
            .scaleEffect(pressing ? 1.15 : (isSelected ? 1.1 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressing)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)

            Text(NSLocalizedString(drink.localizedKey, comment: ""))
                .font(.caption2)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? drink.color : .secondary)
        }
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(
            minimumDuration: holdDuration,
            pressing: { isPressing in
                if isPressing {
                    startProgress()
                } else {
                    cancelProgress()
                }
            },
            perform: {
                finishPress()
            }
        )
    }

    private func startProgress() {
        pressing = true
        progress = 0
        let interval = 0.016 // ~60fps
        let increment = interval / holdDuration
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            DispatchQueue.main.async {
                progress = min(progress + increment, 1.0)
            }
        }
    }

    private func cancelProgress() {
        timer?.invalidate()
        timer = nil
        withAnimation(.easeOut(duration: 0.2)) {
            pressing = false
            progress = 0
        }
    }

    private func finishPress() {
        timer?.invalidate()
        timer = nil
        pressing = false
        progress = 0
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        onLongPress()
    }
}
