import SwiftUI
import MapKit

struct DrinkMarkerView: View {
    let drinkType: DrinkType

    var body: some View {
        ZStack {
            Circle()
                .fill(drinkType.color)
                .frame(width: 36, height: 36)
                .shadow(radius: 4)

            Image(systemName: drinkType.symbolName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}
