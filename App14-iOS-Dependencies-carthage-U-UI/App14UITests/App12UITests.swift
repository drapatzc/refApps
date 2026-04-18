import XCTest

final class App14UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAppLaunches() {
        XCTAssertTrue(app.navigationBars["App14 Dependencies"].exists)
    }

    func testMenuItemsExist() {
        XCTAssertTrue(app.staticTexts["1. Lottie Animation"].exists)
        XCTAssertTrue(app.staticTexts["4. Alamofire REST"].exists)
    }
}
