//
//  User.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/4.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import Codextended
import MessageKit

enum Gender: String, Codable {
    case male = "M"      //"男"
    case female = "F"    //"女"
    case unknown = "N"   //"未知"
}

struct User: Codable {

    var id: Int
    var username: String
    var nickname: String
    var gender: Gender
    var avatar: String

    init(from decoder: Decoder) throws {
        id = try decoder.decode("id")
        username = try decoder.decode("username")
        gender = try decoder.decode("gender")
        nickname = try decoder.decode("nickname")
        avatar = try decoder.decode("nickname")
    }
    
    //FIXME: - DEBUG
    init(username: String = "") {
        self.username = username
        self.nickname = ""
        self.gender = .unknown
        self.avatar = ""
        self.id = 0
    }
}

extension User: Hashable {
    
    var hashValue: Int {
        return username.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(username.hashValue)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.username == rhs.username
    }
}


extension User {
    
    func save() {
        DataCenter.userInfo = self
    }
    
    /// 当前用户
    static func currentUser() -> User? {
        return DataCenter.userInfo
    }
    
    /// 移除当前用户
    static func removeCurrentUser() {
        DataCenter.userInfo = nil
    }
}

extension User: SenderType {
    
    var senderId: String {
        return username
    }
    
    var displayName: String {
        return nickname
    }
}

struct UserTDO {
    
    static var instance = UserTDO()
    
    var username: String?
    var password: String?
    var rePassword: String?
    var inviteCode: String?
    var nationCode: String?
    var verificationcode: String?
    var phoneNumber: String?
    var purePhoneNumber: String?
    var nickname: String?
    var avatar: Data?
    
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
        if properties.contains(.password) && (password == nil || password?.isEmpty == true) {
            return .failure(.custom("Password cannot be empty"))
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

//Mark: - 介绍Codextended的用法

//struct User: Codable {
//
//    var username: String
//    var sex: Int?
//    var date: Date
//
//    init(from decoder: Decoder) throws {
//        username = try decoder.decode("username")
//        sex = try decoder.decodeIfPresent("sex")
//        date = try decoder.decode("date", using: DateFormatter())
//    }
//
//    init() {
//        username = ""
//        sex = nil
//        date = Date()
//    }
//
//}

//func test() {
//    let user = User()
//    do {
//        let data = try user.encoded()
//        let article = try data.decoded() as User
//    } catch {
//        print(error)
//    }
//}
