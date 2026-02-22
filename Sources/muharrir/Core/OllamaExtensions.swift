import Ollama

extension Ollama.Client {
    /// Check if the Ollama server is reachable.
    func isReachable() async -> Bool {
        do {
            _ = try await listModels()
            return true
        } catch {
            return false
        }
    }

    /// Check if a model is available locally (fuzzy match by base name).
    func hasModel(_ name: Model.ID) async throws -> Bool {
        let response = try await listModels()
        let nameStr = name.rawValue
        let baseName = nameStr.split(separator: ":").first.map(String.init) ?? nameStr
        return response.models.contains { model in
            let modelBase = model.name.split(separator: ":").first.map(String.init) ?? model.name
            return modelBase == baseName || model.name == nameStr
        }
    }
}
