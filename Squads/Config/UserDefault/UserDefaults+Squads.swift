//
//  UserDefaultsKey.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension UserDefaults {
    
    public enum Defaults: String, UserDefaultHelper {
        case userToken       //用户的token
        case tokenExpiry     //token过期时间
        case isDarkKey       //是否为黑主题
        case topSquadKey      //是否存在置顶的squad
    }
}

extension UserDefaults {
    
    /// 是否存在置顶的squad
    var topSquad: String? {
        set { UserDefaults.Defaults.topSquadKey.store(value: newValue) }
        get { return UserDefaults.Defaults.topSquadKey.storedString }
    }
    
    /// 用户的token
    var token: String? {
        set { UserDefaults.Defaults.userToken.store(value: newValue) }
        get { return UserDefaults.Defaults.userToken.storedString }
    }
    
    /// token过期时间
    var tokenExpiry: TimeInterval? {
        set { UserDefaults.Defaults.tokenExpiry.store(value: newValue) }
        get { return UserDefaults.Defaults.tokenExpiry.storedDouble }
    }
    
    /// 是否为黑主题
    var isDark: Bool {
        set { UserDefaults.Defaults.isDarkKey.store(value: newValue) }
        get { return UserDefaults.Defaults.isDarkKey.storedBool }
    }
}
