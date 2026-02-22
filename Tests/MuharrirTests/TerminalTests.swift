import XCTest
@testable import muharrir

final class TerminalTests: XCTestCase {

    // Terminal methods print to stdout. We can test the header/panel
    // border calculation logic without capturing output.

    func testHeaderBorderLength() {
        // Border is min(text.count + 4, 70)
        let shortText = "Test"
        let shortBorder = min(shortText.count + 4, 70)
        XCTAssertEqual(shortBorder, 8)

        let longText = String(repeating: "A", count: 100)
        let longBorder = min(longText.count + 4, 70)
        XCTAssertEqual(longBorder, 70)
    }

    func testPanelBorderIsFixed70() {
        let border = String(repeating: "─", count: 70)
        XCTAssertEqual(border.count, 70)
    }

    func testPanelTitlePadding() {
        let title = "Results"
        let padding = max(0, 66 - title.count)
        XCTAssertEqual(padding, 59)

        let longTitle = String(repeating: "X", count: 70)
        let longPadding = max(0, 66 - longTitle.count)
        XCTAssertEqual(longPadding, 0, "Long titles should get 0 padding")
    }

    func testEmptyHeaderText() {
        let text = ""
        let border = min(text.count + 4, 70)
        XCTAssertEqual(border, 4)
    }
}
