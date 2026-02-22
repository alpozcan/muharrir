import Foundation
import Ollama

enum Checker {
    /// Extract non-code paragraphs from markdown text.
    static func extractParagraphs(from text: String) -> [String] {
        var paragraphs: [String] = []
        var inCodeBlock = false

        for line in text.split(separator: "\n", omittingEmptySubsequences: false) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("```") {
                inCodeBlock.toggle()
                continue
            }
            if inCodeBlock { continue }
            if trimmed.hasPrefix("#") { continue }
            if trimmed.hasPrefix("- [") { continue }
            if trimmed.hasPrefix("**Platform:") || trimmed.hasPrefix("**Etki:") { continue }
            if trimmed.hasPrefix("#Swift") { continue }
            if trimmed == "---" { continue }
            if trimmed.count > 30 {
                paragraphs.append(trimmed)
            }
        }

        return paragraphs
    }

    /// Check article wording paragraph by paragraph.
    static func checkWording(
        articlePath: URL,
        useRAG: Bool,
        client: Ollama.Client,
        store: VectorStore
    ) async throws {
        let text = try String(contentsOf: articlePath, encoding: .utf8)
        let mainText = text.components(separatedBy: "=========== FINAL SHARED TEXT").first ?? text
        let paragraphs = extractParagraphs(from: mainText)

        guard !paragraphs.isEmpty else {
            Terminal.error("Kontrol edilecek paragraf bulunamadı.")
            return
        }

        Terminal.info("\(paragraphs.count) paragraf kontrol edilecek\n")

        // Get RAG context
        var ragContext = ""
        if useRAG {
            let sample = paragraphs.prefix(3).joined(separator: " ")
            let matches = try await store.query(sample, nResults: 3)
            if !matches.isEmpty {
                ragContext = "\n\nReferans Türkçe teknik yazım örnekleri (bu tarz ve tonu referans al):\n"
                for m in matches {
                    ragContext += "\n---\nKaynak: \(m.title)\n\(String(m.text.prefix(500)))\n"
                }
            }
        }

        // Process in batches of 5
        let batchSize = 5
        for i in stride(from: 0, to: paragraphs.count, by: batchSize) {
            let batch = Array(paragraphs[i..<min(i + batchSize, paragraphs.count)])
            let batchText = batch.enumerated()
                .map { "[\(i + $0.offset + 1)] \($0.element)" }
                .joined(separator: "\n\n")

            let prompt = """
            Aşağıdaki Türkçe teknik makale paragraflarını incele ve dil/ifade önerilerinde bulun:

            \(batchText)
            \(ragContext)

            Her paragraf için önerini ver. Paragraf zaten iyiyse "OK" yaz.
            """

            Terminal.header("Paragraflar \(i + 1)-\(i + batch.count)")

            let stream = await client.generateStream(
                model: Config.defaultModel,
                prompt: prompt,
                options: ["temperature": 0.3, "top_p": 0.9, "num_predict": 2048],
                system: Prompts.wordingExpert
            )

            for try await chunk in stream {
                print(chunk.response, terminator: "")
            }
            print("\n")
        }
    }

    /// Holistic review of an entire article.
    static func reviewArticle(
        articlePath: URL,
        useRAG: Bool,
        client: Ollama.Client,
        store: VectorStore
    ) async throws {
        let text = try String(contentsOf: articlePath, encoding: .utf8)
        var mainText = text.components(separatedBy: "=========== FINAL SHARED TEXT").first ?? text

        if mainText.count > 8000 {
            mainText = String(mainText.prefix(8000)) + "\n\n[... makale kısaltıldı ...]"
        }

        var ragContext = ""
        if useRAG {
            let matches = try await store.query(String(mainText.prefix(1000)), nResults: 3)
            if !matches.isEmpty {
                ragContext = "\n\nReferans yazım örnekleri:\n"
                for m in matches {
                    ragContext += "\n---\n\(String(m.text.prefix(400)))\n"
                }
            }
        }

        let prompt = """
        Aşağıdaki Türkçe teknik makaleyi bütünsel olarak değerlendir:

        \(mainText)
        \(ragContext)
        """

        Terminal.header("Makale İncelemesi")

        let stream = await client.generateStream(
            model: Config.defaultModel,
            prompt: prompt,
            options: ["temperature": 0.3, "top_p": 0.9, "num_predict": 2048],
            system: Prompts.reviewer
        )

        for try await chunk in stream {
            print(chunk.response, terminator: "")
        }
        print()
    }

    /// Suggest specific wording improvements using RAG context.
    static func suggestImprovements(
        articlePath: URL,
        client: Ollama.Client,
        store: VectorStore
    ) async throws {
        let text = try String(contentsOf: articlePath, encoding: .utf8)
        let mainText = text.components(separatedBy: "=========== FINAL SHARED TEXT").first ?? text
        let paragraphs = extractParagraphs(from: mainText)

        for (i, para) in paragraphs.prefix(10).enumerated() {
            let matches = try await store.query(para, nResults: 2)
            guard !matches.isEmpty else { continue }

            let refTexts = matches.map { String($0.text.prefix(300)) }.joined(separator: "\n")

            let prompt = """
            Aşağıdaki paragrafı, verilen referans metinlerin Türkçe kullanım tarzına göre iyileştir.

            Paragraf:
            \(para)

            Referans metinler (bu tarz ve terminolojiyi referans al):
            \(refTexts)

            Yalnızca somut kelime/ifade değişikliği öner. Genel yorum yapma.
            """

            Terminal.dim("Paragraf \(i + 1)...")

            let response = try await client.generate(
                model: Config.defaultModel,
                prompt: prompt,
                options: ["temperature": 0.3, "top_p": 0.9, "num_predict": 1024],
                system: Prompts.wordingExpert
            )

            print("\n### Paragraf \(i + 1)")
            print(response.response)
            print()
        }
    }
}
