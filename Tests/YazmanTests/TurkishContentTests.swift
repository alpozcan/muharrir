import XCTest
@testable import yazman

/// Tests using realistic Turkish technical article content to verify
/// paragraph extraction and text chunking handle Turkish correctly.
final class TurkishContentTests: XCTestCase {

    // A realistic Turkish Swift article for testing
    static let sampleArticle = """
    # SwiftUI'de State Yönetimi

    SwiftUI, bildirimsel (declarative) bir UI framework'üdür. Geleneksel UIKit'ten farklı olarak, \
    view'ların durumunu doğrudan yönetmek yerine, state değişkenlerini kullanarak arayüzü otomatik \
    olarak günceller.

    ## @State ve @Binding

    @State property wrapper'ı, bir view'ın kendi yerel durumunu tutmasını sağlar. Değer türleri \
    (struct, enum, Int, String vb.) için kullanılır. SwiftUI, @State değişkeni her değiştiğinde \
    ilgili view'ı yeniden çizer.

    ```swift
    struct CounterView: View {
        @State private var count = 0

        var body: some View {
            Button("Sayaç: \\(count)") {
                count += 1
            }
        }
    }
    ```

    @Binding ise bir üst view'dan gelen state'e referans verir. Bu sayede alt view'lar, üst \
    view'ın durumunu değiştirebilir.

    ## @ObservedObject ve @StateObject

    Daha karmaşık veri modelleri için ObservableObject protocol'ünü kullanırız. @Published ile \
    işaretlenen property'ler değiştiğinde, ilgili view'lar otomatik olarak güncellenir.

    **Platform: iOS 14+**

    - [x] @State kullanımı
    - [ ] @EnvironmentObject örneği

    ---

    ## Sonuç

    SwiftUI'nin state yönetim sistemi, reaktif programlama prensiplerini benimseyerek veri akışını \
    tek yönlü hale getirir. Bu yaklaşım, hata ayıklamayı kolaylaştırır ve kodun test edilebilirliğini artırır.
    """

    // MARK: - Paragraph Extraction with Turkish Content

    func testExtractsRealTurkishParagraphs() {
        let paragraphs = Checker.extractParagraphs(from: Self.sampleArticle)

        // Should extract prose paragraphs, not headers/code/metadata
        XCTAssertFalse(paragraphs.isEmpty, "Paragraflar çıkarılmalı")

        for para in paragraphs {
            XCTAssertFalse(para.hasPrefix("#"), "Başlıklar dahil edilmemeli")
            XCTAssertFalse(para.hasPrefix("```"), "Kod blokları dahil edilmemeli")
            XCTAssertFalse(para.contains("@State private var"), "Kod satırları dahil edilmemeli")
            XCTAssertFalse(para.hasPrefix("- ["), "Kontrol listeleri dahil edilmemeli")
            XCTAssertNotEqual(para, "---", "Yatay çizgi dahil edilmemeli")
            XCTAssertFalse(para.hasPrefix("**Platform:"), "Platform bilgisi dahil edilmemeli")
        }
    }

    func testPreservesTurkishSpecialCharacters() {
        let paragraphs = Checker.extractParagraphs(from: Self.sampleArticle)
        let combined = paragraphs.joined(separator: " ")

        // Turkish-specific characters should be preserved
        XCTAssertTrue(combined.contains("ü"), "ü karakteri korunmalı")
        XCTAssertTrue(combined.contains("ş"), "ş karakteri korunmalı")
        XCTAssertTrue(combined.contains("ı"), "ı (dotless i) korunmalı")
        XCTAssertTrue(combined.contains("ö"), "ö karakteri korunmalı")
    }

    func testKeepsTechnicalTermsIntact() {
        let paragraphs = Checker.extractParagraphs(from: Self.sampleArticle)
        let combined = paragraphs.joined(separator: " ")

        // Technical terms should remain intact in extracted text
        XCTAssertTrue(combined.contains("SwiftUI"), "SwiftUI terimi korunmalı")
        XCTAssertTrue(combined.contains("@Binding"), "@Binding terimi korunmalı")
        XCTAssertTrue(combined.contains("ObservableObject"), "ObservableObject korunmalı")
    }

    func testSkipsCodeBlockInTurkishArticle() {
        let paragraphs = Checker.extractParagraphs(from: Self.sampleArticle)
        let combined = paragraphs.joined(separator: " ")

        XCTAssertFalse(combined.contains("count += 1"), "Kod bloğu içeriği dahil edilmemeli")
        XCTAssertFalse(combined.contains("var body: some View"), "Kod bloğu dahil edilmemeli")
    }

    // MARK: - Chunking with Turkish Content

    /// Replicate the chunking algorithm for testing.
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

