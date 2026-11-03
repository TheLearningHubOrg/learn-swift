/// A single to-do item.
///
/// `Todo` is a struct, so it has value semantics: assigning it to another
/// variable or passing it to a function makes an independent copy. That is why
/// it can be `Sendable` with no locks: no two places ever share one instance.
public struct Todo: Sendable, Hashable, Codable, Identifiable {
    public let id: Int
    public var title: String
    public var priority: Priority
    public var tags: Set<String>
    public var isDone: Bool

    public init(
        id: Int,
        title: String,
        priority: Priority = .normal,
        tags: Set<String> = [],
        isDone: Bool = false
    ) {
        self.id = id
        self.title = title
        self.priority = priority
        self.tags = tags
        self.isDone = isDone
    }

    /// Returns a copy marked as done. The original is untouched.
    public func completed() -> Todo {
        var copy = self
        copy.isDone = true
        return copy
    }
}
