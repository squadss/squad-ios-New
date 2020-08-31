//
//  SquadDetail.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/26.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation

struct SquadDetail: Codable {
    let id: Int
    let squadName: String
    let logoPath: String
    let createRemark: String
    let squadCode: String
    
    // 有得接口不返回此条数据
    var channels: Array<CreateChannel>?
    var activities: Array<SquadActivity>?
    var flicks: Array<FlickModel>?
    // 存在更多的, 首页只允许存在两条数据, 所以根据此值判断是否有更多活动
    var hasMoreActivities: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case squadName
        case logoPath
        case createRemark
        case squadCode
        case channels
    }
    
    init(from decoder: Decoder) throws {
        id = try decoder.decode("id")
        squadName = try decoder.decode("squadName")
        logoPath = try decoder.decode("logoPath")
        createRemark = try decoder.decode("createRemark")
        squadCode = try decoder.decode("squadCode")
        channels = try decoder.decodeIfPresent("channels")
    }
    
    func encode(to encoder: Encoder) throws {
        try encoder.encode(id, for: "id")
        try encoder.encode(squadName, for: "squadName")
        try encoder.encode(logoPath, for: "logoPath")
        try encoder.encode(createRemark, for: "createRemark")
        try encoder.encode(squadCode, for: "squadCode")
    }
}
