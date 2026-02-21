import ArgumentParser
import Foundation
import OllamaSwift

struct Improve: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "RAG corpus'unu kullanarak somut iyileştirme önerileri sun."
    )

    @Argument(help: "İyileştirilecek makale dosyası", transform: { URL(fileURLWithPath: $0) })
    var article: URL

    func run() async throws {
        let client = OllamaClient()

        guard await client.isReachable() else {
            Terminal.error("Ollama çalışmıyor. Başlat: brew services start ollama")
            throw ExitCode.failure
        }

        let store = VectorStore(client: client)
        try await store.load()

        Terminal.header("İyileştirme Önerileri: \(article.lastPathComponent)")
        try await Checker.suggestImprovements(
            articlePath: article,
            client: client,
            store: store
        )
    }
}
