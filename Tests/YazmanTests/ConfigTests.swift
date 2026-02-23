import XCTest
@testable import yazman

final class ConfigTests: XCTestCase {

    func testDataDirPath() {
        let expected = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".yazman")
        XCTAssertEqual(Config.dataDir, expected)
    }

    func testCorpusDirPath() {
        let expected = Config.dataDir.appendingPathComponent("corpus")
        XCTAssertEqual(Config.corpusDir, expected)
    }

    func testEmbeddingsFilePath() {
        let expected = Config.dataDir.appendingPathComponent("embeddings.json")
        XCTAssertEqual(Config.embeddingsFile, expected)
    }

    func testDefaultModel() {
        XCTAssertEqual(Config.defaultModel.rawValue, "gemma3:4b")
    }

    func testEmbeddingModel() {
        XCTAssertEqual(Config.embeddingModel.rawValue, "nomic-embed-text")
    }

    func testSeedURLsNotEmpty() {
        XCTAssertFalse(Config.seedURLs.isEmpty)
    }

    func testSeedURLsAreValid() {
        for urlString in Config.seedURLs {
            XCTAssertNotNil(URL(string: urlString), "Invalid seed URL: \(urlString)")
        }
    }

    func testEnsureDirectoriesCreatesDirectories() throws {
        // This test creates real directories in ~/.yazman
        // They should already exist or be safe to create
        try Config.ensureDirectories()
        let fm = FileManager.default
        XCTAssertTrue(fm.fileExists(atPath: Config.dataDir.path))
        XCTAssertTrue(fm.fileExists(atPath: Config.corpusDir.path))
    }
}
