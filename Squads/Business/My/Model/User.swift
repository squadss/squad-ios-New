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

    // 下面这几条信息, 需要查询个人详情接口才会有数据
    var phoneNumber: String?        //"17771865607"
    var nationCode: String?         //"+86"
    var purePhoneNumber: String?    //"+8617771865607"
    
    init(from decoder: Decoder) throws {
        id = try decoder.decode("id")
        username = try decoder.decode("username")
        gender = try decoder.decode("gender")
        nickname = try decoder.decode("nickname")
        avatar = try decoder.decode("headimgurl")
        phoneNumber = try decoder.decodeIfPresent("phoneNumber")
        nationCode = try decoder.decodeIfPresent("nationCode")
        purePhoneNumber = try decoder.decodeIfPresent("purePhoneNumber")
    }
    
    func encode(to encoder: Encoder) throws {
        try encoder.encode(id, for: "id")
        try encoder.encode(username, for: "username")
        try encoder.encode(gender, for: "gender")
        try encoder.encode(nickname, for: "nickname")
        try encoder.encode(avatar, for: "headimgurl")
        try encoder.encode(gender, for: "phoneNumber")
        try encoder.encode(nickname, for: "nationCode")
        try encoder.encode(avatar, for: "purePhoneNumber")
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
        return lhs.id == rhs.id
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
