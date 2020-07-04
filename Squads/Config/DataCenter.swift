//
//  DataCenter.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/4.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import Disk

struct DataCenter {
    
    static var userInfo: User? {
        get { return object(key: "userInfo") }
        set { set(key: "userInfo", value: newValue) }
    }
    
}

extension DataCenter {
    
    private static func object<T: Codable>(key: String, type: T.Type = T.self) -> T? {
        return try? Disk.retrieve(key + ".json", from: .documents, as: type)
    }
    
    private static func object<T: Codable>(key: String, type: [T].Type = [T].self) -> Array<T>? {
        return try? Disk.retrieve(key + ".json", from: .documents, as: type)
    }
    
    private static func object<T: Codable>(key: String, type: Set<T>.Type = Set<T>.self) -> Set<T>? {
        return try? Disk.retrieve(key + ".json", from: .documents, as: type)
    }
    
    private static func set<T: Codable>(key: String, value: T) {
        try? Disk.save(value, to: .documents, as: key + ".json")
    }
    
    private static func set<T: Codable>(key: String, value: Array<T>) {
        try? Disk.save(value, to: .documents, as: key + ".json")
    }
    
    private static func set<T: Codable>(key: String, value: Set<T>) {
        try? Disk.save(value, to: .documents, as: key + ".json")
    }
    
}
