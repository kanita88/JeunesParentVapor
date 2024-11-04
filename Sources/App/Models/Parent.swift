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
    
    init(id: UUID? = nil, nom: String, prenom: String, password: String, date_de_naissance: Date, email: String, premiere_experience: String) {
            self.id = id
            self.nom = nom
            self.prenom = prenom
            self.password = password
            self.date_de_naissance = date_de_naissance
            self.email = email
            self.premiere_experience = premiere_experience
            
            
        }
    
    func toDTO () -> ParentDTO {
        .init(
            id: self.id,
            email: self.$email.value!!
        )
    }
}

//// Extension pour la conformité à ModelAuthenticatable
//extension Parent: ModelAuthenticatable {
//    static let usernameKey = \Parent.$email
//    static let passwordHashKey = \Parent.$password
//    
//    func verify(password: String) throws -> Bool {
//        try Bcrypt.verify(password, created: self.password!)
//    }
//}
