/// Filters and orders a list of to-dos. Built from query-string values.
public struct TodoQuery: Sendable, Equatable {
    public var includeDone: Bool
    public var tag: String?
    public var minimumPriority: Priority?

    public init(includeDone: Bool = true, tag: String? = nil, minimumPriority: Priority? = nil) {
        self.includeDone = includeDone
        self.tag = tag
        self.minimumPriority = minimumPriority
    }

    /// Builds a query from raw strings. Unknown or malformed values are ignored.
    public init(done: String?, tag: String?, priority: String?) {
        self.init(
            includeDone: done.map { $0 != "false" } ?? true,
            tag: tag?.lowercased(),
            minimumPriority: priority.flatMap(Priority.init(rawValue:))
        )
    }

    public func matches(_ todo: Todo) -> Bool {
        if !includeDone && todo.isDone { return false }
        if let tag, !todo.tags.contains(tag) { return false }
        if let minimumPriority, todo.priority < minimumPriority { return false }
        return true
    }

    /// Most urgent first; ties keep creation order (lower id first).
    public func apply(to todos: some Sequence<Todo>) -> [Todo] {
        todos.filter(matches).sorted { lhs, rhs in
            lhs.priority != rhs.priority ? lhs.priority > rhs.priority : lhs.id < rhs.id
        }
    }
}

extension Sequence {
    /// Sorts by any `Comparable` property: `todos.sorted(by: \.id)`.
    public func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}
