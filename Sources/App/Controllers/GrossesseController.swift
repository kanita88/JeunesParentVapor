//
//  GrossesseController.swift
//  JeunesParentVapor
//
//  Created by Apprenant 172 on 23/10/2024.
//

import Fluent
import Vapor
import FluentSQL

struct GrossesseController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let grossesses = routes.grouped ("grossesse")
        grossesses.get(use: indexGrossesse)
        grossesses.post(use: createGrossesse)
        
        grossesses.group(":grossesseID") { grossesse in
            grossesse.get(use: getGrossesseByID)
            grossesse.delete(use: delete)
            //grossesse.put(use: update)
        }
    }
    
    @Sendable
    func indexGrossesse(req: Request) async throws -> [Grossesse] {
        return try await Grossesse.query(on: req.db).all()
    }
    
    @Sendable
    func createGrossesse(req: Request) async throws -> Grossesse {
        let grossesse = try req.content.decode(Grossesse.self)
        try await grossesse.save(on: req.db)
        return grossesse
    }
    
    @Sendable
    func getGrossesseByID(req: Request) async throws -> Grossesse {
        guard let grossesse = try await
                Grossesse.find(req.parameters.get("grossesseID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return grossesse
    }
    
    @Sendable
    func deleteGrossesse(req: Request) async throws -> HTTPStatus {
        guard let grossesse = try await
                Grossesse.find(req.parameters.get("grossesseID"), on: req.db) else {
            throw Abort (.notFound)
        }
        
        try await grossesse.delete(on: req.db)
        return.noContent
    }
    
}
