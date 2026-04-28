import SwiftUI
import UIKit
import Observation
import Foundation

@Observable final class SickNoteViewModel {
    var capturedImage: UIImage? = nil
    var rotation: Angle = .zero
    var cropRect: CGRect? = nil
    var isSubmitting = false
    var submittedDates: [DateInterval] = []

    func addSubmissionPeriod(from startDate: Date, to endDate: Date) {
        let interval = DateInterval(start: startDate, end: endDate)
        submittedDates.append(interval)
    }

    func rotateImage() {
        rotation = Angle(degrees: rotation.degrees + 90)
        if rotation.degrees >= 360 {
            rotation = .zero
        }
    }

    func rotateCapturedImage() {
        guard var image = capturedImage else { return }
        image = rotateUIImage(image, byDegrees: 90)
        capturedImage = image
    }

    private func rotateUIImage(_ image: UIImage, byDegrees degrees: CGFloat) -> UIImage {
        let radians = degrees * CGFloat.pi / 180
        let size = image.size
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { ctx in
            ctx.cgContext.translateBy(x: size.width / 2, y: size.height / 2)
            ctx.cgContext.rotate(by: radians)
            ctx.cgContext.translateBy(x: -size.width / 2, y: -size.height / 2)
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
