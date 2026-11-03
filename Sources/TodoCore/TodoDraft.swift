/// Every way a draft can be rejected. Because `create` uses typed throws,
/// callers know at compile time that this is the only error they can get.
public enum ValidationError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyTitle
    case titleTooLong(limit: Int)
    case tooManyTags(limit: Int)
    case invalidTag(String)

    public var description: String {
        switch self {
        case .emptyTitle:
            "title must not be empty"
        case .titleTooLong(let limit):
            "title must be at most \(limit) characters"
        case .tooManyTags(let limit):
            "at most \(limit) tags are allowed"
        case .invalidTag(let tag):
            "tag '\(tag)' may only contain letters, digits and '-'"
        }
    }
}

/// The input a client sends to create a to-do. Optional fields fall back to defaults.
public struct TodoDraft: Sendable, Codable, Equatable {
    public var title: String
    public var priority: Priority?
    public var tags: [String]?

    public static let maxTitleLength = 120
    public static let maxTags = 5

    public init(title: String, priority: Priority? = nil, tags: [String]? = nil) {
        self.title = title
        self.priority = priority
        self.tags = tags
    }

    /// Checks the draft and turns it into a `Todo` with the given id.
    ///
    /// `throws(ValidationError)` is a typed throw (Swift 6.0, SE-0413): the
    /// compiler rejects any `throw` of another error type inside this body.
    public func validated(id: Int) throws(ValidationError) -> Todo {
        let title = self.title.trimmed
        guard !title.isEmpty else { throw .emptyTitle }
        guard title.count <= Self.maxTitleLength else {
            throw .titleTooLong(limit: Self.maxTitleLength)
        }

        let tags = (self.tags ?? []).map { $0.trimmed.lowercased() }.filter { !$0.isEmpty }
        guard tags.count <= Self.maxTags else { throw .tooManyTags(limit: Self.maxTags) }
        if let bad = tags.first(where: { !$0.isValidTag }) {
            throw .invalidTag(bad)
        }

        return Todo(id: id, title: title, priority: priority ?? .normal, tags: Set(tags))
    }
}

extension StringProtocol {
    /// The string without leading or trailing whitespace, without Foundation.
    var trimmed: String {
        guard let start = firstIndex(where: { !$0.isWhitespace }),
            let end = lastIndex(where: { !$0.isWhitespace })
        else { return "" }
        return String(self[start...end])
    }

    var isValidTag: Bool {
        allSatisfy { $0.isLetter || $0.isNumber || $0 == "-" }
    }
}
