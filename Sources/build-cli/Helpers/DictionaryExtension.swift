//
//  File.swift
//  
//
//  Created by Markus Springer2 on 08.05.21.
//

import Foundation

extension Dictionary where Key:Hashable {
    public func filterToDictionary <C: Collection> (keys: C) -> [Key:Value]
    where C.Iterator.Element == Key, C.IndexDistance == Int {
        
        var result = [Key:Value](minimumCapacity: keys.count)
        for key in keys { result[key] = self[key] }
        return result
    }
}
