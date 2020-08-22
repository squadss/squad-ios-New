//
//  UserTDO.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/28.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation

struct UserTDO {
    
    static var instance = UserTDO()
    
    var username: String?
    var password: String?
    var rePassword: String?
    var inviteCode: String?
    var nationCode: String?
    var verificationcode: String?
    var phoneNumber: String?
    var nickname: String?
    var avatar: Data?
    
    var purePhoneNumber: String? {
        if let phoneNumber = phoneNumber, let nationCode = nationCode {
            return nationCode + phoneNumber
        }
        return nil
    }
    
    struct Properties: OptionSet {
        
        static let username = Properties(rawValue: 1 << 0)
        static let password = Properties(rawValue: 1 << 1)
        static let rePassword = Properties(rawValue: 1 << 2)
        static let phoneNumber = Properties(rawValue: 1 << 3)
        static let verificationcode = Properties(rawValue: 1 << 4)
        static let nickname = Properties(rawValue: 1 << 5)
        static let avatar = Properties(rawValue: 1 << 6)
        
        public var rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    func checkout(properties: Properties) -> Result<UserTDO, GeneralError> {
        if properties.contains(.username) && (username == nil || username?.isEmpty == true) {
            return .failure(.custom("Username cannot be empty"))
        }
        if properties.contains(.username) && (username!.count < 6 || username!.count > 18) {
            return .failure(.custom("Please enter a 6-bit to 18-bit user name"))
        }
        if properties.contains(.password) && (password == nil || password?.isEmpty == true) {
            return .failure(.custom("Password cannot be empty"))
        }
        if properties.contains(.password) && (password!.count < 6 || password!.count > 18) {
            return .failure(.custom("Please enter a 6-bit to 18-bit password"))
        }
        if properties.contains(.rePassword) && (rePassword == nil || rePassword?.isEmpty == true) {
            return .failure(.custom("Please enter your password again"))
        }
        if properties.contains(.rePassword) && (rePassword != password) {
            return .failure(.custom("The two passwords do not agree"))
        }
        if properties.contains(.phoneNumber) && (phoneNumber == nil || phoneNumber?.isEmpty == true) {
            return .failure(.custom("The cell phone number cannot be empty"))
        }
        if properties.contains(.phoneNumber) && (phoneNumber?.count != 11) {
            return .failure(.custom("Incorrect phone number format!"))
        }
        if properties.contains(.verificationcode) && (verificationcode == nil || verificationcode?.isEmpty == true) {
            return .failure(.custom("The captcha cannot be empty"))
        }
        if properties.contains(.nickname) && (nickname == nil || nickname?.isEmpty == true) {
            return .failure(.custom("Nickname cannot be empty"))
        }
        if properties.contains(.avatar) && (avatar == nil || avatar?.isEmpty == true) {
            return .failure(.custom("Please upload an avatar"))
        }
        return .success(self)
    }
}
