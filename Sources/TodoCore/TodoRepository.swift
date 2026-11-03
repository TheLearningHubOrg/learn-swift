/// Storage for to-dos. A protocol so the HTTP layer and the tests can use any
/// implementation: in memory today, a database later.
///
/// Refining `Sendable` lets a repository be captured by the `@Sendable`
/// closures that HTTP handlers are.
public protocol TodoRepository: Sendable {
    func create(_ draft: TodoDraft) async throws(ValidationError) -> Todo
    func all() async -> [Todo]
    func find(id: Int) async -> Todo?
    func markDone(id: Int) async -> Todo?
    func delete(id: Int) async -> Bool
}

/// An actor protects its mutable state: only one task runs inside it at a
/// time, so `items` and `nextID` can never be corrupted by concurrent requests.
public actor InMemoryTodoRepository: TodoRepository {
    private var items: [Int: Todo] = [:]
    private var nextID = 1

    public init() {}

    public func create(_ draft: TodoDraft) throws(ValidationError) -> Todo {
        let todo = try draft.validated(id: nextID)
        items[todo.id] = todo
        nextID += 1
        return todo
    }

    public func all() -> [Todo] {
        items.values.sorted(by: \.id)
    }

    public func find(id: Int) -> Todo? {
        items[id]
    }

    public func markDone(id: Int) -> Todo? {
        guard let todo = items[id] else { return nil }
        let done = todo.completed()
        items[id] = done
        return done
    }

    public func delete(id: Int) -> Bool {
        items.removeValue(forKey: id) != nil
    }
}
