import Foundation
import TodoAPI
import TodoCore

@main
struct App {
    static func main() async throws {
        let config = ServerConfig(environment: ProcessInfo.processInfo.environment)
        let app = buildApplication(config: config, repository: InMemoryTodoRepository())
        // runService() starts the server and handles SIGINT/SIGTERM for a clean shutdown.
        try await app.runService()
    }
}
