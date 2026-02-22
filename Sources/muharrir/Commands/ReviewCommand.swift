import ArgumentParser
import Foundation
import Ollama

struct Review: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Makaleyi bütünsel olarak değerlendir."
    )

    @Argument(help: "İncelenecek makale dosyası", transform: { URL(fileURLWithPath: $0) })
    var article: URL

    @Flag(name: .long, help: "RAG bağlamını kullanma")
    var noRag = false

    func run() async throws {
        let client = await MainActor.run { Ollama.Client.default }

        guard await client.isReachable() else {
            Terminal.error("Ollama çalışmıyor. Başlat: brew services start ollama")
            throw ExitCode.failure
        }

        let store = VectorStore(client: client)
        try await store.load()

        Terminal.header("İnceleme: \(article.lastPathComponent)")
        try await Checker.reviewArticle(
            articlePath: article,
            useRAG: !noRag,
            client: client,
            store: store
        )
    }
}
