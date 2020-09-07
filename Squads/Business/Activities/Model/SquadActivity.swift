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
    
    init(from decoder: Decoder) throws {
        id = try decoder.decode("id")
        accountId = try decoder.decode("accountId")
        squadId = try decoder.decode("squadId")
        title = try decoder.decode("title")
        activityType = try decoder.decode("activityType")
        activityStatus = try decoder.decode("activityStatus")
        startTime = try decoder.decodeIfPresent("startTime")
        endTime = try decoder.decodeIfPresent("endTime")
        let address = try decoder.decodeIfPresent("address", as: String.self)
        let latitude = try decoder.decodeIfPresent("latitude", as: String.self)
        let longitude = try decoder.decodeIfPresent("longitude", as: String.self)
        if let unwrappedAddress = address, let unwrappedLatitude = latitude, let unwrappedLongitude = longitude, !unwrappedLatitude.isEmpty, !unwrappedLongitude.isEmpty {
            position = SquadLocation(address: unwrappedAddress,
                                     longitude: unwrappedLongitude.asDouble(),
                                     latitude: unwrappedLatitude.asDouble())
        }
    }
    
    func encode(to encoder: Encoder) throws {
        try encoder.encode(id, for: "id")
        try encoder.encode(accountId, for: "accountId")
        try encoder.encode(squadId, for: "squadId")
        try encoder.encode(title, for: "title")
        try encoder.encode(activityType, for: "activityType")
        try encoder.encode(activityStatus, for: "activityStatus")
    }
    
    func isEquadTo(_ other: SquadActivity) -> Bool {
        return id == other.id
            && accountId == other.accountId
            && squadId == other.squadId
            && title == other.title
            && activityType == other.activityType
            && activityStatus == other.activityStatus
    }
    
    static func == (lhs: SquadActivity, rhs: SquadActivity) -> Bool {
        return lhs.id == rhs.id
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
