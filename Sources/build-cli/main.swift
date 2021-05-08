import ArgumentParser
import Foundation
import SwiftShell
import Rainbow

enum BuildMode: String, ExpressibleByArgument {
    case mvn, mvnClean
}


@available(macOS 10.13, *)
struct Banner: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        abstract: "A utility for performing maths.",
        version: "1.0.0",
        subcommands: [ Build.self, Register.self]
    )
    
    @Option(help: "The path you want to register")
    var register: String?
    
}

@available(macOS 10.13, *)
struct Register: ParsableCommand, Decodable {
    
    @Argument(help: "Project name")
    var project: String
    
    mutating func run() {
        print("What is the name of the project?")
        let nameOpt = readLine()
        
        print("Which command do you want to run?")
        let commandOpt = readLine()
        
        guard var name = nameOpt, let command = commandOpt else {
            print("You need to provide a name and a command! Returning")
            return;
        }
        
        let fileManager = HomeFileManager(project: project)
        
        var projects = fileManager.getProjects()
        
        var currentPath = FileManager.default.currentDirectoryPath;
        
        if projects.contains(where: {$0.path == currentPath}) {
            print("Already registered");
        } else {
            
            
            currentPath = "/Users/ma.springer/Code/celonis5-microservices/cloud-integration-internal-client";
            name = "integration";
            
            projects.append(Project(path: currentPath, name: name, command: command));
        }
        fileManager.writeProjects(projects: projects);
        
    }
}

@available(macOS 10.13, *)
struct Build: ParsableCommand {
    
    @Argument(help: "Project name")
    var project: String
    
    @Option var mode: BuildMode = BuildMode.mvn
    
    mutating func run() {
        print("")
        let execution = ExecutionManager()
        let fileManager = HomeFileManager(project: project)
        
        var projects = fileManager.getProjects()
        
        var executionsOpt = fileManager.getExecutions()
        
        guard let executions = executionsOpt else {
            print("No executions defined");
            return;
        }
        
        if(executions.projects.contains(self.project)) {
            var configs = executions.configurations.filter { value in
                return value.name == self.project
            }.first!
            
            configs.steps.sort(by: { left, right in
                return left.position! < right.position!
            })
            
            let sortedExecutions = Dictionary(grouping: configs.steps, by: { $0.position! }).sorted(by: { $0.key < $1.key })
            
            
            
            let queue = DispatchQueue(label: "Test dispatch queue", attributes: .concurrent)
            let group = DispatchGroup()
            sortedExecutions.forEach { (key: Int, steps: [Step]) in
                //print("\u{1B}[1A\u{1B}[K -->Downloaded: \(key)%")
                
                let group = DispatchGroup()
                
                for step in steps {
                    
                    group.enter()
                    do {
                        queue.async {
                            print(step.step.green)
                            var project = projects.filter { project in
                                return project.name == step.step
                            }.first!
                            
                            execution.launch(command: project.command, path: project.path, executable: project.executable)
                            
                            group.leave()
                        }
                    }
                }
                group.wait()
            }
            
        } else {
            print("Doesn't contain project")
        }
    }
    
}


if #available(macOS 10.13, *) {
    Banner.main()
} else {
    print("Please use a newer version of macOS")
}
