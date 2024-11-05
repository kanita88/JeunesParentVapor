//
//  LogMiddleware.swift
//  JeunesParentVapor
//
//  Created by Apprenant 142 on 04/11/2024.
//

import Vapor

struct LogMiddleware: AsyncMiddleware {
    func respond(to request: Vapor.Request, chainingTo next: any
Vapor.AsyncResponder) async throws -> Vapor.Response {
        
    print ("New request send !", request.description)
        
        return try await next.respond(to: request)

}
}
