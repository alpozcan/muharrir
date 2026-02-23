import Foundation
import Ollama
import OSLog

enum Lifecycle {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var registered = false

    /// Start Ollama if not already running, then register cleanup to stop it on exit.
    /// Safe to call multiple times — only the first call has effect.
    static func ensureOllama() {
        lock.lock()
        defer { lock.unlock() }
        guard !registered else { return }
        registered = true

        Logger.general.info("Ensuring Ollama is running")

        // Start Ollama via brew services (idempotent if already running)
        let start = Process()
        start.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        start.arguments = ["brew", "services", "start", "ollama"]
        start.standardOutput = FileHandle.nullDevice
        start.standardError = FileHandle.nullDevice

        do {
            try start.run()
            start.waitUntilExit()
            if start.terminationStatus == 0 {
                Logger.general.info("Ollama service started (or was already running)")
            } else {
                Logger.general.error("brew services start ollama exited with status \(start.terminationStatus)")
            }
        } catch {
            Logger.general.error("Failed to start Ollama: \(error.localizedDescription)")
        }

        atexit {
            Lifecycle.stopOllama()
        }

        signal(SIGINT) { _ in
            Lifecycle.stopOllama()
            _Exit(130)
        }

        signal(SIGTERM) { _ in
            Lifecycle.stopOllama()
            _Exit(143)
        }
    }

    /// Wait for Ollama HTTP server to be ready (up to ~15s).
    static func waitUntilReady(_ client: Ollama.Client) async -> Bool {
        for _ in 0..<30 {
            if await client.isReachable() { return true }
            try? await Task.sleep(for: .milliseconds(500))
        }
        return false
    }

    private static func stopOllama() {
        Logger.general.info("Stopping Ollama service")

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["brew", "services", "stop", "ollama"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                Logger.general.info("Ollama service stopped successfully")
            } else {
                Logger.general.error("brew services stop ollama exited with status \(process.terminationStatus)")
            }
        } catch {
            Logger.general.error("Failed to stop Ollama: \(error.localizedDescription)")
        }
    }
}
