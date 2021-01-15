import ArgumentParser
import Foundation

/// Passthrough command for running an app with the serve parameter.
struct Serve: ParsableCommand {
    @Option(name: .shortAndLong, help: "The executable product to run. Defaults to the current folder name.")
    var product: String?
    
    @Option(help: "The host to serve at. Defaults to `::1` aka `localhost`.")
    var host = "::1"

    @Option(help: "The port to serve at. Defaults to `8888`.")
    var port = 8888
    
    @Option(help: "The unix socket to serve at. If this is provided, the host and port will be ignored.")
    var unixSocket: String?
    
    func run() throws {
        let currentPath = FileManager.default.currentDirectoryPath.split(separator: "/").last
        guard let executable = self.product ?? currentPath.map(String.init) else {
            return
        }
        
        if let socket = self.unixSocket {
            _ = try Process().shell("swift run -c release -Xswiftc -g \(executable) serve --unixSocket \(socket)")
        } else {
            _ = try Process().shell("swift run -c release -Xswiftc -g \(executable) serve --host \(self.host) --port \(self.port)")
        }
    }
}
