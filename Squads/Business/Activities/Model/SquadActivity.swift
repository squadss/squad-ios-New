//
//  SquadActivity.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/15.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import SwiftDate

struct SquadActivity: Codable, Equatable {
    
    typealias TimeModel = (date: String, month: String, day: String)
    
    var id: Int = 0
    var accountId: Int = 0
    var squadId: Int = 0
    var title: String!
    var activityType: EventCategory
    var activityStatus: ActivityStatus
    
    var startTime: String?
    var endTime: String?
    var position: SquadLocation?
    var gmtCreate: String?
    
    var responsedMembers: Array<ActivityMember>?
    var waitingMembers: Array<User>?
    var goingMembers: Array<User>?
    var rejectMembers: Array<User>?
    
    // 是否正在请求中
    var requestStatus: Bool = false
    
    init(from decoder: Decoder) throws {
        id = try decoder.decode("id")
        accountId = try decoder.decode("accountId")
        squadId = try decoder.decode("squadId")
        title = try decoder.decode("title")
        activityType = try decoder.decode("activityType")
        activityStatus = try decoder.decode("activityStatus")
        startTime = try decoder.decodeIfPresent("startTime")
        endTime = try decoder.decodeIfPresent("endTime")
        gmtCreate = try decoder.decodeIfPresent("gmtCreate")
        
        let address = try decoder.decodeIfPresent("address", as: String.self)
        let latitude = try decoder.decodeIfPresent("latitude", as: String.self)
        let longitude = try decoder.decodeIfPresent("longitude", as: String.self)
        if let a = address, let la = latitude, let lo = longitude, !la.isEmpty, !lo.isEmpty {
            position = SquadLocation(address: a, longitude: lo.asDouble(), latitude: la.asDouble())
        }
    }
    
    func encode(to encoder: Encoder) throws {
        try encoder.encode(id, for: "id")
        try encoder.encode(accountId, for: "accountId")
        try encoder.encode(squadId, for: "squadId")
        try encoder.encode(title, for: "title")
        try encoder.encode(activityType, for: "activityType")
        try encoder.encode(activityStatus, for: "activityStatus")
        try encoder.encode(gmtCreate, for: "gmtCreate")
    }
    
    func isEquadTo(_ other: SquadActivity) -> Bool {
        return id == other.id
            && accountId == other.accountId
            && squadId == other.squadId
            && title == other.title
            && position == other.position
            && activityType == other.activityType
            && activityStatus == other.activityStatus
            && responsedMembers == other.responsedMembers
            && waitingMembers == other.waitingMembers
            && goingMembers == other.goingMembers
            && rejectMembers == other.rejectMembers
    }
    
    static func == (lhs: SquadActivity, rhs: SquadActivity) -> Bool {
        return lhs.id == rhs.id
    }
    
    func fromPrepareMembers(responede: Array<ActivityMember>?, waiting: Array<User>?) -> SquadActivity {
        var this = self
        this.responsedMembers = responede
        this.waitingMembers = waiting
        this.requestStatus = false
        return this
    }
    
    func fromGoingMembers(accept a_list: Array<User>?, reject r_list: Array<User>?) -> SquadActivity {
        var this = self
        this.goingMembers = a_list
        this.rejectMembers = r_list
        this.requestStatus = false
        return this
    }
    
    func requestingStatus() -> SquadActivity {
        var this = self
        this.requestStatus = true
        return this
    }
    
    /// 返回(date, month, day)
    func formatterStartTime() -> TimeModel? {
        // startTime 服务器使用的是北京时区, 需要先按照北京时区转为时间戳, 在将时间戳按照本地时区转为日期字符串显示
        guard let unwrappedStartTime = startTime else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 8 * 60 * 60)
        let date = dateFormatter.date(from: unwrappedStartTime)
        if let unwrappedNewDate = date {
            
            dateFormatter.timeZone = .current
            dateFormatter.calendar = .current
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.locale = .current
            
            let date = dateFormatter.string(from: unwrappedNewDate.date)
            dateFormatter.dateFormat = "MMM"
            let month = dateFormatter.string(from: unwrappedNewDate.date)
            dateFormatter.dateFormat = "dd"
            let day = dateFormatter.string(from: unwrappedNewDate.date)
            return (date, month, day)
        } else {
            return nil
        }
    }
    
    #if DEBUG
    static let test = SquadActivity(id: 8, accountId: 2, squadId: 2, title: "好吃不贵，经济实惠", activityType: .food, activityStatus: .prepare)
    
    init(id: Int, accountId: Int, squadId: Int, title: String, activityType: EventCategory, activityStatus: ActivityStatus) {
        self.id = id
        self.accountId = accountId
        self.squadId = squadId
        self.title = title
        self.activityType = activityType
        self.activityStatus = activityStatus
    }
    
    #endif
}
