import Foundation
import Ollama

enum Config {
    static let dataDir: URL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".muharrir")
    static let corpusDir: URL = dataDir.appendingPathComponent("corpus")
    static let embeddingsFile: URL = dataDir.appendingPathComponent("embeddings.json")

    static let defaultModel: Model.ID = "gemma3:4b"
    static let embeddingModel: Model.ID = "nomic-embed-text"

    static let seedURLs = [
        "https://medium.com/@andynvt/swift-programlama-dili",
        "https://medium.com/türkiye/tagged/swift",
        "https://medium.com/türkiye/tagged/ios",
        "https://www.mobilhanem.com/swift-egitimleri/",
        "https://tr.wikipedia.org/wiki/Swift_(programlama_dili)",
        "https://tr.wikipedia.org/wiki/Nesne_yönelimli_programlama",
        "https://tr.wikipedia.org/wiki/Yazılım_mühendisliği",
    ]

    static func ensureDirectories() throws {
        let fm = FileManager.default
        try fm.createDirectory(at: dataDir, withIntermediateDirectories: true)
        try fm.createDirectory(at: corpusDir, withIntermediateDirectories: true)
    }
}
