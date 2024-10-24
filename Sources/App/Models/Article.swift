//
//  Article.swift
//  
//
//  Created by Apprenant 172 on 18/10/2024.
//

import Vapor
import Fluent

final class Article: Model, Content, @unchecked Sendable {
    
    static let schema = "article" // Nom de la table MySQL
    
    @ID(key: .id) //@ID(custom: "id")
    var id: UUID?
    
    @Field(key: "title")
    var title: String?
   
    @Field(key: "description")
    var description: String?
    
    @Field(key: "publicationDate")
    var publicationDate: String?
    
    @Field(key: "read_time")
    var read_time: Int?
    
    @Field(key: "imageURL")
    var imageURL : String?
    
    @Field(key: "category")
    var category: String?
    
    @Field(key: "content")
    var content: String?

    
    // Constructeur vide requis par Fluent
    init() {}
}

