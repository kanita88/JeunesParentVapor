import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: TodoController())
    try app.register(collection: ParentController())
    try app.register(collection: EnfantController())
    try app.register(collection: TaskController())
    try app.register(collection: GrossesseController())
    try app.register(collection: ArticleController())
}
