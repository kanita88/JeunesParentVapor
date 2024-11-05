//
//  CreateParent.swift
//  JeunesParentVapor
//
//  Created by Apprenant 142 on 04/11/2024.
//

import Foundation
import Vapor
import Fluent

struct CreateParent: AsyncMigration  {
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("parents")
            .delete()
    }
    
    func prepare(on database: Database) async throws {
        try await database.schema("parents")
            .id()
            .field("nom", .string, .required)
            .field("prenom", .string,.required)
            .field("date_de_naissance", .string, .required)
            .unique(on: "email")
            .field("password", .string, .required)
            .field("premiere_experience", .string, .required)
            .create()
    }
    
    
}
