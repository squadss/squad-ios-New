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
    
    // 本地添加数据, 不是服务器返回的数据, 后期可以将该数据放到接口中返回
    var channels: Array<CreateChannel>?
    
    enum CodingKeys: String, CodingKey {
        case id
        case squadName
        case logoPath
        case createRemark
        case squadCode
    }
    
    init(from decoder: Decoder) throws {
        id = try decoder.decode("id")
        squadName = try decoder.decode("squadName")
        logoPath = try decoder.decode("logoPath")
        createRemark = try decoder.decode("createRemark")
        squadCode = try decoder.decode("squadCode")
    }
    
    func addChannels(_ list: Array<CreateChannel>) -> SquadDetail {
        var model = self
        model.channels = list
        return model
    }
}
