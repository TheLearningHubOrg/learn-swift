import Testing

@testable import TodoCore

@Suite("Query, stats and value semantics")
struct TodoQueryTests {
    let todos = [
        Todo(id: 1, title: "low", priority: .low, tags: ["home"]),
        Todo(id: 2, title: "urgent", priority: .urgent, tags: ["work"]),
        Todo(id: 3, title: "normal done", priority: .normal, tags: ["work"], isDone: true),
        Todo(id: 4, title: "urgent too", priority: .urgent),
    ]

    @Test func defaultQuerySortsByPriorityThenID() {
        let ids = TodoQuery().apply(to: todos).map(\.id)
        #expect(ids == [2, 4, 3, 1])
    }

    @Test func filtersCombine() {
        let query = TodoQuery(includeDone: false, tag: "work")
        #expect(query.apply(to: todos).map(\.id) == [2])
    }

    @Test func rawQueryStringsAreParsedLeniently() {
        let query = TodoQuery(done: "false", tag: "WORK", priority: "bogus")
        #expect(query == TodoQuery(includeDone: false, tag: "work", minimumPriority: nil))
    }

    @Test func minimumPriority() {
        let query = TodoQuery(minimumPriority: .high)
        #expect(query.apply(to: todos).map(\.id) == [2, 4])
    }

    @Test func priorityOrderingFollowsRank() {
        #expect(Priority.allCases.sorted() == [.low, .normal, .high, .urgent])
    }

    @Test func stats() {
        let stats = TodoStats(todos)
        #expect(stats.total == 4)
        #expect(stats.done == 1)
        #expect(stats.completionPercent == 25)
        #expect(stats.byPriority == ["low": 1, "urgent": 2, "normal": 1])
        #expect(TodoStats([]).completionPercent == 0)
    }

    @Test func completedReturnsACopy() {
        let original = todos[0]
        let done = original.completed()
        #expect(done.isDone)
        #expect(!original.isDone, "structs are copied, the original must not change")
    }
}
