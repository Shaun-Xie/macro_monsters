import XCTest

final class MacroMonstersUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOnboardingSavesGoals() {
        let app = launchApp()

        XCTAssertTrue(app.textFields["goalCaloriesField"].waitForExistence(timeout: 5))
        app.buttons["startTrackingButton"].tap()

        XCTAssertTrue(app.tabBars.buttons["Today"].waitForExistence(timeout: 5))
    }

    func testManualFoodEntryUpdatesDailyTotals() {
        let app = launchApp()
        completeOnboarding(in: app)

        app.tabBars.buttons["Log"].tap()
        app.buttons["manualEntryButton"].tap()

        setText("Test Bowl", in: app.textFields["manualFoodNameField"])
        setText("500", in: app.textFields["manualCaloriesField"])
        app.buttons["manualAddButton"].tap()

        app.tabBars.buttons["Today"].tap()
        XCTAssertTrue(app.staticTexts["Test Bowl"].waitForExistence(timeout: 5))
    }

    func testFoodSearchEntryUpdatesDailyTotals() {
        let app = launchApp()
        completeOnboarding(in: app)

        app.tabBars.buttons["Log"].tap()
        setText("rice", in: app.textFields["foodSearchField"])
        app.buttons["foodSearchButton"].tap()
        app.buttons["Add Cooked Rice"].tap()

        app.tabBars.buttons["Today"].tap()
        XCTAssertTrue(app.staticTexts["Cooked Rice"].waitForExistence(timeout: 5))
    }

    func testUpgradePurchaseChangesBaseState() {
        let app = launchApp(arguments: ["--ui-testing-seed-currency"])
        completeOnboarding(in: app)

        app.tabBars.buttons["Upgrade"].tap()
        app.buttons["Buy Base Expansion"].tap()
        app.tabBars.buttons["Base"].tap()

        XCTAssertTrue(app.staticTexts["Base Level 2"].waitForExistence(timeout: 5))
    }

    private func launchApp(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"] + arguments
        app.launch()
        return app
    }

    private func completeOnboarding(in app: XCUIApplication) {
        if app.buttons["startTrackingButton"].waitForExistence(timeout: 5) {
            app.buttons["startTrackingButton"].tap()
        }
        XCTAssertTrue(app.tabBars.buttons["Today"].waitForExistence(timeout: 5))
    }

    private func setText(_ text: String, in element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 5))
        element.tap()
        if let currentValue = element.value as? String, !currentValue.isEmpty {
            element.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count))
        }
        element.typeText(text)
    }
}
