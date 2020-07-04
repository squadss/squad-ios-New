//
//  UserDefaultHelper.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation

public protocol UserDefaultHelper {
    var uniqueKey: String { get }
}

extension UserDefaultHelper where Self: RawRepresentable, Self.RawValue == String {
    
    public func store(value: Any?){
        UserDefaults.standard.set(value, forKey: uniqueKey)
    }
    
    public var storedValue: Any? {
        return UserDefaults.standard.value(forKey: uniqueKey)
    }
    
    public var storedString: String? {
        return storedValue as? String
    }
    
    public func store(url: URL?) {
        UserDefaults.standard.set(url, forKey: uniqueKey)
    }
    public var storedURL: URL? {
        return UserDefaults.standard.url(forKey: uniqueKey)
    }
    
    public func store(value: Bool) {
        UserDefaults.standard.set(value, forKey: uniqueKey)
    }
    
    public var storedBool: Bool {
        return UserDefaults.standard.bool(forKey: uniqueKey)
    }
    
    public func store(value: Int) {
        UserDefaults.standard.set(value, forKey: uniqueKey)
    }
    public var storedInt: Int {
        return UserDefaults.standard.integer(forKey: uniqueKey)
    }
    
    public func store(value: Double) {
        UserDefaults.standard.set(value, forKey: uniqueKey)
    }
    public var storedDouble: Double {
        return UserDefaults.standard.double(forKey: uniqueKey)
    }
    
    public func store(value: Float) {
        UserDefaults.standard.set(value, forKey: uniqueKey)
    }
    public var storedFloat: Float {
        return UserDefaults.standard.float(forKey: uniqueKey)
    }
    
    public var uniqueKey: String {
        return "\(Self.self)_\(rawValue)"
    }
    
    /// removed object from standard userdefaults
    public func removed() {
        UserDefaults.standard.removeObject(forKey: uniqueKey)
    }
    
}
