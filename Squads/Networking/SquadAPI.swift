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
    
    /// 获取小组详情
    case querySquad(id: String, setTop: Bool)
    
    /// 删除Squad
    case deleteSquad(id: String)
    
    /// 更新Squad
    case updateSquad(name: String, avator: Data, remark: String)
    
    /// 获取当前置顶的squad
    case quardTopSquad
    
    /// 加入一个小组
    case addMember(squadId: Int, accountId: Int)
    
    /// 从小组中退出
    case removeMember(squadId: Int)
    
    /// 查询在小组中的用户资料
    case queryMemberInfo(squadId: Int)
    
    /// 修改小组与用户的关系
    case updateMemberInfo(squadId: Int, accountId: Int)
    
    /// 创建一个频道
    case createChannel(squadId: Int, name: String, avatar: Data, ownerAccountId: Int)
    
    /// 删除一个频道
    case deleteChannel(id: Int)
    
    /// 查询一个频道
    case queryChannel(id: Int)
    
    /// 更新一个频道
    case updateChannel(squadId: Int, name: String, avatar: Data, ownerAccountId: Int)
    
    /// 查询指定squad下的所有频道
    case getSquadChannel(squadId: Int)
    
    /// 批量通过手机号查询用户是否已被注册
    case isAlreadyRegistered(phoneList: Array<String>)
    
    /// 查询当前用户全部的好友
    case queryAllFriends
    
    /// 批量邀请好友加入squad
    case inviteFriends(squadId: String, userIds: Array<String>)
    
    /// 我的被邀请记录 需要分页
    case myInviteRecords(page: Int, size: Int)
    
    /// 删除某项记录
    case deleteInviteRecord(id: Int)
    
    /// 查询指定squad下的所有成员
    case getMembersFromSquad(squadId: Int)
    
    /// 查询我加入的所有的squad
    case queryAllSquads
}

extension SquadAPI: TargetType {
    
    var baseURL: URL {
        //115.159.208.16:8888/api
        return URL(string: "http://squad.wieed.com:8888/api/")!
    }
    
    var path: String {
        switch self {
        case .createSquad:
            return "squad/add"
        case .deleteSquad(let id):
            return "squad/delete/\(id)"
        case .querySquad(let id, _):
            return "squad/info/\(id)"
        case .updateSquad:
            return "squad/update"
        case .addMember:
            return "squad/member/add"
        case .removeMember(let id):
            return "squad/member/delete/\(id)"
        case .updateMemberInfo:
            return "squad/member/update"
        case .queryMemberInfo(let id):
            return "squad/member/info/\(id)"
        case .getSquadChannel:
            return "channel/getSquadChannel"
        case .deleteChannel(let id):
            return "channel/delete/\(id)"
        case .createChannel:
            return "channel/add"
        case .updateChannel:
            return "channel/update"
        case .queryChannel(let id):
            return "channel/info/\(id)"
            
        case .quardTopSquad, .isAlreadyRegistered, .queryAllFriends, .inviteFriends, .myInviteRecords, .getMembersFromSquad, .queryAllSquads, .deleteInviteRecord:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createSquad,
             .deleteSquad,
             .updateSquad,
             .addMember,
             .removeMember,
             .updateMemberInfo,
             .createChannel,
             .deleteChannel,
             .updateChannel:
            return .post
            
        case .querySquad,
             .queryMemberInfo,
             .getSquadChannel,
             .queryChannel:
            return .get
        //FIXME: - 测试接口
        case .quardTopSquad, .isAlreadyRegistered, .queryAllFriends, .inviteFriends, .getMembersFromSquad, .queryAllSquads, .myInviteRecords, .deleteInviteRecord: return .get
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
        case .myInviteRecords:
            return """
            {
            "code": 200,
            "message": "邀请成功",
            "data": {
                    "records": [
                        {
                            "inviter": "",
                            "receiver": "",
                            "squadId": "",
                            "squadName": "",
                            "squadAvatar": "",
                            "content": "",
                            "status": 10
                        },
                        {
                            "inviter": "",
                            "receiver": "",
                            "squadId": "",
                            "squadName": "Box Squad",
                            "squadAvatar": "",
                            "content": "",
                            "status": 10
                        },
                        {
                            "inviter": "",
                            "receiver": "",
                            "squadId": "",
                            "squadName": "Jimmy Squad",
                            "squadAvatar": "",
                            "content": "",
                            "status": 10
                        },
                        {
                            "inviter": "",
                            "receiver": "",
                            "squadId": "",
                            "squadName": "Tom Squad",
                            "squadAvatar": "",
                            "content": "",
                            "status": 10
                        }
                    ]
                    "total": 10
                    "size": 10
                    "current": 1
                }
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
        case .deleteSquad, .querySquad:
            return .requestPlain
        case let .updateSquad(name, avator, remark):
            let params = ["squadName": name, "logoImgBase64": avator.base64EncodedString(options: .lineLength64Characters), "createRemark": remark]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case let .addMember(squadId, accountId):
            return .requestParameters(parameters: [
                "squadId": squadId,
                "accountId": accountId
            ], encoding: JSONEncoding.default)
        case let .updateMemberInfo(squadId, accountId):
            return .requestParameters(parameters: [
                "squadId": squadId,
                "accountId": accountId
            ], encoding: JSONEncoding.default)
        case  .removeMember, .queryMemberInfo:
            return .requestPlain
            
        case let .createChannel(squadId, name, avatar, ownerAccountId):
            return .requestParameters(parameters: [
                "squadId": squadId,
                "ownerAccountId": ownerAccountId,
                "channelName": name,
                "headImgUrl": avatar.base64EncodedString(options: .lineLength64Characters)
            ], encoding: JSONEncoding.default)
        case let .updateChannel(squadId, name, avatar, ownerAccountId):
            return .requestParameters(parameters: [
                "squadId": squadId,
                "ownerAccountId": ownerAccountId,
                "channelName": name,
                "headImgUrl": avatar.base64EncodedString(options: .lineLength64Characters)
            ], encoding: JSONEncoding.default)
        case .queryChannel, .deleteChannel:
            return .requestPlain
        case .getSquadChannel(let squadId):
            let params = ["squadId": squadId]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        //FIXME: - 测试接口
        case .quardTopSquad, .isAlreadyRegistered, .queryAllFriends, .inviteFriends, .getMembersFromSquad, .queryAllSquads, .myInviteRecords, .deleteInviteRecord:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
