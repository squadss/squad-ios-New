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
        avatar = try decoder.decode("headimgurl")
    }
    
    func encode(to encoder: Encoder) throws {
        try encoder.encode(id, for: "id")
        try encoder.encode(username, for: "username")
        try encoder.encode(gender, for: "gender")
        try encoder.encode(nickname, for: "nickname")
        try encoder.encode(avatar, for: "headimgurl")
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
