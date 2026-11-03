/// Host and port, read from environment variables so the same binary runs
/// on a laptop, in Docker and in CI.
public struct ServerConfig: Sendable, Equatable {
    public var host: String
    public var port: Int

    public static let defaultPort = 8080

    public init(environment: [String: String]) {
        host = environment["HOST"] ?? "0.0.0.0"
        if let raw = environment["PORT"], let port = Int(raw), (1...65_535).contains(port) {
            self.port = port
        } else {
            self.port = Self.defaultPort
        }
    }
}
