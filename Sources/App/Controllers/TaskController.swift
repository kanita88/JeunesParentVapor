//
//  File.swift
//
//
//  Created by Apprenant 172 on 18/10/2024.
//

import Fluent
import Vapor
import FluentSQL

struct TaskController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let tasks = routes.grouped ("task")
        tasks.get(use: task_index)
        tasks.post(use: task_create)
        
        tasks.group("byemail") { task in
            task.get(":email" ,use: getTaskByEmail)
        }
        
        tasks.group(":taskID") { task in
            task.get(use: getTaskByID)
            task.delete(use: task_delete)
            task.put(use: task_update)
        }
    }
}


@Sendable
func task_index(req: Request) async throws -> [Task] {
    return try await Task.query(on: req.db).all()
}

@Sendable
func task_create(req: Request) async throws -> Task {
    let task = try req.content.decode(Task.self)
    try await task.save(on: req.db)
    return task
}

@Sendable
func getTaskByID(req: Request) async throws -> Task {
    guard let task = try await
            Task.find(req.parameters.get("taskID"), on: req.db) else {
        throw Abort(.notFound)
    }
    return task
}

@Sendable
func getTaskByEmail(req: Request) async throws -> Task {
    guard let email = req.parameters.get("email") else {
        throw Abort(.badRequest, reason: "Le paramètre 'email' est invalide ou manquant.")
    }
    
    if let sql = req.db as? SQLDatabase {
        let task = try await sql.raw("SELECT * FROM task WHERE email = \(bind: email)")
            .all(decodingFluent: Task.self)
        
        guard let task = task.first else {
            throw Abort(.notFound, reason: "Utilisateur non trouvé.")
        }
        return task
    }
    throw Abort(.internalServerError, reason: "La base de données n'est pas SQL.")
}

@Sendable
func task_update(req: Request) async throws -> Task {
    guard let taskIDString = req.parameters.get ("taskID"),
          let taskID = UUID(uuidString: taskIDString) else {
        throw Abort(.badRequest, reason: "ID d'utilisateur invalide.")
    }
    let updatedTask = try req.content.decode(Task.self)
    
    guard let task = try await Task.find(taskID, on:req.db) else {
        throw Abort(.notFound, reason: "Tache non trouvé.")
    }
    // Mise à jour des propriétés
    task.nom = updatedTask.nom
    task.tache = updatedTask.tache
    task.completed = updatedTask.completed
    
    try await task.save(on: req.db)
    return task
}

@Sendable
func task_delete(req: Request) async throws -> HTTPStatus {
    // Récupération du paramètre "taskID" depuis l'URL
    guard let taskID = req.parameters.get("taskID", as: UUID.self) else {
        throw Abort(.badRequest, reason: "Paramètre taskID non valide.")
    }
    
    // Rechercher la tâche dans la base de données à l'aide de son UUID
    guard let task = try await Task.find(taskID, on: req.db) else {
        throw Abort(.notFound, reason: "Tâche introuvable.")
    }
    
    // Supprimer la tâche trouvée
    try await task.delete(on: req.db)
    
    // Retourner le statut 204 No Content
    return .noContent
}
