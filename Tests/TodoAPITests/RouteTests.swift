import Foundation
import Hummingbird
import HummingbirdTesting
import Testing

@testable import TodoAPI
@testable import TodoCore

@Suite("HTTP routes")
struct RouteTests {
    func makeApp() -> some ApplicationProtocol {
        buildApplication(
            config: ServerConfig(environment: [:]),
            repository: InMemoryTodoRepository()
        )
    }

    func decode<T: Decodable>(_ type: T.Type, from buffer: ByteBuffer) throws -> T {
        try JSONDecoder().decode(type, from: Data(String(buffer: buffer).utf8))
    }

    @Test func health() async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: "/health", method: .get) { response in
                #expect(response.status == .ok)
                #expect(String(buffer: response.body) == "ok")
            }
        }
    }

    @Test func createListCompleteDelete() async throws {
        try await makeApp().test(.router) { client in
            let body = ByteBuffer(string: #"{"title":"Learn actors","priority":"high","tags":["swift"]}"#)
            try await client.execute(uri: "/todos", method: .post, body: body) { response in
                #expect(response.status == .created)
                let created = try decode(TodoBody.self, from: response.body)
                #expect(created.todo.id == 1)
                #expect(created.todo.tags == ["swift"])
            }

            try await client.execute(uri: "/todos?priority=high", method: .get) { response in
                let list = try decode(TodoListBody.self, from: response.body)
                #expect(list.items.map(\.title) == ["Learn actors"])
                #expect(list.stats.total == 1)
            }

            try await client.execute(uri: "/todos/1/done", method: .patch) { response in
                let updated = try decode(TodoBody.self, from: response.body)
                #expect(updated.todo.isDone)
            }

            try await client.execute(uri: "/todos/1", method: .delete) { response in
                #expect(response.status == .noContent)
            }

            try await client.execute(uri: "/todos/1", method: .get) { response in
                #expect(response.status == .notFound)
            }
        }
    }

    @Test func invalidDraftIsBadRequest() async throws {
        try await makeApp().test(.router) { client in
            let body = ByteBuffer(string: #"{"title":"   "}"#)
            try await client.execute(uri: "/todos", method: .post, body: body) { response in
                #expect(response.status == .badRequest)
                #expect(String(buffer: response.body).contains("title must not be empty"))
            }
        }
    }

    @Test func nonNumericIDIsBadRequest() async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: "/todos/abc", method: .get) { response in
                #expect(response.status == .badRequest)
            }
        }
    }

    @Test(arguments: [
        ([:], 8080),
        (["PORT": "9000"], 9000),
        (["PORT": "not-a-port"], 8080),
        (["PORT": "70000"], 8080),
    ])
    func portFromEnvironment(environment: [String: String], expected: Int) {
        #expect(ServerConfig(environment: environment).port == expected)
    }
}
