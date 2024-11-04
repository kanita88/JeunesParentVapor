//
//  File.swift
//
//
//  Created by Apprenant 172 on 18/10/2024.
//

import Fluent
import Vapor
import FluentSQL
import JWT

    struct ParentController: RouteCollection {
        func boot(routes: any Vapor.RoutesBuilder) throws {
            let parents = routes.grouped ("parent")
            parents.get(use: index)
            parents.post(use: create)
            
            parents.group("byemail") { parent in
                parent.get(":email" ,use: getParentByEmail)
            }
            
            parents.group(":parentID") { parent in
                parent.get(use: getParentByID)
                parent.delete(use: delete)
                parent.put(use: update)
            }
            parents.post("login") { req -> EventLoopFuture<Response> in
                // Décoder directement le modèle Parent depuis le corps de la requête
                let parent = try req.content.decode(Parent.self)
                
                // Appeler la fonction d'authentification
                return authenticateParent(req: req, parent: parent)
            }
        }
    }

    @Sendable
func index(req: Request) async throws -> [ParentDTO] {
    let parents = try await Parent.query(on: req.db).all()
    return parents.map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> ParentDTO {
        let parent = try req.content.decode(Parent.self)
        
        guard parent.password!.count >= 8 else {
            throw Abort(.badRequest, reason: " Password must be at least 8 characters")
        }
        parent.password = try Bcrypt.hash(parent.password!)
        
        try await parent.save(on: req.db)
        return parent.toDTO()
    }

    @Sendable
    func getParentByID(req: Request) async throws -> Parent {
        guard let parent = try await
                Parent.find(req.parameters.get("parentID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return parent
    }

    @Sendable
    func getParentByEmail(req: Request) async throws -> Parent {
        guard let email = req.parameters.get("email") else {
            throw Abort(.badRequest, reason: "Le paramètre 'email' est invalide ou manquant.")
        }
        
        if let sql = req.db as? SQLDatabase {
            let parent = try await sql.raw("SELECT * FROM parent WHERE email = \(bind: email)")
                .all(decodingFluent: Parent.self)
            
            guard let parent = parent.first else {
                throw Abort(.notFound, reason: "Utilisateur non trouvé.")
            }
            return parent
        }
        throw Abort(.internalServerError, reason: "La base de données n'est pas SQL.")
    }

    @Sendable
    func update(req: Request) async throws -> Parent {
        guard let parentIDString = req.parameters.get ("parentID"),
              let parentID = UUID(uuidString: parentIDString) else {
            throw Abort(.badRequest, reason: "ID d'utilisateur invalide.")
        }
        let updatedParent = try req.content.decode(Parent.self)
        
        guard let parent = try await Parent.find(parentID, on:req.db) else {
            throw Abort(.notFound, reason: "Parent non trouvé.")
        }
        // Mise à jour des propriétés
        parent.nom = updatedParent.nom
        parent.prenom = updatedParent.prenom
        parent.email = updatedParent.email
        parent.date_de_naissance = updatedParent.date_de_naissance
        parent.premiere_experience = updatedParent.premiere_experience
        
        try await parent.save(on: req.db)
        return parent
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let parent = try await
                Parent.find(req.parameters.get("parentID"), on: req.db) else {
            throw Abort (.notFound)
        }
        
        try await parent.delete(on: req.db)
        return.noContent
    }

    @Sendable
    func authenticateParent(req: Request, parent: Parent) -> EventLoopFuture<Response> {
        // Chercher le parent dans la base de données
        return Parent.query(on: req.db)
            .filter(\.$email == parent.email)
            .first()
            .flatMap { storedParent in
                // Vérifier si le parent existe
                guard let storedParent = storedParent else {
                    let response = Response(status: .unauthorized, body: .init(string: "Parent non trouvé"))
                    response.headers.add(name: .contentType, value: "text/plain; charset=utf-8")
                    return req.eventLoop.future(response)
                }
                
                // Comparer le mot de passe en texte clair (non recommandé)
                if storedParent.password == parent.password {
                    // Authentification réussie, renvoyer une réponse simple
                    let response = Response(status: .ok, body: .init(string: "Authentification réussie pour (storedParent.email)"))
                    response.headers.add(name: .contentType, value: "text/plain; charset=utf-8")
                    return req.eventLoop.future(response)
                } else {
                    let response = Response(status: .unauthorized, body: .init(string: "Mot de passe incorrect"))
                    response.headers.add(name: .contentType, value: "text/plain; charset=utf-8")
                    return req.eventLoop.future(response)
                }
            }
    }



