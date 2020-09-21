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
        squadId = try decoder.decode("squadId")
        url = try decoder.decode("url")
        mediaType = try decoder.decode("mediaType")
        dateString = try decoder.decode("gmtCreate")
        // gmtCreate 服务器返回的日期格式为北京时区, 需要转为时间戳, 再转为本地时区
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 8 * 60 * 60)
        let date = dateFormatter.date(from: dateString)
        if let unwrappedNewDate = date {
            dateFormatter.timeZone = .current
            dateFormatter.calendar = .current
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.locale = .current
            dateString = dateFormatter.string(from: unwrappedNewDate.date)
        }
    }
}
