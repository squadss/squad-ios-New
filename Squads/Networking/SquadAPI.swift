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
    case querySquad(id: Int, setTop: Bool)
    
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
    
    /// 批量邀请好友加入squad(接口暂不支持)
    case inviteFriends(squadId: Int, userIds: Array<String>)
    
    /// 单一邀请好友加入squad
    case inviteFriend(squadId: Int, userId: Int)
    
    /// 我的被邀请记录
    case myInviteRecords
    
    /// 删除某项记录
    case deleteInviteRecord(id: Int)
    
    /// 查询指定squad下的所有成员
    case getMembersFromSquad(squadId: Int)
    
    /// 查询我加入的所有的squad
    case queryAllSquads
    
    /// 根据邀请码获取对应的 squad
    case querySquadByInviteCode(code: String)
    
    /// 根据squadid生成邀请链接
    case createLinkBySquad(squadId: Int, nationCode: String, phoneNumber: String)
}

extension SquadAPI: TargetType {
    
    var baseURL: URL {
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
        case .quardTopSquad:
            // 后面需要再服务器新增一个接口, 专门去记录一下, 如果用户更换设备登录的话, 就会出现问题
            let id = UserDefaults.standard.topSquad!
            return "squad/info/\(id)"
        case .updateSquad:
            return "squad/update"
        case .querySquadByInviteCode(let squadCode):
            return "squad/info/invitecode/\(squadCode)"
        case .createLinkBySquad:
            return "squad/inviteText"
        case .getMembersFromSquad:
            return "squad/member/getBySquadId"
        case .queryAllSquads:
            return "squad/getByLoginUser"
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
        case .queryAllFriends:
            return "friend/getByLoginUser"
        case .inviteFriend:
            return "friend/invite"
        case .myInviteRecords:
            let id = User.currentUser()!.id
            return "friend/invitee/\(id)"
        case .isAlreadyRegistered, .deleteInviteRecord, .inviteFriends:
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
             .updateChannel,
             .createLinkBySquad,
             .inviteFriends,
             .inviteFriend:
            return .post
            
        case .querySquad,
             .quardTopSquad,
             .queryMemberInfo,
             .getSquadChannel,
             .queryChannel,
             .getMembersFromSquad,
             .queryAllSquads,
             .querySquadByInviteCode,
             .queryAllFriends,
             .myInviteRecords:
            return .get
        //FIXME: - 测试接口
        case .isAlreadyRegistered, .deleteInviteRecord: return .get
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
        default:
            return Data()
        }
    }
    
    var task: Task {
        switch self {
        case let .createSquad(name, avator, remark):
            let params = ["squadName": name, "logoImgBase64": avator.base64EncodedString(options: .lineLength64Characters), "createRemark": remark]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .deleteSquad, .querySquad, .quardTopSquad, .querySquadByInviteCode, .queryAllSquads, .queryAllFriends, .myInviteRecords:
            return .requestPlain

        case let .updateSquad(name, avator, remark):
            let params = ["squadName": name, "logoImgBase64": avator.base64EncodedString(options: .lineLength64Characters), "createRemark": remark]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .createLinkBySquad(squadId, nationCode, phoneNumber):
            return .requestParameters(parameters: [
                "squadId": squadId,
                "nationCode": nationCode,
                "phoneNumber": phoneNumber,
                "purePhoneNumber": nationCode + phoneNumber
            ], encoding: JSONEncoding.default)
        case .getMembersFromSquad(let id):
            return .requestParameters(parameters: ["squadId": id], encoding: URLEncoding.default)
            
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
        case let .inviteFriend(squadId, userId):
            guard let accountId = User.currentUser()?.id else { return .requestPlain }
            let params = ["inviterAccountId": accountId,
                          "inviteeAccountId": userId,
                          "inviteSquadId": squadId,
                          "inviteStatus": Invitation.Status.doing.rawValue]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        //FIXME: - 测试接口
        case .isAlreadyRegistered, .deleteInviteRecord, .inviteFriends:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
