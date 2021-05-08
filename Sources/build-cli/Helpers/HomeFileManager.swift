//
//  File.swift
//  
//
//  Created by Markus Springer2 on 04.05.21.
//

import Foundation

@available(macOS 10.13, *)
class ExecutionManager {
    func launch(command: String, path: String, executable: String?) -> Void {
        
        let task = Process()
        
        //the path to the external program you want to run
        if(executable != nil) {
            task.executableURL = URL(fileURLWithPath: executable!)
        } else {
            task.executableURL = URL(fileURLWithPath: "/usr/local/bin/node")
        }
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.currentDirectoryURL = URL(fileURLWithPath: path)
        
        task.environment = ["PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]
        
        task.arguments = command.components(separatedBy: " ")
        
        task.terminationHandler = {
            _ in
            //print("process run complete.".green)
        }
        
        try! task.run()
        
        let outputHandle = pipe.fileHandleForReading
        outputHandle.waitForDataInBackgroundAndNotify()
        
        outputHandle.readabilityHandler = { pipe in
            guard let currentOutput = String(data: pipe.availableData, encoding: .utf8) else {
                print("Error decoding data: \(pipe.availableData)".red)
                return
            }
            guard !currentOutput.isEmpty else {
                return
            }
            DispatchQueue.main.async {
                print(currentOutput, terminator:"")
            }
        }
        
        task.waitUntilExit()
        print("Task successfully finished".green)
    }
}

@available(macOS 10.12, *)
struct HomeFileManager {
    
    public let project: String;
    
    init(project: String) {
        self.project = project;
        if(!self.fileExists(fileName: "projects.json")) {
            print("File does not exist");
            self.writeToFile(content: "[]", fileName: "projects.json")
        }
    }
    
    public func getBaseFolder() -> URL {
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".build-cli");
    }
    
    public func verifyFolder() -> Bool {
        do {
            let dataUrl: URL = self.getBaseFolder();
            var isDir:ObjCBool = true
            if !FileManager.default.fileExists(atPath: dataUrl.absoluteString, isDirectory: &isDir) {
                try FileManager.default.createDirectory(at: dataUrl, withIntermediateDirectories: true)
            }
            return true;
        } catch {
            print(error.localizedDescription)
            return false;
        }
    }
    
    public func readLocalFile(fileName: String) -> Data? {
        do {
            let test = self.getBaseFolder().appendingPathComponent(fileName);
            let url = URL(string: test.absoluteString)
            
            return try String(contentsOfFile: url!.path).data(using: .utf8)
        } catch {
            print(error)
            return nil;
        }
        
        return nil
    }
    
    public func fileExists(fileName: String) -> Bool {
        let fileUrl = self.getBaseFolder().appendingPathComponent(fileName)
        let url = URL(string: fileUrl.absoluteString)
        
        return FileManager.default.fileExists(atPath: url!.path)
    }
    
    public func writeToFile(content: String, fileName: String) {
        let fileUrl = self.getBaseFolder().appendingPathComponent(fileName)
        let url = URL(string: fileUrl.absoluteString)
        
        do {
            
            try content.write(to: url!, atomically: false, encoding: .utf8)
            
        } catch {
            print(error.localizedDescription)
            
        }
    }
    
    public func writeProjects(projects: [Project]) {
        do {
            let fileUrl = self.getBaseFolder().appendingPathComponent("projects.json")
            let url = URL(string: fileUrl.absoluteString)
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(projects)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)!
            try json.write(to: url!, atomically: false, encoding: .utf8)
        } catch {
            print("Cannot write to file")
        }
    }
    
    public func getProjects() -> [Project] {
        var data = self.readLocalFile(fileName: "projects.json");
        let jsonDecoder = JSONDecoder()
        do {
            return try jsonDecoder.decode([Project].self, from: data!)
        } catch {
            return []
        }
    }
    
    public func getExecutions() -> Execution? {
        var data = self.readLocalFile(fileName: "executions.json");
        let jsonDecoder = JSONDecoder()
        do {
            return try jsonDecoder.decode(Execution.self, from: data!)
        } catch {
            print("asdf")
            return nil
        }
    }
}
