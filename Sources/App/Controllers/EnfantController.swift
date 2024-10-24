//
//  EnfantController.swift
//
//
//  Created by Apprenant 172 on 22/10/2024.
//

import Fluent
import Vapor
import FluentSQL

struct EnfantController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let enfants = routes.grouped ("enfant")
        enfants.get(use: indexChild)
        enfants.post(use: createChild)
        
        enfants.group(":enfantID") { enfant in
            enfant.get(use: getChildByID)
            enfant.delete(use: deleteChild)
            enfant.put(use: updateChild)
        }
        enfants.post("login") { req -> EventLoopFuture<Response> in
            // Décoder directement le modèle Parent depuis le corps de la requête
            let parent = try req.content.decode(Parent.self)
            
            // Appeler la fonction d'authentification
            return authenticateParent(req: req, parent: parent)
        }
    }
}

@Sendable
func indexChild(req: Request) async throws -> [Enfant] {
    return try await Enfant.query(on: req.db).all()
}

@Sendable
func createChild(req: Request) async throws -> Enfant {
    let enfant = try req.content.decode(Enfant.self)
    try await enfant.save(on: req.db)
    return enfant
}

@Sendable
func getChildByID(req: Request) async throws -> Enfant {
    guard let enfant = try await
            Enfant.find(req.parameters.get("enfantID"), on: req.db) else {
        throw Abort(.notFound)
    }
    return enfant
}


@Sendable
func updateChild(req: Request) async throws -> Enfant {
    guard let enfantIDString = req.parameters.get ("enfantID"),
          let enfantID = UUID(uuidString: enfantIDString) else {
        throw Abort(.badRequest, reason: "ID d'utilisateur invalide.")
    }
    let updatedEnfant = try req.content.decode(Enfant.self)
    
    guard let enfant = try await Enfant.find(enfantID, on:req.db) else {
        throw Abort(.notFound, reason: "Enfant non trouvé.")
    }
    // Mise à jour des propriétés
    enfant.nom = updatedEnfant.nom
    enfant.birthDate = updatedEnfant.birthDate
    enfant.terme = updatedEnfant.terme
    enfant.alimentation = updatedEnfant.alimentation
    enfant.qualite_sommeil = updatedEnfant.qualite_sommeil
    enfant.ville = updatedEnfant.ville
    enfant.genre = updatedEnfant.genre
    enfant.ville = updatedEnfant.ville
    enfant.poids = updatedEnfant.poids
    enfant.taille = updatedEnfant.taille
    
    
    try await enfant.save(on: req.db)
    return enfant
}

@Sendable
func deleteChild(req: Request) async throws -> HTTPStatus {
    guard let enfant = try await
            Enfant.find(req.parameters.get("enfantID"), on: req.db) else {
        throw Abort (.notFound)
    }
    
    try await enfant.delete(on: req.db)
    return.noContent
}
