import Testing

@testable import TodoCore

@Suite("In-memory repository")
struct RepositoryTests {
    @Test func createAssignsIncreasingIDs() async throws {
        let repo = InMemoryTodoRepository()
        let first = try await repo.create(TodoDraft(title: "one"))
        let second = try await repo.create(TodoDraft(title: "two"))
        #expect(first.id == 1)
        #expect(second.id == 2)
        #expect(await repo.all().map(\.title) == ["one", "two"])
    }

    @Test func rejectedDraftDoesNotUseAnID() async throws {
        let repo = InMemoryTodoRepository()
        await #expect(throws: ValidationError.emptyTitle) {
            try await repo.create(TodoDraft(title: ""))
        }
        #expect(try await repo.create(TodoDraft(title: "ok")).id == 1)
    }

    @Test func markDoneAndDelete() async throws {
        let repo = InMemoryTodoRepository()
        let todo = try await repo.create(TodoDraft(title: "ship"))
        #expect(await repo.markDone(id: todo.id)?.isDone == true)
        #expect(await repo.find(id: todo.id)?.isDone == true)
        #expect(await repo.delete(id: todo.id))
        #expect(await repo.delete(id: todo.id) == false)
        #expect(await repo.markDone(id: 99) == nil)
    }

    @Test("Concurrent creates never reuse an id")
    func concurrentCreates() async throws {
        let repo = InMemoryTodoRepository()
        try await withThrowingTaskGroup(of: Todo.self) { group in
            for n in 1...100 {
                group.addTask { try await repo.create(TodoDraft(title: "task \(n)")) }
            }
            var ids = Set<Int>()
            for try await todo in group { ids.insert(todo.id) }
            #expect(ids == Set(1...100))
        }
    }
}
