import XCTest
@testable import muharrir

final class ParagraphExtractionTests: XCTestCase {

    func testBasicParagraphExtraction() {
        let text = """
        # Header

        This is a paragraph that is long enough to be included in the results for testing purposes.

        Another paragraph that should be extracted because it exceeds thirty characters.
        """
        let paragraphs = Checker.extractParagraphs(from: text)
        XCTAssertEqual(paragraphs.count, 2)
    }

    func testCodeBlockSkipping() {
        let text = """
        This is regular text that should be included in paragraph extraction results.

        ```swift
        let x = 42
        print("this should be completely skipped during extraction")
        ```

        After the code block this paragraph should be included in the extraction results.
        """
        let paragraphs = Checker.extractParagraphs(from: text)
        XCTAssertEqual(paragraphs.count, 2)
        for para in paragraphs {
            XCTAssertFalse(para.contains("let x = 42"))
            XCTAssertFalse(para.contains("print("))
        }
    }

    func testNestedCodeFences() {
        let text = """
        Before code block this text should be included in paragraph results for testing.

        ```
        outer code
        ```

        Between blocks this text should also be included in paragraph results for testing.

        ```python
        inner code that should be completely skipped
        ```

        After all code blocks this final paragraph should be in results for testing.
        """
        let paragraphs = Checker.extractParagraphs(from: text)
        XCTAssertEqual(paragraphs.count, 3)
    }

    func testHeaderSkipping() {
        let text = """
        # Main Title
        ## Subtitle
        ### Section

        This paragraph below headers should be included because it exceeds thirty characters.
        """
        let paragraphs = Checker.extractParagraphs(from: text)
        XCTAssertEqual(paragraphs.count, 1)
        XCTAssertFalse(paragraphs[0].hasPrefix("#"))
    }

    func testShortLineFiltering() {
        let text = """
        Short
        Also short
        Way too brief

        This paragraph is long enough to pass the thirty character minimum filter.
        """
        let paragraphs = Checker.extractParagraphs(from: text)
        XCTAssertEqual(paragraphs.count, 1)
    }

    func testHorizontalRuleSkipping() {
        let text = """
        This paragraph before the rule should be included in extraction results.
        ---
        This paragraph after the horizontal rule should also be included.
        """
        let paragraphs = Checker.extractParagraphs(from: text)
        XCTAssertEqual(paragraphs.count, 2)
        for para in paragraphs {
            XCTAssertNotEqual(para, "---")
        }
    }

    func testCheckboxListSkipping() {
        let text = """
        Regular paragraph that should be included in the extraction results for testing.

        - [x] Completed task item
        - [ ] Uncompleted task item

        Another regular paragraph that should also be included in results.
        """
        let paragraphs = Checker.extractParagraphs(from: text)
        XCTAssertEqual(paragraphs.count, 2)
    }

    func testEmptyInput() {
        let paragraphs = Checker.extractParagraphs(from: "")
        XCTAssertTrue(paragraphs.isEmpty)
    }

    func testOnlyCodeBlocks() {
        let text = """
        ```
        all code
        nothing but code here
        ```
        """
        let paragraphs = Checker.extractParagraphs(from: text)
        XCTAssertTrue(paragraphs.isEmpty)
    }

    func testPlatformAndImpactSkipping() {
        let text = """
        **Platform: iOS** should be skipped from extraction.
        **Etki: Yüksek** should also be skipped from extraction.

        Regular text that should be included in the extraction results.
        """
        let paragraphs = Checker.extractParagraphs(from: text)
        XCTAssertEqual(paragraphs.count, 1)
    }

    func testSwiftHashtagSkipping() {
        let text = """
        #Swift tagged line should be skipped from extraction.

        Regular paragraph that should pass the extraction filter.
        """
        let paragraphs = Checker.extractParagraphs(from: text)
        XCTAssertEqual(paragraphs.count, 1)
    }
}
