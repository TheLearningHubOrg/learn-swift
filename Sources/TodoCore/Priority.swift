/// How urgent a to-do is.
///
/// A raw-value enum: each case has a `String` raw value ("low", "normal", ...)
/// that `Codable` uses for JSON, and `CaseIterable` gives us `Priority.allCases`.
public enum Priority: String, Sendable, Codable, CaseIterable, Comparable {
    case low
    case normal
    case high
    case urgent

    /// Numeric weight used for ordering. The `switch` must be exhaustive,
    /// so adding a case without a rank is a compile error, not a runtime bug.
    var rank: Int {
        switch self {
        case .low: 0
        case .normal: 1
        case .high: 2
        case .urgent: 3
        }
    }

    public static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rank < rhs.rank
    }
}
