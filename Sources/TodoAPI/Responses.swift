import Hummingbird
import TodoCore

/// Response bodies. They wrap domain types instead of making `Todo` itself
/// conform to Hummingbird's protocol, which keeps TodoCore free of web code.
public struct TodoBody: ResponseCodable {
    public let todo: Todo
}

public struct TodoListBody: ResponseCodable {
    public let items: [Todo]
    public let stats: TodoStats
}
