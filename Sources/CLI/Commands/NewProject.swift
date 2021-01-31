import ArgumentParser
import Foundation

private let kQuickstartRepo = "git@github.com:alchemy-swift/alchemy.git"
private let kTempDirectory = "/tmp/alchemy-quickstart"
private let kBackendDirectory = "Quickstarts/Backend"
private let kFullstackDirectory = "Quickstarts/Fullstack"
private let kXcodeprojName = "AlchemyFullstack.xcodeproj"

/// What project template does the user want downloaded?
private enum TemplateType: CaseIterable {
    /// A fresh, backend only template.
    case backend
    /// Fullstack project with Backend, iOS, Shared.
    case fullstack
    
    var description: String {
        switch self {
        case .backend:
            return "Backend: an Alchemy server."
        case .fullstack:
            return "Fullstack: an Xcode project with 3 targets; iOS, Backend, & Shared."
        }
    }
}

/// Creates a new project from one of the quickstart templates.
struct NewProject: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "new")
    
    @Argument(help: "What to name your project.")
    var name: String
    
    func run() throws {
        print("Cloning quickstart project...")
        // Blow away the temp directory so git doesn't complain if it already exists.
        _ = try Process().shell("rm -rf \(kTempDirectory)")
        _ = try Process().shell("git clone \(kQuickstartRepo) \(kTempDirectory)")
        
        try self.createProject()
    }
    
    private func createProject() throws {
        switch self.queryTemplateType() {
        case .backend:
            _ = try Process().shell("cp -r \(kTempDirectory)/\(kBackendDirectory) \(self.name)")
            _ = try Process().shell("git init \(name)")
            print("Created package at '\(self.name)'.")
        case .fullstack:
            _ = try Process().shell("cp -r \(kTempDirectory)/\(kFullstackDirectory) \(self.name)")
            
            let projectTarget = "\(self.name)/\(self.name).xcodeproj"
            _ = try Process().shell("mv \(self.name)/\(kXcodeprojName) \(projectTarget)")
            // Rename relevant scheme containers so the iOS scheme loads properly.
            _ = try Process().shell("find \(self.name) -type f -name '*.xcscheme' -print0 | xargs -0 sed -i '' -e 's/AlchemyFullstack/\(self.name)/g'")
            _ = try Process().shell("git init \(name)")
            print("Created project at '\(self.name)'. Use the project file '\(projectTarget)'.")
        }
    }
    
    private func queryTemplateType(allowed: [TemplateType] = TemplateType.allCases) -> TemplateType {
        let response = Process().queryUser(
            query: "Which template would you like to use?",
            choices: allowed.map { $0.description }
        )
        
        return allowed[response]
    }
}

extension Process {
    /// Gives queries as numerical options, then waits until the user enters a number.
    func queryUser(query: String, choices: [String]) -> Int {
        print(query)
        for (index, choice) in choices.enumerated() {
            print("\(index): \(choice)")
        }
        
        return getResponse(prompt: "> ", allowedResponses: choices.enumerated().map { "\($0.offset)" })
    }
    
    private func getResponse(prompt: String, allowedResponses: [String]) -> Int {
        print(prompt, terminator: "")
        var response = readLine()
        while response.map({ !allowedResponses.contains($0) }) ?? false {
            print("Invalid response.")
            print(prompt, terminator: "")
            response = readLine()
        }
        
        guard let unwrappedResponse = response, let intResponse = Int(unwrappedResponse) else {
            return 0
        }
        
        return intResponse
    }
}
