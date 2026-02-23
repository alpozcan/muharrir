import Foundation
import OSLog
import SwiftSoup

enum Scraper {
    /// Fetch a URL and extract clean text content.
    static func fetchArticle(url: String) async throws -> Article? {
        guard let requestURL = URL(string: url) else { return nil }

        Logger.scraper.info("Fetching \(url)")

        var request = URLRequest(url: requestURL)
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Yazman/1.0",
            forHTTPHeaderField: "User-Agent"
        )
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode),
              let html = String(data: data, encoding: .utf8) else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            Logger.scraper.error("Fetch failed for \(url): HTTP \(status)")
            return nil
        }

        Logger.scraper.debug("HTTP \(httpResponse.statusCode) for \(url)")

        let doc = try SwiftSoup.parse(html)

        // Extract title
        let title = try doc.title()

        // Remove scripts, styles, nav, footer
        try doc.select("script, style, nav, footer, header, aside, .sidebar, .comments").remove()

        // Try to find main content
        let contentSelectors = ["article", "main", ".post-content", ".article-body", ".entry-content", "[role=main]"]
        var contentElement: Element?
        for selector in contentSelectors {
            if let el = try doc.select(selector).first() {
                contentElement = el
                break
            }
        }

        let textSource = contentElement ?? doc.body() ?? doc

        // Extract text, preserving paragraph structure
        let paragraphs = try textSource.select("p, h1, h2, h3, h4, h5, h6, li")
        let text = try paragraphs.array().map { try $0.text() }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")

        guard text.count >= 200 else {
            Logger.scraper.debug("Skipped \(url): text too short (\(text.count) chars)")
            return nil
        }

        Logger.scraper.info("Fetched \(url): \(text.count) chars")
        return Article(
            url: url,
            title: title,
            author: "",
            text: text,
            language: "tr"
        )
    }

    /// Discover article links from a listing page.
    static func discoverLinks(from url: String) async -> [String] {
        guard let requestURL = URL(string: url) else { return [] }

        var request = URLRequest(url: requestURL)
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Yazman/1.0",
            forHTTPHeaderField: "User-Agent"
        )

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let html = String(data: data, encoding: .utf8),
              let doc = try? SwiftSoup.parse(html) else {
            return []
        }

        let keywords = ["swift", "ios", "programlama", "gelistirme", "yazilim", "mobil", "uygulama"]

        return (try? doc.select("a[href]").array().compactMap { link -> String? in
            guard let href = try? link.attr("href"),
                  href.hasPrefix("http"),
                  keywords.contains(where: { href.lowercased().contains($0) }) else {
                return nil
            }
            return href
        }) ?? []
    }

    /// Add local markdown/text files as articles.
    static func loadLocalFile(at path: URL) throws -> Article {
        let text = try String(contentsOf: path, encoding: .utf8)
        return Article(
            url: "file://\(path.path)",
            title: path.deletingPathExtension().lastPathComponent,
            author: "local",
            text: text,
            language: "tr"
        )
    }

    /// Cache an article to disk as JSON.
    static func cacheArticle(_ article: Article) throws {
        try Config.ensureDirectories()
        let hash = Data(article.url.utf8)
            .map { String(format: "%02x", $0) }.joined().prefix(16)
        let cachePath = Config.corpusDir.appendingPathComponent("\(hash).json")
        let data = try JSONEncoder().encode(article)
        try data.write(to: cachePath)
        Logger.scraper.debug("Cached article to \(cachePath.lastPathComponent)")
    }

    /// Load all cached articles from disk.
    static func loadCachedArticles() throws -> [Article] {
        let fm = FileManager.default
        guard fm.fileExists(atPath: Config.corpusDir.path) else { return [] }

        let files = try fm.contentsOfDirectory(at: Config.corpusDir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }

        return files.compactMap { file in
            guard let data = try? Data(contentsOf: file),
                  let article = try? JSONDecoder().decode(Article.self, from: data) else {
                return nil
            }
            return article
        }
    }
}
