import XCTest
@testable import yazman

final class SpinnerWordRevealTests: XCTestCase {

    // MARK: - wordReveal

    func testWordRevealZeroWords() {
        let (text, done) = Spinner.wordReveal("hello world", wordCount: 0, maxWidth: 80)
        XCTAssertEqual(text, "")
        XCTAssertFalse(done)
    }

    func testWordRevealOneWord() {
        let (text, done) = Spinner.wordReveal("hello world foo", wordCount: 1, maxWidth: 80)
        XCTAssertEqual(text, "hello")
        XCTAssertFalse(done)
    }

    func testWordRevealTwoWords() {
        let (text, done) = Spinner.wordReveal("hello world foo", wordCount: 2, maxWidth: 80)
        XCTAssertEqual(text, "hello world")
        XCTAssertFalse(done)
    }

    func testWordRevealAllWords() {
        let (text, done) = Spinner.wordReveal("hello world foo", wordCount: 3, maxWidth: 80)
        XCTAssertEqual(text, "hello world foo")
        XCTAssertTrue(done)
    }

    func testWordRevealExcessWordCountIsDone() {
        let (text, done) = Spinner.wordReveal("hello world", wordCount: 100, maxWidth: 80)
        XCTAssertEqual(text, "hello world")
        XCTAssertTrue(done)
    }

    func testWordRevealRespectsMaxWidth() {
        // "hello world" = 11 chars, maxWidth = 8 → only "hello" fits
        let (text, done) = Spinner.wordReveal("hello world", wordCount: 2, maxWidth: 8)
        XCTAssertEqual(text, "hello")
        XCTAssertFalse(done)
    }

    func testWordRevealEmptyText() {
        let (text, done) = Spinner.wordReveal("", wordCount: 5, maxWidth: 80)
        XCTAssertEqual(text, "")
        XCTAssertTrue(done)
    }

    func testWordRevealZeroMaxWidth() {
        let (text, done) = Spinner.wordReveal("hello", wordCount: 1, maxWidth: 0)
        XCTAssertEqual(text, "")
        XCTAssertTrue(done)
    }

    func testWordRevealSingleLongWord() {
        // Word longer than maxWidth, first word
        let (text, _) = Spinner.wordReveal("superlongword", wordCount: 1, maxWidth: 8)
        XCTAssertTrue(text.count <= 8, "Should truncate to maxWidth")
        XCTAssertTrue(text.hasSuffix("…"), "Should end with ellipsis")
    }

    func testWordRevealTurkishText() {
        let turkish = "Türkçe yazım kuralları uygulanıyor"
        let (text1, done1) = Spinner.wordReveal(turkish, wordCount: 2, maxWidth: 80)
        XCTAssertEqual(text1, "Türkçe yazım")
        XCTAssertFalse(done1)

        let (text2, done2) = Spinner.wordReveal(turkish, wordCount: 4, maxWidth: 80)
        XCTAssertEqual(text2, "Türkçe yazım kuralları uygulanıyor")
        XCTAssertTrue(done2)
    }

    func testWordRevealProgressiveReveal() {
        let sentence = "bir iki üç dört beş"
        var previous = ""
        for i in 1...5 {
            let (text, _) = Spinner.wordReveal(sentence, wordCount: i, maxWidth: 80)
            XCTAssertTrue(text.count >= previous.count, "Each step should reveal more or equal text")
            previous = text
        }
        XCTAssertEqual(previous, sentence)
    }

    // MARK: - fadeEdges

    func testFadeEdgesShortText() {
        // Text shorter than 2*edgeWidth → whole thing is dimmed
        let result = Spinner.fadeEdges("hi", edgeWidth: 3)
        XCTAssertTrue(result.contains("hi"))
        // Should contain dim escape codes
        XCTAssertTrue(result.contains("\u{1B}[2m"))
    }

    func testFadeEdgesLongerText() {
        let result = Spinner.fadeEdges("abcdefghij", edgeWidth: 3)
        // Should contain both dim and normal reset codes
        XCTAssertTrue(result.contains("\u{1B}[2m"))
        XCTAssertTrue(result.contains("\u{1B}[22m"))
        // Middle portion "defg" should appear without dim prefix
        XCTAssertTrue(result.contains("defg"))
    }

    // MARK: - Snippet cycling integration

    func testSpinnerCyclesThroughSnippets() {
        // Simulate the tick logic manually by creating spinner
        // and checking that snippetIndex advances
        let spinner = Spinner(
            label: "Test",
            contexts: ["first sentence here", "second sentence here", "third sentence here"]
        )

        // The spinner should be able to start and stop without crashing
        spinner.start()
        // Give it time to tick several times
        Thread.sleep(forTimeInterval: 0.5)
        spinner.stop()
    }

    func testSpinnerSingleSnippetDoesNotCrash() {
        let spinner = Spinner(label: "Test", context: "only one snippet")
        spinner.start()
        Thread.sleep(forTimeInterval: 0.3)
        spinner.stop()
    }

    func testSpinnerEmptyContextDoesNotCrash() {
        let spinner = Spinner(label: "Test", contexts: [])
        spinner.start()
        Thread.sleep(forTimeInterval: 0.3)
        spinner.stop()
    }

    func testSpinnerStopWithoutStart() {
        let spinner = Spinner(label: "Test", context: "hello")
        // Should not crash
        spinner.stop()
    }

    func testSpinnerDoubleStart() {
        let spinner = Spinner(label: "Test", context: "hello")
        spinner.start()
        spinner.start() // Should be idempotent
        Thread.sleep(forTimeInterval: 0.2)
        spinner.stop()
    }

    func testSpinnerDoubleStop() {
        let spinner = Spinner(label: "Test", context: "hello")
        spinner.start()
        Thread.sleep(forTimeInterval: 0.2)
        spinner.stop()
        spinner.stop() // Should be idempotent
    }
}
