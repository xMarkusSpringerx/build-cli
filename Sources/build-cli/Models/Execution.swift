//
//  File.swift
//  
//
//  Created by Markus Springer2 on 07.05.21.
//

import Foundation

struct Step: Codable {
    public var step: String;
    public var position: Int?;
    public var afterString: String?;
}

struct Configuration: Codable {
    public var name: String;
    public var steps: [Step]
}

struct Execution: Codable {
    public var projects: [String];
    public var configurations: [Configuration];
}
