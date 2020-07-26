//
//  SquadAPI.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/24.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Alamofire

enum SquadAPI {
    
    /// 添加小组
    /// name: 小组的名称
    /// avator: 头像
    /// remark: 备注
    case createSquad(name: String, avator: Data, remark: String)
    
    /// 创建一个群
    case createChannel(name: String, avatar: Data)
    
    /// 删除小组
//    case removeSquad()
    
    /// 小组详情
//    case querySquad()
    
    /// 修改小组信息
//    case updateSquad()
    
    /// 加入一个小组
//    case addMember()
    
    /// 从小组中退出
//    case removeMember()
    
    /// 查询在小组中的用户资料
//    case queryMemberInfo(userId: String)
    
    /// 修改小组与用户的关系
//    case updateMemberInfo()
}

extension SquadAPI: TargetType {
    
    var baseURL: URL {
        //115.159.208.16:8888/api
        return URL(string: "http://squad.wieed.com:8888/api/squad")!
    }
    
    var path: String {
        switch self {
        case .createSquad:
            return "add"
        case .createChannel:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createSquad:
            return .post
        case .createChannel:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case let .createSquad(name, avator, remark):
            let params = ["squadName": name, "logoImgBase64": avator.base64EncodedString(options: .lineLength64Characters), "createRemark": remark]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .createChannel:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
