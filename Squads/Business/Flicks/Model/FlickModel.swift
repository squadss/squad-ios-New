//
//  FlickModel.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/10.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation

enum MediaType: Int, Codable {
    case priture = 1
    case video = 2
}

struct FlickModel: Decodable {
    var pirtureList: Array<URL>
    var content: String
    var dateString: String
    var squadId: Int
    var url: String = ""
    var mediaType: MediaType
    
    // 服务器没有设置该字段
    var likeNum: String?
    var commonNum: String?
    
    init(from decoder: Decoder) throws {
        pirtureList = try decoder.decode("filePaths")
        content = try decoder.decode("title")
        dateString = try decoder.decode("gmtCreate")
        squadId = try decoder.decode("squadId")
        url = try decoder.decode("url")
        mediaType = try decoder.decode("mediaType")
    }
}
