import XCTest

final class MarketListemUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
    }

    func testProductCanBeAddedAndDuplicateIsPrevented() {
        addProduct(named: "Süt")
        XCTAssertTrue(element("product.row.sut").waitForExistence(timeout: 5))

        app.buttons["shopping.add.fab"].tap()
        enterProductName("SÜT")
        app.buttons["product.add.button"].tap()

        XCTAssertTrue(element("product.duplicate.message").waitForExistence(timeout: 5))
        XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "product.row.sut").count, 1)
    }

    func testPurchasedProductCanBeAddedAgainFromHistory() {
        addProduct(named: "Yumurta")

        let row = element("product.row.yumurta")
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.swipeRight()
        app.buttons["Alındı"].tap()

        app.tabBars.buttons["Geçmiş"].tap()
        let readdButton = app.buttons["history.readd.yumurta"]
        XCTAssertTrue(readdButton.waitForExistence(timeout: 5))
        readdButton.tap()

        app.tabBars.buttons["Liste"].tap()
        XCTAssertTrue(element("product.row.yumurta").waitForExistence(timeout: 5))
    }

    func testCaptureAppStoreScreenshots() {
        app.terminate()
        app.launchArguments = ["--sample-data"]
        app.launch()

        XCTAssertTrue(app.navigationBars["Market Listem"].waitForExistence(timeout: 8))
        captureScreenshot(named: "01-market-listesi")

        app.tabBars.buttons["Ev"].tap()
        XCTAssertTrue(app.navigationBars["Evdekiler"].waitForExistence(timeout: 5))
        captureScreenshot(named: "02-evdekiler")

        app.tabBars.buttons["Liste"].tap()
        app.buttons["Alışverişe Başla"].tap()
        XCTAssertTrue(app.navigationBars["Market"].waitForExistence(timeout: 5))
        captureScreenshot(named: "03-alisveris-modu")
    }

    private func addProduct(named name: String) {
        app.buttons["shopping.add.empty"].tap()
        enterProductName(name)
        app.buttons["product.add.button"].tap()
    }

    private func enterProductName(_ name: String) {
        let field = app.textFields["product.name.field"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(name)
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    private func captureScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
