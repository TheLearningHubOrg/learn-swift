import Hummingbird
import TodoCore

/// Registers every route on a new router.
///
/// The repository is passed in (dependency injection), so tests can hand in a
/// fresh store and production can hand in a database-backed one.
public func buildRouter(repository: some TodoRepository) -> Router<BasicRequestContext> {
    let router = Router()

    router.get("/health") { _, _ in
        "ok"
    }

    router.get("/todos") { request, _ -> TodoListBody in
        let params = request.uri.queryParameters
        let query = TodoQuery(
            done: params.get("done"),
            tag: params.get("tag"),
            priority: params.get("priority")
        )
        let all = await repository.all()
        return TodoListBody(items: query.apply(to: all), stats: TodoStats(all))
    }

    router.post("/todos") { request, context -> EditedResponse<TodoBody> in
        let draft = try await request.decode(as: TodoDraft.self, context: context)
        // `do throws(ValidationError)` states the thrown type, so in the catch
        // block `error` is a ValidationError, not `any Error`.
        do throws(ValidationError) {
            let todo = try await repository.create(draft)
            return EditedResponse(status: .created, response: TodoBody(todo: todo))
        } catch {
            throw HTTPError(.badRequest, message: error.description)
        }
    }

    router.get("/todos/:id") { _, context -> TodoBody in
        let id = try context.parameters.require("id", as: Int.self)
        guard let todo = await repository.find(id: id) else {
            throw HTTPError(.notFound, message: "no todo with id \(id)")
        }
        return TodoBody(todo: todo)
    }

    router.patch("/todos/:id/done") { _, context -> TodoBody in
        let id = try context.parameters.require("id", as: Int.self)
        guard let todo = await repository.markDone(id: id) else {
            throw HTTPError(.notFound, message: "no todo with id \(id)")
        }
        return TodoBody(todo: todo)
    }

    router.delete("/todos/:id") { _, context -> Response in
        let id = try context.parameters.require("id", as: Int.self)
        guard await repository.delete(id: id) else {
            throw HTTPError(.notFound, message: "no todo with id \(id)")
        }
        return Response(status: .noContent)
    }

    return router
}

/// Builds the application without starting it, so tests can drive it in memory.
public func buildApplication(
    config: ServerConfig,
    repository: some TodoRepository
) -> some ApplicationProtocol {
    Application(
        router: buildRouter(repository: repository),
        configuration: .init(
            address: .hostname(config.host, port: config.port),
            serverName: "todo-server"
        )
    )
}
