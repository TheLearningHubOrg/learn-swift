/// Summary numbers for a list of to-dos.
public struct TodoStats: Sendable, Equatable, Codable {
    public let total: Int
    public let done: Int
    public let byPriority: [String: Int]

    public init(_ todos: [Todo]) {
        total = todos.count
        done = todos.count(where: \.isDone)
        byPriority = Dictionary(grouping: todos, by: \.priority.rawValue).mapValues(\.count)
    }

    /// Whole-number percentage; 0 for an empty list instead of dividing by zero.
    public var completionPercent: Int {
        total == 0 ? 0 : done * 100 / total
    }
}
