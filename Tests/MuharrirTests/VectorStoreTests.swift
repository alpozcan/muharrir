import XCTest
@testable import muharrir

final class VectorStoreTests: XCTestCase {

    // MARK: - Cosine Similarity (replicate private function for testing)

    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        var dot: Float = 0
        var normA: Float = 0
        var normB: Float = 0
        for i in 0..<a.count {
            dot += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }
        let denom = sqrt(normA) * sqrt(normB)
        return denom > 0 ? dot / denom : 0
    }

    func testIdenticalVectorsMaxSimilarity() {
        let vec: [Float] = [1.0, 2.0, 3.0]
        let sim = cosineSimilarity(vec, vec)
        XCTAssertEqual(sim, 1.0, accuracy: 0.001)
    }

    func testOrthogonalVectorsZeroSimilarity() {
        let a: [Float] = [1.0, 0.0, 0.0]
        let b: [Float] = [0.0, 1.0, 0.0]
        let sim = cosineSimilarity(a, b)
        XCTAssertEqual(sim, 0.0, accuracy: 0.001)
    }

    func testOppositeVectorsNegativeSimilarity() {
        let a: [Float] = [1.0, 0.0]
        let b: [Float] = [-1.0, 0.0]
        let sim = cosineSimilarity(a, b)
        XCTAssertEqual(sim, -1.0, accuracy: 0.001)
    }

    func testEmptyVectorsReturnZero() {
        let sim = cosineSimilarity([], [])
        XCTAssertEqual(sim, 0.0)
    }

    func testMismatchedLengthsReturnZero() {
        let sim = cosineSimilarity([1.0, 2.0], [1.0])
        XCTAssertEqual(sim, 0.0)
    }

    func testZeroVectorReturnZero() {
        let a: [Float] = [0.0, 0.0, 0.0]
        let b: [Float] = [1.0, 2.0, 3.0]
        let sim = cosineSimilarity(a, b)
        XCTAssertEqual(sim, 0.0)
    }

    func testSimilarVectorsHighSimilarity() {
        let a: [Float] = [1.0, 2.0, 3.0]
        let b: [Float] = [1.1, 2.1, 3.1]
        let sim = cosineSimilarity(a, b)
        XCTAssertGreaterThan(sim, 0.99)
    }

    // MARK: - VectorStore.Entry Codable

    func testEntryEncodeDecode() throws {
        let entry = VectorStore.Entry(
            id: "test::0",
            text: "Sample text",
            title: "Test Article",
            url: "https://example.com",
            embedding: [0.1, 0.2, 0.3]
        )
        let data = try JSONEncoder().encode(entry)
        let decoded = try JSONDecoder().decode(VectorStore.Entry.self, from: data)
        XCTAssertEqual(decoded.id, entry.id)
        XCTAssertEqual(decoded.text, entry.text)
        XCTAssertEqual(decoded.title, entry.title)
        XCTAssertEqual(decoded.url, entry.url)
        XCTAssertEqual(decoded.embedding, entry.embedding)
    }

    func testEntryArrayEncodeDecode() throws {
        let entries = [
            VectorStore.Entry(id: "a::0", text: "First", title: "A", url: "http://a", embedding: [1.0]),
            VectorStore.Entry(id: "b::0", text: "Second", title: "B", url: "http://b", embedding: [2.0]),
        ]
        let data = try JSONEncoder().encode(entries)
        let decoded = try JSONDecoder().decode([VectorStore.Entry].self, from: data)
        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].id, "a::0")
        XCTAssertEqual(decoded[1].id, "b::0")
    }

    // MARK: - Article Codable

    func testArticleEncodeDecode() throws {
        let article = Article(
            url: "https://example.com/test",
            title: "Test",
            author: "Author",
            text: "Some long text content.",
            language: "tr"
        )
        let data = try JSONEncoder().encode(article)
        let decoded = try JSONDecoder().decode(Article.self, from: data)
        XCTAssertEqual(decoded.url, article.url)
        XCTAssertEqual(decoded.title, article.title)
        XCTAssertEqual(decoded.author, article.author)
        XCTAssertEqual(decoded.language, article.language)
    }

    // MARK: - SearchResult

    func testSearchResultCreation() {
        let result = SearchResult(
            text: "Sample",
            title: "Title",
            url: "https://example.com",
            similarity: 0.95
        )
        XCTAssertEqual(result.similarity, 0.95)
        XCTAssertEqual(result.title, "Title")
    }
}
