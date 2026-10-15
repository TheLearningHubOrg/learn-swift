import Foundation

public struct RoadmapStage: Sendable, Identifiable, Codable {
    public let id: Int
    public let title: String
    public let domainFocus: String
    public var completed: Bool

    public init(id: Int, title: String, domainFocus: String, completed: Bool = false) {
        self.id = id
        self.title = title
        self.domainFocus = domainFocus
        self.completed = completed
    }
}

public enum DomainResult<T: Sendable>: Sendable {
    case success(T)
    case failure(String)
}
