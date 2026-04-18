import XCTest

final class App10UITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testAppLaunches() {
        XCTAssertEqual(app.state, .runningForeground)
    }
}
