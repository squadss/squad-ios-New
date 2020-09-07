//
//  ActivityMember.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/15.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation

struct ActivityMember: Codable, Equatable {
    
    // 用户id
    var accountId: Int
    // 活动id
    var activityId: Int
    // 我的时间
    var myTime: Array<TimePeriod>
    // 昵称
    var nickname: String
    // 头像
    var avatar: String
    
    var isResponded: Bool {
        return !myTime.isEmpty
    }
    
    var isGoing: Bool?
    
    init(activityId: Int, user: User, isGoing: Bool? = nil) {
        self.accountId = user.id
        self.nickname = user.nickname
        self.avatar = user.avatar
        self.activityId = activityId
        self.myTime = []
        self.isGoing = isGoing
    }
    
    init(from decoder: Decoder) throws {
        accountId = try decoder.decode("accountId")
        activityId = try decoder.decode("activityId")
        nickname = try decoder.decode("nickname")
        avatar = try decoder.decode("headimgurl")
        let jsonString = try decoder.decode("selectTime", as: String.self)
        
        // 服务器返回的jsonString 有问题, 引号"" 在JAVA后台被转义为 &quot, 处理办法是将 &quot 字符替换回 "
        /*
         https://blog.csdn.net/charset_ok/article/details/80239882?utm_medium=distribute.pc_aggpage_search_result.none-task-blog-2~all~first_rank_v2~rank_v25-8-80239882.nonecase&utm_term=ios%20%E5%8F%8C%E5%BC%95%E5%8F%B7%E8%BD%AC%E4%B9%89
         */
        
        let newString = jsonString.replacingOccurrences(of: "&amp;quot;", with: "\"")
        myTime = try Array<TimePeriod>.decodeJSON(from: newString)
    }
    
    func encode(to encoder: Encoder) throws {
        try encoder.encode(accountId, for: "accountId")
        try encoder.encode(activityId, for: "activityId")
        try encoder.encode(nickname, for: "nickname")
        try encoder.encode(avatar, for: "headimgurl")
        try encoder.encode(myTime.toJSONString(), for: "selectTime")
    }
    
    static func == (lhs: ActivityMember, rhs: ActivityMember) -> Bool {
        return lhs.accountId == rhs.accountId && lhs.activityId == rhs.activityId
    }
    
    func isEquadTo(_ other: ActivityMember) -> Bool {
        return accountId == other.accountId
            && myTime == other.myTime
            && activityId == other.activityId
            && nickname == other.nickname
            && avatar == other.avatar
    }
}
