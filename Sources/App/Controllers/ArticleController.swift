//
//  ArticleController.swift
//  
//
//  Created by Apprenant 172 on 18/10/2024.


    import Fluent
    import Vapor
    import FluentSQL

    struct ArticleController: RouteCollection {
        func boot(routes: any Vapor.RoutesBuilder) throws {
            let articles = routes.grouped ("article")
            articles.get(use: index_article)
            articles.post(use: create_article)
            
            articles.group("byemail") { article in
                article.get(":email" ,use: getArticleByEmail)
            }
        }

    @Sendable
    func index_article(req: Request) async throws -> [Article] {
        return try await Article.query(on: req.db).all()
    }

    @Sendable
    func create_article(req: Request) async throws -> Article {
        let article = try req.content.decode(Article.self)
        try await article.save(on: req.db)
        return article
    }

    @Sendable
    func getArticleByID(req: Request) async throws -> Article {
        guard let article = try await
                Article.find(req.parameters.get("articleID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return article
    }

    @Sendable
    func getArticleByEmail(req: Request) async throws -> Article {
        guard let email = req.parameters.get("email") else {
            throw Abort(.badRequest, reason: "Le paramètre 'email' est invalide ou manquant.")
        }
        
        if let sql = req.db as? SQLDatabase {
            let article = try await sql.raw("SELECT * FROM article WHERE email = \(bind: email)")
                .all(decodingFluent: Article.self)
            
            guard let article = article.first else {
                throw Abort(.notFound, reason: "Utilisateur non trouvé.")
            }
            return article
        }
        throw Abort(.internalServerError, reason: "La base de données n'est pas SQL.")
    }

    @Sendable
    func update(req: Request) async throws -> Article {
        guard let articleIDString = req.parameters.get ("articleID"),
              let articleID = UUID(uuidString: articleIDString) else {
            throw Abort(.badRequest, reason: "ID d'utilisateur invalide.")
        }
        let updatedArticle = try req.content.decode(Article.self)
        
        guard let article = try await Article.find(articleID, on:req.db) else {
            throw Abort(.notFound, reason: "Parent non trouvé.")
        }
        // Mise à jour des propriétés
        article.title = updatedArticle.title
        article.description = updatedArticle.description
        article.publicationDate = updatedArticle.publicationDate
        article.read_time = updatedArticle.read_time
        article.imageURL  = updatedArticle.imageURL ?? article.imageURL
        article.category = updatedArticle.category
        article.content = updatedArticle.content
        
        
        try await article.save(on: req.db)
        return article
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let article = try await
                Article.find(req.parameters.get("articleID"), on: req.db) else {
            throw Abort (.notFound)
        }
        
        try await article.delete(on: req.db)
        return.noContent
    }
    
}
