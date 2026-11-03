import Testing

@testable import TodoCore

@Suite("Draft validation")
struct TodoDraftTests {
    @Test("A valid draft becomes a Todo with trimmed title and lowercased tags")
    func validDraft() throws {
        let draft = TodoDraft(title: "  Write README  ", priority: .high, tags: ["Docs", " swift "])
        let todo = try draft.validated(id: 7)
        #expect(todo.id == 7)
        #expect(todo.title == "Write README")
        #expect(todo.priority == .high)
        #expect(todo.tags == ["docs", "swift"])
        #expect(todo.isDone == false)
    }

    @Test("Missing priority falls back to .normal")
    func defaultPriority() throws {
        #expect(try TodoDraft(title: "x").validated(id: 1).priority == .normal)
    }

    @Test(
        "Invalid drafts throw the matching ValidationError",
        arguments: [
            (TodoDraft(title: "   "), ValidationError.emptyTitle),
            (TodoDraft(title: String(repeating: "a", count: 121)), .titleTooLong(limit: 120)),
            (TodoDraft(title: "t", tags: ["a", "b", "c", "d", "e", "f"]), .tooManyTags(limit: 5)),
            (TodoDraft(title: "t", tags: ["ok", "not ok!"]), .invalidTag("not ok!")),
        ]
    )
    func invalidDrafts(draft: TodoDraft, expected: ValidationError) {
        #expect(throws: expected) {
            try draft.validated(id: 1)
        }
    }

    @Test func trimmedHandlesAllWhitespace() {
        #expect("  \t\n ".trimmed == "")
        #expect(" a b ".trimmed == "a b")
    }
}
