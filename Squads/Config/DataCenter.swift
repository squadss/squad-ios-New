//
//  DataCenter.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/4.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import Disk

//注意: 写入本地的对象编码遵守Encoder和Decoder协议后, 需要实现其对应的方法
// init(from decoder: Decoder) throws { }
// func encode(to encoder: Encoder) throws { }
struct DataCenter {
    
    static var userInfo: User? {
        get { return object(key: "userInfo") }
        set { set(key: "userInfo", value: newValue) }
    }
    
    static var topSquad: SquadDetail? {
        get { return object(key: "squadDetail") }
        set { set(key: "squadDetail", value: newValue) }
    }
}

extension DataCenter {
    
    private static func object<T: Codable>(key: String, type: T.Type = T.self) -> T? {
        return try? Disk.retrieve(key, from: .applicationSupport, as: type)
    }
    
    private static func object<T: Codable>(key: String, type: [T].Type = [T].self) -> Array<T>? {
        return try? Disk.retrieve(key, from: .applicationSupport, as: type)
    }
    
    private static func object<T: Codable>(key: String, type: Set<T>.Type = Set<T>.self) -> Set<T>? {
        return try? Disk.retrieve(key, from: .applicationSupport, as: type)
    }
    
    private static func set<T: Codable>(key: String, value: T) {
        try? Disk.save(value, to: .applicationSupport, as: key)
    }
    
    private static func set<T: Codable>(key: String, value: Array<T>) {
        try? Disk.save(value, to: .applicationSupport, as: key)
    }
    
    private static func set<T: Codable>(key: String, value: Set<T>) {
        try? Disk.save(value, to: .applicationSupport, as: key)
    }
    
}
