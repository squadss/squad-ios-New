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
    case createLinkBySquad(squadId: Int)
    
    // MARK: - 活动相关
    
    // 创建活动
    // type: 活动类型
    // squadId: 所属的小队
    // title: 标题
    // location: 定位, 可选参数 包含经纬度和地址
    // myTime: 我的时间 包含开始时间, 结束时间
    case createActivity(type: EventCategory, squadId: Int, title: String, location: SquadLocation?)
    
    // 删除活动, 权限只有活动发起人有
    case deleteActivity(activityId: Int)
    
    // 编辑活动
    // activityId: 活动id
    // title: 标题
    // setTime: 设置活动的时间段(此权限只有活动发起人才有)
    case setActivityInfo(activityId: Int, squadId: Int, title: String?, location: SquadLocation?,  setTime: TimePeriod?, status: ActivityStatus?)
    
    // 获取活动详情
    case queryActivityInfo(activityId: Int)
    
    // 获取活动分页列表
    case queryActivities(squadId: Int)
    
    // 加入活动
    // activityId: 活动id
    // myTime: 我的时间 包含开始时间, 结束时间
    case joinActivity(activityId: Int, myTime: Array<TimePeriod>?)
    
    // 退出活动
    case exitActivity(activityId: Int)
    
    // 获取已响应时间的用户列表 参与活动的人数最多也不超过20人, 所以暂时不用分页
    case getResponded(activityId: Int)
    
    // 获取还未选择时间的用户列表
    case getWaiting(activityId: Int)
    
    // 修改活动成员表
    case updateActivityMemberInfo(activityId: Int, myTime: Array<TimePeriod>)
    
    // 查看某个活动 GOING->1 / CAN'T MAKE IT -> -1 的人列表
    case queryMembersActivityGoingStatus(activityId: Int, isAccept: Bool)
    
    // 查看当前登录用户某个活动的 Going 状态
    case queryActivityGoingStatus(activityId: Int)
    
    // 用户修改 Going 状态
    case updateGoingStatus(activityId: Int, isAccept: Bool)
    
    //MARK: - Flick 相关
    
    // 添加小组, 媒体内容
    // mediaType: 媒体类型：1->图片；2->视频
    // media: 图片 Base64 的数组，或服务器返回路径数组
    // url: 链接地址
    case addMediaWithFlick(squadId: Int, mediaType: MediaType, media: Array<Data>, title: String, url: String)
    
    // 删除小组-媒体内容
    case deleteMediaWithFlick(id: Int)
    
    // 小组-媒体内容分页列表
    case getPageListWithFlick(pageIndex: Int, pageSize: Int, keyword: String)
    
    // 某条媒体内容详情
    case mediaDetailWithFlick(id: Int)
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
        case .createActivity:
            return "activity/add"
        case .deleteActivity(let activityId):
            return "activity/delete/\(activityId)"
        case .queryActivities(let squadId):
            return "activity/list/\(squadId)"
        case .setActivityInfo:
            return "activity/update"
        case .queryActivityInfo(let activityId):
            return "activity/info/\(activityId)"
        case .joinActivity:
            return "activityMember/add"
        case .exitActivity(let activityId):
            return "activityMember/delete/\(activityId)"
        case .getResponded(let activityId):
            return "activityMember/responded/\(activityId)"
        case .getWaiting(let activityId):
            return "activityMember/wating/\(activityId)"
        case .updateActivityMemberInfo:
            return "activityMember/update"
        case .updateGoingStatus:
            return "squadActivityGoing/update"
        case let .queryMembersActivityGoingStatus(activityId, isAccept):
            let status: Int = isAccept ? 1 : -1
            return "squadActivityGoing/memberList/\(activityId)/\(status)"
        case .queryActivityGoingStatus(let activityId):
            return "squadActivityGoing/status/\(activityId)"
        case .isAlreadyRegistered, .deleteInviteRecord, .inviteFriends:
            return ""
        case .getPageListWithFlick:
            return "squadMedia/getPageList"
        case .addMediaWithFlick:
            return "squadMedia/add"
        case .deleteMediaWithFlick(let id):
            return "squadMedia/delete/\(id)"
        case .mediaDetailWithFlick(let id):
            return "squadMedia/info/\(id)"
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
        case .deleteActivity, .exitActivity, .setActivityInfo, .createActivity, .queryActivities, .joinActivity, .getResponded, .getWaiting, .updateActivityMemberInfo, .updateGoingStatus, .queryMembersActivityGoingStatus:
            return .post
        case .queryActivityInfo, .queryActivityGoingStatus:
            return .get
        case .addMediaWithFlick, .getPageListWithFlick, .deleteMediaWithFlick:
            return .post
        case .mediaDetailWithFlick:
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
        case .getResponded:
            return """
            {
                "code": 200,
                "message": "",
                "data": [
                            {
                              "id": 0,
                              "accountId": 2,
                              "activityId": 6,
                              "nickname": "小明",
                              "headimgurl": "string",
                              "selectTime": "[{"startTime": 1597637876, "endTime": 1597652276}]",
                              "memberGoing": 0,
                              "createRemark": "string",
                              "gmtCreate": "2020-08-15T08:30:03.748Z",
                              "modifiedRemark": "string",
                              "gmtModified": "2020-08-15T08:30:03.748Z"
                            },
                            {
                              "id": 0,
                              "accountId": 1,
                              "activityId": 6,
                              "nickname": "小李",
                              "headimgurl": "string",
                              "selectTime": "[]",
                              "memberGoing": 0,
                              "createRemark": "string",
                              "gmtCreate": "2020-08-15T08:30:03.748Z",
                              "modifiedRemark": "string",
                              "gmtModified": "2020-08-15T08:30:03.748Z"
                            }
                        ]
            }
            """.data(using: .utf8)!
        case .getWaiting:
            return """
            {
                "code": 200,
                "message": "",
                "data": [
                            {
                              "id": 0,
                              "accountId": 3,
                              "activityId": 6,
                              "nickname": "string",
                              "headimgurl": "string",
                              "selectTime": "[]",
                              "memberGoing": 0,
                              "createRemark": "string",
                              "gmtCreate": "2020-08-15T08:30:03.748Z",
                              "modifiedRemark": "string",
                              "gmtModified": "2020-08-15T08:30:03.748Z"
                            },
                            {
                              "id": 0,
                              "accountId": 5,
                              "activityId": 6,
                              "nickname": "string",
                              "headimgurl": "string",
                              "selectTime": "[]",
                              "memberGoing": 0,
                              "createRemark": "string",
                              "gmtCreate": "2020-08-15T08:30:03.748Z",
                              "modifiedRemark": "string",
                              "gmtModified": "2020-08-15T08:30:03.748Z"
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
        case let .createLinkBySquad(squadId):
            return .requestParameters(parameters: [
                "squadId": squadId
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
        
        case let .createActivity(type, squadId, title, location):
            var params: [String: Any] = [
                "accountId": User.currentUser()!.id,
                "squadId": squadId,
                "title": title,
                "activityType": type.rawValue,
                "activityStatus": ActivityStatus.prepare.rawValue
            ]
            location.flatMap{
                params["address"] = $0.address
                params["latitude"] = $0.latitude
                params["longitude"] = $0.longitude
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .queryActivityInfo, .queryActivities:
            return .requestPlain
        case let .setActivityInfo(activityId, squadId, title, location, setTime, status):
           
            var params: [String: Any] = ["id": activityId, "squadId": squadId, "accountId": User.currentUser()!.id]
            
            title.flatMap {
                params["title"] = $0
            }
            
            setTime.flatMap {
                params["startTime"] = $0.beginning
                params["endTime"] = $0.end
            }
            
            status.flatMap {
                params["activityStatus"] = $0.rawValue
            }
                           
            location.flatMap{
                params["address"] = $0.address
                params["latitude"] = $0.latitude
                params["longitude"] = $0.longitude
            }
            
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .joinActivity(activityId, myTime):
            var params: [String: Any] = ["activityId": activityId]
            
            if let unwrappedMyTime = myTime, !unwrappedMyTime.isEmpty {
                let jsonString = unwrappedMyTime.toJSONString()?
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "\n", with: "")
                if let unwrappedJsonString = jsonString {
                    params["selectTime"] = unwrappedJsonString
                }
            }
            
            User.currentUser().flatMap {
                params["accountId"] = $0.id
                params["nickname"] = $0.nickname
                params["headimgurl"] = $0.avatar
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .exitActivity, .deleteActivity, .getResponded, .getWaiting:
            return .requestPlain
        case let .updateActivityMemberInfo(activityId, myTime):
            var params: [String: Any] = ["activityId": activityId]
            // 外部需要保证myTime数组个数不能为空
            params["selectTime"] = myTime.toJSONString()
            User.currentUser().flatMap {
                params["accountId"] = $0.id
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .updateGoingStatus(activityId, isAccept):
            var params: [String: Any] = ["activityId": activityId, "going": isAccept]
            User.currentUser().flatMap { params["accountId"] = $0.id }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .queryMembersActivityGoingStatus, .queryActivityGoingStatus:
            return .requestPlain
        case let .addMediaWithFlick(squadId, mediaType, media, title, url):
            return .requestParameters(parameters: [
                "squadId": squadId,
                "accountId": User.currentUser()!.id,
                "title": title,
                "url": url,
                "mediaType": mediaType.rawValue,
                "media": media.map{ $0.base64EncodedString(options: .lineLength64Characters) }
            ], encoding: JSONEncoding.default)
        case let .getPageListWithFlick(pageIndex, pageSize, keyword):
            return .requestParameters(parameters: [
                "keyword": keyword,
                "pageIndex": pageIndex,
                "pageSize": pageSize,
                "pageSorts": [["column": "gmtCreate", "asc": false]]
            ], encoding: JSONEncoding.default)
        case .deleteMediaWithFlick, .mediaDetailWithFlick:
            return .requestPlain
        //FIXME: - 测试接口
        case .isAlreadyRegistered, .deleteInviteRecord, .inviteFriends:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
