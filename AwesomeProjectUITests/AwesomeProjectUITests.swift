//
//  AwesomeProjectUITests
//

@testable import AwesomeProject
import XCTest

class ProfileTests: XCTestCase {
    func testProfile() throws {
        let app = XCUIApplication()
        app.launch()

        let navigation = app.navigationBars["Channels"]
        _ = navigation.waitForExistence(timeout: 5)

        let profileButton = navigation.buttons["profile"]
        _ = profileButton.waitForExistence(timeout: 5)
        profileButton.tap()

        let editButton = app.buttons["editButton"]
        _ = editButton.waitForExistence(timeout: 5)
        editButton.tap()

        _ = app.textFields.firstMatch.waitForExistence(timeout: 5)
        _ = app.textViews.firstMatch.waitForExistence(timeout: 5)

        XCTAssertEqual(app.textFields.count + app.textViews.count, 2)

        app.terminate()
    }
}
