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
import JWTDecode

struct ParentController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let parents = routes.grouped ("parents")
        
        let basicAuthMiddleware = ParentUser.authenticator()
        let guardAuthMiddleware = ParentUser.guardMiddleware()
        let authGroup = parents.grouped(basicAuthMiddleware, guardAuthMiddleware)
        
        let tokenAuthMiddleware = TokenSession.authenticator()
        let guardTokenMiddleware = TokenSession.guardMiddleware()
        let tokenGroup = parents.grouped(tokenAuthMiddleware, guardTokenMiddleware)
        
        //parents.get(use: index)
        //parents.post(use: create)
        
        authGroup.post("login", use : login )
        parents.post(use: create) //créer mdp haché et envoi token
        
        tokenGroup.get(use: index) // il faut le token pour se connecter à index
        tokenGroup.get("profile", use: profile)
        
        //authGroup.get(use: index)
        
        
        parents.group("byemail") { parent in
            parent.get(":email" ,use: getParentByEmail)
        }
        
        parents.group(":parentID") { parent in
            parent.get(use: getParentByID)
            parent.delete(use: delete)
            parent.put(use: update)
        }
        
        //            parents.post("login") { req -> EventLoopFuture<Response> in
        //                // Décoder directement le modèle Parent depuis le corps de la requête
        //                let parent = try req.content.decode(Parent.self)
        //
        //                // Appeler la fonction d'authentification
        //                return authenticateParent(req: req, parent: parent)
        //            }
    }
    
    @Sendable
    func index(req: Request) async throws -> [ParentDTO] {
        let parents = try await ParentUser.query(on: req.db).all()
        return parents.map { $0.toDTO() }
    }
    
    @Sendable
    func create(req: Request) async throws -> ParentDTO {
        let parent = try req.content.decode(ParentUser.self)
        
        guard parent.password.count >= 8 else {
            throw Abort(.badRequest, reason: " Password must be at least 8 characters")
        }
        parent.password = try Bcrypt.hash(parent.password)
        
        try await parent.save(on: req.db)
        return parent.toDTO()
    }
    
    
    @Sendable
    func getParentByID(req: Request) async throws -> ParentUser {
        guard let parent = try await
                ParentUser.find(req.parameters.get("parentID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return parent
    }
    
    @Sendable
    func getParentByEmail(req: Request) async throws -> ParentUser {
        guard let email = req.parameters.get("email") else {
            throw Abort(.badRequest, reason: "Le paramètre 'email' est invalide ou manquant.")
        }
        
        if let sql = req.db as? SQLDatabase {
            let parent = try await sql.raw("SELECT * FROM parent WHERE email = \(bind: email)")
                .all(decodingFluent: ParentUser.self)
            
            guard let parent = parent.first else {
                throw Abort(.notFound, reason: "Utilisateur non trouvé.")
            }
            return parent
        }
        throw Abort(.internalServerError, reason: "La base de données n'est pas SQL.")
    }
    
    @Sendable
    func update(req: Request) async throws -> ParentUser {
        guard let parentIDString = req.parameters.get ("parentID"),
              let parentID = UUID(uuidString: parentIDString) else {
            throw Abort(.badRequest, reason: "ID d'utilisateur invalide.")
        }
        let updatedParent = try req.content.decode(ParentUser.self)
        
        guard let parent = try await ParentUser.find(parentID, on:req.db) else {
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
                ParentUser.find(req.parameters.get("parentID"), on: req.db) else {
            throw Abort (.notFound)
        }
        
        try await parent.delete(on: req.db)
        return.noContent
    }
    
    @Sendable
    func login(req: Request) async throws -> [String: String] {
        // Authentifie l'utilisateur avec l'authentification de base
        let parent = try req.auth.require(ParentUser.self)
        // Crée le payload du token JWT
        let payload = try TokenSession(with: parent)
        // Génère le token JWT signé
        let token = try await req.jwt.sign(payload)
        // Récupère le prénom pour le message de bienvenue
        let firstName = parent.prenom ?? "Utilisateur"
        return ["token": token, "prenom": firstName]
    }
    
    @Sendable
    func profile(_ req: Request) async throws -> [String: String] {
        // Récupérer le token JWT de l'en-tête Authorization
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Token manquant dans l'en-tête Authorization.")
        }
        
        do {
            // Décoder le token JWT
            let jwt = try decode(jwt: token)
            
            // Extraire les informations du payload
            let parentId = jwt.claim(name: "parentId").string ?? "ID non disponible"
            let prenom = jwt.claim(name: "prenom").string ?? "Utilisateur"
            
            // Retourner les informations de profil sous forme de dictionnaire `[String: String]`
            return ["parentId": parentId, "prenom": prenom]
        } catch {
            print("Erreur lors du décodage du token JWT : \(error)")
            throw Abort(.unauthorized, reason: "Token JWT invalide.")
        }
    }
}
