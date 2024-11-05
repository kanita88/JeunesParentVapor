import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }
    
    app.get("hello") { req async -> String in
        return "Hello, world!"
    }

    app.post("hello") { req async -> String in
        return "Hello, POST!"
    }
    
    app.put("hello") { req async -> String in
        return "Hello, PUT!"
    }

    app.delete("hello") { req async -> String in
        return "Hello, DELETE!"
    }

    try app.register(collection: TodoController())
    try app.register(collection: ParentController())
    try app.register(collection: EnfantController())
    try app.register(collection: TaskController())
    try app.register(collection: GrossesseController())
    try app.register(collection: ArticleController())
}
