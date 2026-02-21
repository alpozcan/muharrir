import ArgumentParser
import Foundation
import OllamaSwift

struct Add: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Yerel markdown/text dosyalarını corpus'a ekle."
    )

    @Argument(help: "Eklenecek dosya yolları", transform: { URL(fileURLWithPath: $0) })
    var paths: [URL]

    func run() async throws {
        try Config.ensureDirectories()

        var articles: [Article] = []

        for path in paths {
            guard FileManager.default.fileExists(atPath: path.path) else {
                Terminal.error("Dosya bulunamadı: \(path.path)")
                continue
            }

            do {
                let article = try Scraper.loadLocalFile(at: path)
                try Scraper.cacheArticle(article)
                articles.append(article)
                Terminal.success("  Eklendi: \(path.lastPathComponent)")
            } catch {
                Terminal.error("  Hata: \(path.lastPathComponent) - \(error.localizedDescription)")
            }
        }

        if !articles.isEmpty {
            Terminal.info("Embedding'ler oluşturuluyor...")
            let client = OllamaClient()
            let store = VectorStore(client: client)
            try await store.load()
            let chunks = try await store.indexArticles(articles)
            Terminal.success("\(articles.count) dosyadan \(chunks) chunk indekslendi")
        }
    }
}
