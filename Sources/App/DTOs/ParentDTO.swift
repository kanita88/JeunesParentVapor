//
//  ParentDTO.swift
//  JeunesParentVapor
//
//  Created by Apprenant 172 on 04/11/2024.
//

import Fluent
import Vapor

struct ParentDTO: Content {
    var id: UUID?
    var email: String
}
