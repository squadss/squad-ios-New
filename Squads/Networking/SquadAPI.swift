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
    
    /// 获取小组详情
    case querySquad(id: String, setTop: Bool)
    
    /// 获取当前置顶的squad
    case quardTopSquad
    
    /// 批量通过手机号查询用户是否已被注册
    case isAlreadyRegistered(phoneList: Array<String>)
    
    /// 查询全部的好友
    case queryAllFriends
    
    /// 批量邀请好友加入squad
    case inviteFriends(squadId: String, userIds: Array<String>)
    
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
        case .createChannel, .querySquad, .quardTopSquad, .isAlreadyRegistered, .queryAllFriends, .inviteFriends:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createSquad:
            return .post
        case .createChannel:
            return .post
        //FIXME: - 测试接口
        case .querySquad, .quardTopSquad, .isAlreadyRegistered, .queryAllFriends, .inviteFriends: return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .querySquad(let id):
        return """
            {
                "code": 200,
                "message": "",
                "data": {
                        "id": \(id),
                        "squadName": "测试小组",
                        "logoPath": "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg",
                        "createRemark": ""
                        }
            }
            """.data(using: .utf8)!
        case .quardTopSquad:
        return """
            {
                "code": 200,
                "message": "",
                "data": {
                        "id": 1,
                        "squadName": "测试小组",
                        "logoPath": "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg",
                        "createRemark": ""
                        }
            }
            """.data(using: .utf8)!
        case .isAlreadyRegistered:
            return """
                {
                    "code": 200,
                    "message": "",
                    "data": [
                                {
                                    "id": 122,
                                    "nickname": "小张",
                                    "avatar": "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg",
                                    "gender": "F"
                                    "username": "xiaozhagn"
                                },
                                {
                                    "id": 123,
                                    "nickname": "小李",
                                    "avatar": "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg",
                                    "gender": "F"
                                    "username": "xiaozhagn"
                                }
                            ]
                }
                """.data(using: .utf8)!
        case .queryAllFriends:
            return """
                {
                    "code": 200,
                    "message": "",
                    "data": [
                                {
                                    "id": 122,
                                    "nickname": "小张",
                                    "avatar": "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg",
                                    "gender": "F"
                                    "username": "xiaozhagn"
                                },
                                {
                                    "id": 123,
                                    "nickname": "小李",
                                    "avatar": "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg",
                                    "gender": "F"
                                    "username": "xiaozhagn"
                                }
                            ]
                }
                """.data(using: .utf8)!
        case .inviteFriends:
            return """
            {
            "code": 200,
            "message": "邀请成功",
            "data": null
            }
            """.data(using: .utf8)!
        default:
            return Data()
        }
    }
    
    var task: Task {
        switch self {
        case let .createSquad(name, avator, remark):
            let params = ["squadName": name, "logoImgBase64": avator.base64EncodedString(options: .lineLength64Characters), "createRemark": remark]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        //FIXME: - 测试接口
        case .createChannel, .querySquad, .quardTopSquad, .isAlreadyRegistered, .queryAllFriends, .inviteFriends:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