    func testChunkingTurkishArticleProducesChunks() {
        let chunks = chunkText(Self.sampleArticle)
        XCTAssertGreaterThan(chunks.count, 1, "Uzun makale birden fazla chunk üretmeli")
    }

    func testChunksPreserveTurkishCharacters() {
        let turkishText = String(repeating: "Türkçe yazılım geliştirme süreçleri öğüşıç. ", count: 20)
        let chunks = chunkText(turkishText, chunkSize: 200, overlap: 50)

        XCTAssertGreaterThan(chunks.count, 1)
        for chunk in chunks {
            // Verify no character corruption in Turkish text
            XCTAssertFalse(chunk.contains("\u{FFFD}"), "Unicode replacement character olmamalı")
            XCTAssertTrue(chunk.contains("ü") || chunk.contains("ö") || chunk.contains("ş") || chunk.contains("ı"),
                          "Türkçe karakterler korunmalı")
        }
    }

    func testChunkingSentenceBoundaryWithTurkishPunctuation() {
        // Turkish sentence with period followed by space
        let text = String(repeating: "a", count: 250)
            + "Bu bir Türkçe cümledir. "
            + String(repeating: "b", count: 250)

        let chunks = chunkText(text, chunkSize: 350, overlap: 50)
        XCTAssertGreaterThan(chunks.count, 1, "Cümle sınırında bölünmeli")
    }

    // MARK: - Mixed Turkish/English content (common in tech articles)

    func testParagraphExtractionWithMixedContent() {
        let mixed = """
        Bu makalede Swift'in Codable protocol'ünü inceleyeceğiz. Codable, Encodable ve Decodable \
        protocol'lerinin birleşimidir. JSON parsing işlemlerini son derece kolaylaştırır.

        ```swift
        struct Kullanici: Codable {
            let ad: String
            let email: String
        }
        ```

        JSONDecoder sınıfı, gelen veriyi otomatik olarak struct'a dönüştürür. KeyDecodingStrategy \
        ayarları ile snake_case ve camelCase arasında otomatik dönüşüm yapılabilir.
        """

        let paragraphs = Checker.extractParagraphs(from: mixed)
        XCTAssertEqual(paragraphs.count, 2)

        // Ensure code is excluded
        let combined = paragraphs.joined(separator: " ")
        XCTAssertFalse(combined.contains("let ad: String"))
        // Ensure prose is included
        XCTAssertTrue(combined.contains("Codable"))
        XCTAssertTrue(combined.contains("JSONDecoder"))
    }

    func testVectorStoreEntryWithTurkishContent() throws {
        let entry = VectorStore.Entry(
            id: "tr-test::0",
            text: "Swift'te güçlü referans döngülerinden kaçınmak için weak ve unowned kullanılır.",
            title: "Bellek Yönetimi — ARC Rehberi",
            url: "https://example.com/bellek-yonetimi",
            embedding: [0.1, 0.2, 0.3, 0.4, 0.5]
        )

        let data = try JSONEncoder().encode(entry)
        let decoded = try JSONDecoder().decode(VectorStore.Entry.self, from: data)

        XCTAssertEqual(decoded.id, entry.id)
        XCTAssertTrue(decoded.text.contains("güçlü referans döngülerinden"))
        XCTAssertTrue(decoded.title.contains("Bellek Yönetimi"))
        XCTAssertEqual(decoded.embedding, entry.embedding)
    }

    // MARK: - Edge cases with Turkish text

    func testParagraphExtractionWithSuffixedHeaders() {
        // Turkish markdown often has possessive suffixes on headers
        let text = """
        # Uygulamanın Mimarisi

        MVVM (Model-View-ViewModel) mimarisi, iOS uygulamalarında en yaygın kullanılan yapılardan biridir.

        ## ViewModel'in Görevi

        ViewModel, view ile model arasındaki köprü görevi görür ve iş mantığını barındırır.
        """

        let paragraphs = Checker.extractParagraphs(from: text)
        XCTAssertEqual(paragraphs.count, 2)
        XCTAssertFalse(paragraphs.contains(where: { $0.contains("# ") }))
    }

    func testChunkingEmptyLinesInTurkishText() {
        let text = """
        İlk paragraf yeterince uzun bir metin içermeli ve elli karakterden fazla olmalıdır.

        İkinci paragraf da aynı şekilde uzun olmalı ve test için yeterli karakter içermelidir.

        Üçüncü paragraf son paragraf olarak yazılmış ve yine yeterince uzun olan bir metindir.
        """

        let chunks = chunkText(text, chunkSize: 100, overlap: 20)
        XCTAssertGreaterThan(chunks.count, 0)
        for chunk in chunks {
            XCTAssertGreaterThan(chunk.count, 50, "Her chunk 50 karakterden uzun olmalı")
        }
    }
}
