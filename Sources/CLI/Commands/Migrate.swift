import ArgumentParser
import Foundation

struct Migrate: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "migrate",
        subcommands: [Run.self, New.self],
        defaultSubcommand: Run.self
    )
    
    /// Generate a new migration
    struct New: ParsableCommand {
        @Argument
        var name: String
        
        func run() throws {
            var migrationLocation = "Sources"
            if
                let migrationLocations = try? Process()
                    .shell("find Sources -type d -name 'Migrations'")
                    .split(separator: "\n"),
                let migrationsFolder = migrationLocations.first
            {
                migrationLocation = String(migrationsFolder)
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let fileName = "_\(dateFormatter.string(from: Date()))\(name)"
            let template = self.migrationTemplate(name: fileName)

            let destinationURL = URL(fileURLWithPath: "\(migrationLocation)/\(fileName).swift")
            try template.write(to: destinationURL, atomically: true, encoding: .utf8)
            print("Created migration '\(fileName)' at \(migrationLocation). Don't forget to add it to `Services.db.migrations`!")
        }
        
        private func migrationTemplate(name: String) -> String {
            """
            import Alchemy
            
            struct \(name): Migration {
                func up(schema: Schema) {
                    schema.create(table: "users") {
                        $0.int("id").primary()
                        $0.string("name").notNull()
                        $0.string("email").notNull().unique()
                    }
                }
                
                func down(schema: Schema) {
                    schema.drop(table: "users")
                }
            }
            """
        }
    }

    /// Passthrough command for running an app with the migrate
    /// parameter.
    struct Run: ParsableCommand {
        @Option(name: .shortAndLong, help: "The executable product to run. Defaults to the current folder name.")
        var product: String?
        
        @Flag(help: "Should migrations be rolled back.")
        var rollback: Bool = false
        
        func run() throws {
            let currentPath = FileManager.default.currentDirectoryPath.split(separator: "/").last
            guard let executable = self.product ?? currentPath.map(String.init) else {
                return
            }
            
            var commandString = "swift run -c release -Xswiftc -g \(executable) migrate"
            if self.rollback {
                commandString.append(" --rollback")
            }
            _ = try Process().shell(commandString)
        }
    }
}

