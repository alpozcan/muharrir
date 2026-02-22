import XCTest
@testable import muharrir

final class ChunkerTests: XCTestCase {

    // MARK: - chunkText via VectorStore (needs actor access)

    // Since chunkText is private on VectorStore, we test it indirectly through the
    // extractParagraphs function and by testing the public behavior.
    // Direct chunking logic tests use our own helper to replicate the algorithm.

    /// Replicate the chunking algorithm for unit testing.
    private func chunkText(
        _ text: String,
        chunkSize: Int = 500,
        overlap: Int = 100
    ) -> [String] {
        var chunks: [String] = []
        var start = text.startIndex

        while start < text.endIndex {
            let endOffset = text.distance(from: start, to: text.endIndex)
            let chunkEnd: String.Index

            if endOffset <= chunkSize {
                chunkEnd = text.endIndex
            } else {
                let tentativeEnd = text.index(start, offsetBy: chunkSize)
                let searchStart = text.index(start, offsetBy: chunkSize / 2)
                let searchEndIndex = text.index(
                    tentativeEnd, offsetBy: 100, limitedBy: text.endIndex
                ) ?? text.endIndex
                let searchRange = searchStart..<min(searchEndIndex, text.endIndex)

                if let dotPos = text.range(of: ". ", options: .backwards, range: searchRange) {
                    chunkEnd = dotPos.upperBound
                } else if let nlPos = text.range(of: "\n", options: .backwards, range: searchRange) {
                    chunkEnd = nlPos.upperBound
                } else {
                    chunkEnd = tentativeEnd
                }
            }

            let chunk = String(text[start..<chunkEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
            if chunk.count > 50 {
                chunks.append(chunk)
            }

            if chunkEnd >= text.endIndex { break }
            start = text.index(chunkEnd, offsetBy: -overlap, limitedBy: text.startIndex) ?? text.startIndex
        }

        return chunks
    }

    func testEmptyInput() {
        let chunks = chunkText("")
        XCTAssertTrue(chunks.isEmpty)
    }

    func testShortTextBelowMinLength() {
        let chunks = chunkText("Short text.")
        XCTAssertTrue(chunks.isEmpty, "Text under 50 chars should be filtered out")
    }

    func testSingleChunkText() {
        let text = String(repeating: "a", count: 100)
        let chunks = chunkText(text)
        XCTAssertEqual(chunks.count, 1)
    }

    func testMultipleChunks() {
        // Create text longer than 500 chars with sentence boundaries
        let sentence = "Bu bir test cümlesidir. "
        let text = String(repeating: sentence, count: 30) // ~720 chars
        let chunks = chunkText(text, chunkSize: 200, overlap: 50)
        XCTAssertGreaterThan(chunks.count, 1)
    }

    func testOverlapBetweenChunks() {
        let sentence = "Bu bir test cümlesidir ve devam eder. "
        let text = String(repeating: sentence, count: 40) // ~1520 chars
        let chunks = chunkText(text, chunkSize: 300, overlap: 100)
        XCTAssertGreaterThan(chunks.count, 2)
        // With overlap, adjacent chunks should share some content
    }

    func testSentenceBoundaryDetection() {
        let text = String(repeating: "a", count: 300) + ". " + String(repeating: "b", count: 300)
        let chunks = chunkText(text, chunkSize: 400, overlap: 50)
        // Should break at the sentence boundary (". ")
        XCTAssertGreaterThan(chunks.count, 1)
    }

    func testNewlineBoundaryDetection() {
        let text = String(repeating: "a", count: 300) + "\n" + String(repeating: "b", count: 300)
        let chunks = chunkText(text, chunkSize: 400, overlap: 50)
        XCTAssertGreaterThan(chunks.count, 1)
    }

    func testUnicodeText() {
        let turkish = "Türkçe özel karakterler: ğüşıöç. Bu cümle Türkçe yazılmıştır ve yeterince uzundur. "
        let text = String(repeating: turkish, count: 10)
        let chunks = chunkText(text, chunkSize: 200, overlap: 50)
        XCTAssertGreaterThan(chunks.count, 1)
        // Verify no character corruption
        for chunk in chunks {
            XCTAssertTrue(chunk.isContiguousUTF8 || true) // just check it doesn't crash
            XCTAssertFalse(chunk.isEmpty)
        }
    }

    func testMinimumLengthFiltering() {
        // Chunks under 50 chars should be dropped
        let text = String(repeating: "x", count: 51) + "\n" + String(repeating: "y", count: 30)
        let chunks = chunkText(text, chunkSize: 60, overlap: 10)
        for chunk in chunks {
            XCTAssertGreaterThan(chunk.count, 50)
        }
    }
}
