//
//  SquadActivity.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/15.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation

struct SquadActivity: Codable, Equatable {
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
    
    // 显示开始的日期和月份
    var startDay: String = ""
    var startMonth: String = ""
    var startDate: String = "TBD"
    
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
        
        if let unwrappedStartTime = startTime {
            let date = unwrappedStartTime.toDate("yyyy-MM-dd HH:mm:ss", region: .current)
            let dateComponents = date?.dateComponents
            dateComponents?.month.flatMap{ startMonth = String($0) }
            dateComponents?.day.flatMap{ startDay = String($0) }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.locale = .init(identifier: "en_US")
            date.flatMap{ startDate = dateFormatter.string(from: $0.date) }
        }
        
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
