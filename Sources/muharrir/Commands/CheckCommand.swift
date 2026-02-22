import ArgumentParser
import Foundation
import Ollama

struct Check: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Makaleyi paragraf paragraf dil kontrolünden geçir."
    )

    @Argument(help: "Kontrol edilecek makale dosyası", transform: { URL(fileURLWithPath: $0) })
    var article: URL

    @Flag(name: .long, help: "RAG bağlamını kullanma")
    var noRag = false

    func run() async throws {
        let client = await MainActor.run { Ollama.Client.default }

        guard await client.isReachable() else {
            Terminal.error("Ollama çalışmıyor. Başlat: brew services start ollama")
            throw ExitCode.failure
        }

        guard try await client.hasModel(Config.defaultModel) else {
            Terminal.error("Model bulunamadı: \(Config.defaultModel). Çalıştır: ollama pull \(Config.defaultModel)")
            throw ExitCode.failure
        }

        let store = VectorStore(client: client)
        try await store.load()

        Terminal.header("Kontrol: \(article.lastPathComponent)")
        try await Checker.checkWording(
            articlePath: article,
            useRAG: !noRag,
            client: client,
            store: store
        )
    }
}
