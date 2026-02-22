import ArgumentParser
import Ollama

@main
struct Muharrir: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "muharrir",
        abstract: "Türkçe teknik makale yazım denetleyicisi — yerel LLM + RAG ile.",
        version: "1.0.0",
        subcommands: [
            Scrape.self,
            Add.self,
            Check.self,
            Review.self,
            Improve.self,
            Stats.self,
            Search.self,
        ]
    )
}
