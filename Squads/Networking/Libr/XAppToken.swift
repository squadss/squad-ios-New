//
//  XAppToken.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation

extension Date {
    var isInPast: Bool {
        let now = Date()
        return self.compare(now) == ComparisonResult.orderedAscending
    }
}

struct XAppToken {
    
    //过期时间: 一周以后过期,和服务器保持一致
    static func normal(token: String, expiry date: Date = Date(timeIntervalSinceNow: 24 * 3600 * 7)) -> XAppToken {
        var appToken = XAppToken()
        appToken.expiry = date
        appToken.token = token
        return appToken
    }
    
    // MARK: - Initializers
    let defaults: UserDefaults
    
    init() {
        self.defaults = UserDefaults.standard
    }
    
    // MARK: - Properties
    
    var token: String? {
        get {
            return defaults.token
        }
        set(newToken) {
            defaults.token = newToken
        }
    }
    
    var expiry: Date? {
        get {
            if let expiry = defaults.tokenExpiry {
                return Date(timeIntervalSince1970: expiry)
            }
            return nil
        }
        set(newExpiry) {
            if let expiry = newExpiry?.timeIntervalSince1970 {
                defaults.tokenExpiry = expiry
            }
        }
    }
    
    var expired: Bool {
        if let expiry = expiry {
            return expiry.isInPast
        }
        return true
    }
    
    var isValid: Bool {
        if let token = token {
            return !token.isEmpty && !expired
        }
        return false
    }
    
}
