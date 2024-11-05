import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "root",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "young_parents"
    ), as: .mysql)

    app.migrations.add(CreateTodo())
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin],
        cacheExpiration: 800
    )

    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    // Add the CORS middleware to the application
    app.middleware.use(corsMiddleware)
    
    
    // Récupération de la clé secrète depuis les variables d'environnement
    guard let secret = Environment.get("SECRET_KEY"), !secret.isEmpty else {
            fatalError("SECRET_KEY is missing or empty in the environment variables.")
        }
    // Création de la clé HMAC avec la clé secrète
    let hmacKey = HMACKey(from: Data(secret.utf8))
    
    // Ajout de la clé HMAC à la configuration JWT avec l'algorithme SHA-256
    await app.jwt.keys.add(hmac: hmacKey, digestAlgorithm: .sha256)
    
    //print(hmacKey)
    
    // register routes
    try routes(app)
}
