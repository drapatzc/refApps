import Foundation

class LottoViewModel: ObservableObject {

    @Published var mainNumbers: [Int] = []
    @Published var superNumber: Int = 0
    @Published var isAnimating: Bool = false

    func generate() {
        isAnimating = true

        // Intentional: Uses the ObjC helper which contains static analyzer bugs
        let raw = LottoAnalyzerHelper.generateLottoNumbers()
        let nums = raw.map { $0.intValue }

        let superRaw = LottoAnalyzerHelper.computeMultiplier(false)
        let super6 = Int(arc4random_uniform(10))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.mainNumbers = nums
            self.superNumber = super6
            _ = superRaw // suppress unused warning – result is ignored intentionally
            self.isAnimating = false
        }
    }
}
