import XCTest

final class HomeFlowUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func test_measurement_tab_shows_start_cta() {
        XCTAssertTrue(app.staticTexts["측정 시작"].waitForExistence(timeout: 3))
    }

    func test_tap_settings_gear_opens_settings() {
        let gear = app.images["gearshape"]
        if gear.waitForExistence(timeout: 3) {
            gear.tap()
            XCTAssertTrue(app.navigationBars["설정"].waitForExistence(timeout: 2))
        }
    }

    func test_history_tab_navigates() {
        app.tabBars.buttons["기록"].tap()
        let empty = app.staticTexts["아직 기록이 없습니다"]
        let trend = app.buttons["추이"]
        XCTAssertTrue(empty.waitForExistence(timeout: 2) || trend.exists)
    }
}
