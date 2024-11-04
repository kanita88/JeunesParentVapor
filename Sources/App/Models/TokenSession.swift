//
//  TokenSession.swift
//  JeunesParentVapor
//
//  Created by Apprenant 172 on 04/11/2024.
//

import JWTKit
import Vapor

struct TokenSession: Content, Authenticatable, JWTPayload {
    
    // Temps d'expiration en secondes (1 minutes)
    var expirationTime: TimeInterval = 60*1

    // Données du token
    var expiration: ExpirationClaim
    var parentId: UUID

    // Initialisation avec un utilisateur
    init(with parent: Parent) throws {
        self.parentId = try parent.requireID()
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
    }

    // Vérification du token pour s'assurer qu'il n'est pas expiré
    func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
        try expiration.verifyNotExpired() // Vérification de l'expiration
    }
}
