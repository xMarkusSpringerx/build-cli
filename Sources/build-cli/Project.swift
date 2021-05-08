//
//  File.swift
//  
//
//  Created by Markus Springer2 on 04.05.21.
//

import Foundation


struct Project: Codable {
    public var path: String
    public var name: String
    public var command: String
    public var executable: String?
}
