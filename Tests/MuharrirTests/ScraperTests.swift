import XCTest
@testable import muharrir

final class ScraperTests: XCTestCase {

    private var tempDir: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("MuharrirTests-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    // MARK: - loadLocalFile

    func testLoadLocalFileWithTurkishMarkdown() throws {
        let content = """
        # Swift'te Async/Await Kullanımı

        Swift 5.5 ile birlikte gelen async/await yapısı, asenkron programlamayı çok daha okunabilir hale getirdi.
        Bu makalede, async/await'in temel kullanım kalıplarını inceleyeceğiz.

        ## Temel Kullanım

        Bir fonksiyonu asenkron yapmak için `async` anahtar kelimesini kullanırız.
        """
        let filePath = tempDir.appendingPathComponent("async-await-kullanimi.md")
        try content.write(to: filePath, atomically: true, encoding: .utf8)

        let article = try Scraper.loadLocalFile(at: filePath)

        XCTAssertEqual(article.title, "async-await-kullanimi")
        XCTAssertEqual(article.author, "local")
        XCTAssertEqual(article.language, "tr")
        XCTAssertTrue(article.url.contains("async-await-kullanimi.md"))
        XCTAssertTrue(article.text.contains("async/await"))
        XCTAssertTrue(article.text.contains("asenkron programlama"))
    }

    func testLoadLocalFilePreservesTurkishCharacters() throws {
        let content = "Türkçe özel karakterler: ğüşıöçĞÜŞİÖÇ. Yazılım geliştirme süreçleri hakkında bilgi."
        let filePath = tempDir.appendingPathComponent("türkçe-test.txt")
        try content.write(to: filePath, atomically: true, encoding: .utf8)

        let article = try Scraper.loadLocalFile(at: filePath)

        XCTAssertTrue(article.text.contains("ğüşıöçĞÜŞİÖÇ"))
        XCTAssertTrue(article.text.contains("süreçleri"))
    }

    func testLoadLocalFileURLFormat() throws {
        let filePath = tempDir.appendingPathComponent("test-dosya.md")
        try "İçerik".write(to: filePath, atomically: true, encoding: .utf8)

        let article = try Scraper.loadLocalFile(at: filePath)
        XCTAssertTrue(article.url.hasPrefix("file://"))
        XCTAssertTrue(article.url.contains("test-dosya.md"))
    }

    func testLoadLocalFileThrowsForMissingFile() {
        let missing = tempDir.appendingPathComponent("olmayan-dosya.md")
        XCTAssertThrowsError(try Scraper.loadLocalFile(at: missing))
    }

    // MARK: - cacheArticle / loadCachedArticles round-trip

    func testCacheAndLoadArticleRoundTrip() throws {
        let article = Article(
            url: "https://example.com/swift-programlama",
            title: "Swift ile iOS Geliştirme",
            author: "Test Yazarı",
            text: """
            Swift, Apple'ın modern programlama dilidir. Güvenli, hızlı ve ifade gücü yüksek bir dildir.
            Protocol-oriented programming yaklaşımıyla, kodunuzu daha modüler hale getirebilirsiniz.
            """,
            language: "tr"
        )

        try Scraper.cacheArticle(article)
        let loaded = try Scraper.loadCachedArticles()

        let found = loaded.first(where: { $0.url == article.url })
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.title, article.title)
        XCTAssertEqual(found?.author, article.author)
        XCTAssertEqual(found?.language, "tr")
        XCTAssertTrue(found?.text.contains("Protocol-oriented programming") ?? false)
    }

    func testCacheArticleCreatesJSONFile() throws {
        let article = Article(
            url: "https://example.com/cache-test",
            title: "Cache Test Makalesi",
            author: "Yazar",
            text: "Test içeriği yeterince uzun olmalı.",
            language: "tr"
        )

        try Scraper.cacheArticle(article)

        let files = try FileManager.default.contentsOfDirectory(
            at: Config.corpusDir,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "json" }

        XCTAssertFalse(files.isEmpty, "En az bir JSON cache dosyası olmalı")
    }

    // MARK: - Article Codable with Turkish content

    func testArticleCodableWithTurkishContent() throws {
        let article = Article(
            url: "https://example.com/değişken-yaşam-döngüsü",
            title: "Değişken Yaşam Döngüsü — Swift'te ARC",
            author: "Öğretim Görevlisi",
            text: """
            Automatic Reference Counting (ARC), Swift'in bellek yönetim mekanizmasıdır.
            Güçlü referans döngülerinden kaçınmak için weak ve unowned kullanılır.
            Closure'larda [weak self] kalıbı en yaygın kullanılan yöntemdir.
            """,
            language: "tr"
        )

        let data = try JSONEncoder().encode(article)
        let decoded = try JSONDecoder().decode(Article.self, from: data)

        XCTAssertEqual(decoded.url, article.url)
        XCTAssertEqual(decoded.title, article.title)
        XCTAssertEqual(decoded.author, article.author)
        XCTAssertTrue(decoded.text.contains("bellek yönetim"))
        XCTAssertTrue(decoded.text.contains("[weak self]"))
    }
}
