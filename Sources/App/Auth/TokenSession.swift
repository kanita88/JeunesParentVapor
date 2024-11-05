//
//  TokenSession.swift
//  JeunesParentVapor
//
//  Created by Apprenant 142 on 04/11/2024.
//

import Foundation
import JWTKit
import Vapor

struct TokenSession: Content, Authenticatable, JWTPayload {
    var expirationTime: TimeInterval = 60 * 15
    
    // Token Data
    var expiration: ExpirationClaim
    var parentld: UUID
    
    init(with parent: ParentUser) throws {
        self.parentld = try parent.requireID()
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
        
        
    }
    
    func verify(using algorithm: some JWTAlgorithm) throws {
        try expiration.verifyNotExpired()
    }
    
}
