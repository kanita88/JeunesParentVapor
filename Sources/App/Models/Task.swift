//
//  Task.swift
//  
//
//  Created by Apprenant 172 on 18/10/2024.
//

import Vapor
import Fluent

final class Task: Model, Content, @unchecked Sendable {
    
    static let schema = "task" // Nom de la table MySQL
    
    @ID(key: .id) //@ID(custom: "id")
    var id: UUID?
   
    @Field(key: "nom")
    var nom: String?
    
    @Field(key: "tache")
    var tache: String?
    
    @Field(key: "completed")
    var completed: Bool?
    
    @Field(key: "id_parent")  // L'ID du parent (facultatif)
    var id_parent: UUID?

    
    // Constructeur vide requis par Fluent
    init() {}
}
