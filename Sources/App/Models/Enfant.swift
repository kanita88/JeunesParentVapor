//
//  Enfant.swift
//  
//
//  Created by Apprenant 172 on 22/10/2024.
//

import Vapor
import Fluent

final class Enfant: Model, Content, @unchecked Sendable {
    
    static let schema = "enfant" // Nom de la table MySQL
    
    @ID(key: .id) //@ID(custom: "id")
    var id: UUID?
    
    @Field(key: "nom")
    var nom: String?
   
    @Field(key: "date_de_naissance")
    var birthDate: Date?
    
    @Field(key: "terme")
    var terme: Bool?
    
    @Field(key: "alimentation")
    var alimentation: String?
    
    @Field(key: "qualite_sommeil")
    var qualite_sommeil : Bool?
    
    @Field(key: "ville")
    var ville: String?
    
    @Field(key: "genre")
    var genre: String?
    
    @Field(key: "poids")
    var poids: Double?
    
    @Field(key: "taille")
    var taille: Double?
    
    @Field(key: "id_parent")  // L'ID du parent (facultatif)
    var id_parent: UUID?

    
    // Constructeur vide requis par Fluent
    init() {}
}
