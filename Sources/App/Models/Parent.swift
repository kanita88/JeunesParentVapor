//
//  Parent.swift
//
//
//  Created by Apprenant 172 on 18/10/2024.
//

import Vapor
import Fluent

final class Parent: Model, Content, @unchecked Sendable {
    
    static let schema = "parent" // Nom de la table MySQL
    
    @ID(key: .id) //@ID(custom: "id")
    var id: UUID?
   
    @Field(key: "nom")
    var nom: String?
    
    @Field(key: "prenom")
    var prenom: String?
    
    @Field(key: "password")
    var password: String?
    
    @Field(key: "date_de_naissance")
    var date_de_naissance: Date?
    
    @Field(key: "email")
    var email: String?
    
    @Field(key: "premiere_experience")
    var premiere_experience: String?
    
    // Constructeur vide requis par Fluent
    init() {}
}
