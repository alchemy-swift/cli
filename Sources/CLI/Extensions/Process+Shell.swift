import Foundation

struct ShellError: Error {
    let output: String
}

extension Process {
    /// Executes a shell command.
    ///
    /// - throws: `ShellError` if `standardError` isn't empty afterwards.
    func shell(_ command: String, verbose: Bool = false) throws -> String {
        self.launchPath = "/bin/bash"
        self.arguments = ["-c", command]

        var outputPipe: Pipe?
        var errorPipe: Pipe?

        if !verbose {
            outputPipe = Pipe()
            errorPipe = Pipe()
            
            self.standardOutput = outputPipe
            self.standardError = errorPipe
        }
        
        self.launch()
        
        let outputData = outputPipe?.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe?.fileHandleForReading.readDataToEndOfFile()
        
        self.waitUntilExit()
        
        let output = String(decoding: outputData ?? Data(), as: UTF8.self)
        let error = String(decoding: errorData ?? Data(), as: UTF8.self)

        if self.terminationStatus == 0 {
            return output
                .reduce("") { $0 + String($1) }
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            throw ShellError(output: error)
        }
    }
}
