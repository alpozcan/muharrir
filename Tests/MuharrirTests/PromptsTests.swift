import XCTest
@testable import muharrir

final class PromptsTests: XCTestCase {

    // MARK: - Wording Expert Prompt

    func testWordingExpertNotEmpty() {
        XCTAssertFalse(Prompts.wordingExpert.isEmpty)
    }

    func testWordingExpertContainsTurkishInstructions() {
        let prompt = Prompts.wordingExpert
        XCTAssertTrue(prompt.contains("Türkçe"), "Prompt should reference Turkish language")
        XCTAssertTrue(prompt.contains("teknik"), "Prompt should reference technical writing")
    }

    func testWordingExpertMentionsTechnicalTermPolicy() {
        let prompt = Prompts.wordingExpert
        // Should instruct to keep technical terms in English
        XCTAssertTrue(prompt.contains("İngilizce"), "Should mention keeping terms in English")
        // Should mention specific Swift terms
        XCTAssertTrue(prompt.contains("async"), "Should mention async as a preserved term")
        XCTAssertTrue(prompt.contains("protocol"), "Should mention protocol as a preserved term")
    }

    func testWordingExpertHasResponseFormat() {
        let prompt = Prompts.wordingExpert
        XCTAssertTrue(prompt.contains("OK"), "Should instruct to write OK for good sentences")
        XCTAssertTrue(prompt.contains("Orijinal"), "Should ask to show original sentence")
        XCTAssertTrue(prompt.contains("Önerilen"), "Should ask to show suggested fix")
    }

    func testWordingExpertGrammarGuidelines() {
        let prompt = Prompts.wordingExpert
        // Should discourage passive voice
        XCTAssertTrue(prompt.contains("Pasif"), "Should mention avoiding passive voice")
        // Should encourage short sentences
        XCTAssertTrue(prompt.contains("Kısa"), "Should encourage short sentences")
    }

    // MARK: - Reviewer Prompt

    func testReviewerNotEmpty() {
        XCTAssertFalse(Prompts.reviewer.isEmpty)
    }

    func testReviewerContainsTurkishContext() {
        let prompt = Prompts.reviewer
        XCTAssertTrue(prompt.contains("Türkçe"), "Should reference Turkish language")
        XCTAssertTrue(prompt.contains("editör"), "Should describe role as editor")
    }

    func testReviewerHasEvaluationCriteria() {
        let prompt = Prompts.reviewer
        XCTAssertTrue(prompt.contains("tutarlılığı"), "Should check terminology consistency")
        XCTAssertTrue(prompt.contains("Akış"), "Should check article flow")
        XCTAssertTrue(prompt.contains("Teknik doğruluk"), "Should check technical accuracy")
        XCTAssertTrue(prompt.contains("Ton"), "Should check appropriate tone")
        XCTAssertTrue(prompt.contains("gramer"), "Should check grammar")
    }

    func testReviewerTargetsIOSDevelopers() {
        let prompt = Prompts.reviewer
        XCTAssertTrue(prompt.contains("iOS geliştirici"), "Should target iOS developers")
    }
}
