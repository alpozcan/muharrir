import Ollama
import OSLog

extension Ollama.Client {
    /// Check if the Ollama server is reachable.
    func isReachable() async -> Bool {
        do {
            _ = try await listModels()
            Logger.ollama.info("Ollama server is reachable")
            return true
        } catch {
            Logger.ollama.error("Ollama server unreachable: \(error.localizedDescription)")
            return false
        }
    }

    /// Check if a model is available locally (fuzzy match by base name).
    func hasModel(_ name: Model.ID) async throws -> Bool {
        let response = try await listModels()
        let nameStr = name.rawValue
        let baseName = nameStr.split(separator: ":").first.map(String.init) ?? nameStr
        let found = response.models.contains { model in
            let modelBase = model.name.split(separator: ":").first.map(String.init) ?? model.name
            return modelBase == baseName || model.name == nameStr
        }
        if found {
            Logger.ollama.info("Model \(nameStr) is available")
        } else {
            Logger.ollama.notice("Model \(nameStr) not found locally")
        }
        return found
    }
}
