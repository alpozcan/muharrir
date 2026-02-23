import OSLog

extension Logger {
    private static let subsystem = "dev.yazman.cli"

    static let general = Logger(subsystem: subsystem, category: "general")
    static let ollama = Logger(subsystem: subsystem, category: "ollama")
    static let vectorStore = Logger(subsystem: subsystem, category: "vectorStore")
    static let scraper = Logger(subsystem: subsystem, category: "scraper")
    static let checker = Logger(subsystem: subsystem, category: "checker")
}
