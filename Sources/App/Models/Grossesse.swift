//
//  Grossesse.swift
//  JeunesParentVapor
//
//  Created by Apprenant 172 on 23/10/2024.
//

import Vapor
import Fluent

final class Grossesse: Model, Content, @unchecked Sendable {
    
    static let schema = "grossesse" // Nom de la table MySQL
    
    @ID(key: .id) //@ID(custom: "id")
    var id: UUID?
    
    @Field(key: "date_menstruation")
    var date_menstruation: Date?
   
    @Field(key: "date_conception")
    var date_conception: Date?
    
    @Field(key: "date_accouchement")
    var date_accouchement: Date?
    
    @Field(key: "grossesse_multiple")
    var grossesse_multiple: Bool?
    
    @Field(key: "mode_accouchement")
    var mode_accouchement : String?
    
    @Field(key: "conditions_medicales")
    var conditions_medicales: String?
    
    @Field(key: "id_parent")  // L'ID du parent (facultatif)
    var id_parent: UUID?

    
    // Constructeur vide requis par Fluent
    init() {}
}
