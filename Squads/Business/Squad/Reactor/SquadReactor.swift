//
//  SquadReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

protocol SquadPrimaryKey { }

//struct SquadSqroll: SquadPrimaryKey {
//    var list: Array<FlickModel>
//}

struct SquadChannel: SquadPrimaryKey, Comparable {
    let sessionId: String
    var avatar: String?
    var title: String = ""
    var content: String = ""
    var unreadCount: Int = 0
    var timeStamp: Date
    
    var dateString: String {
        return timeStamp.chatTimeToString
    }
    
    static func == (lhs: SquadChannel, rhs: SquadChannel) -> Bool {
        return lhs.sessionId == rhs.sessionId
    }
    
    static func < (lhs: SquadChannel, rhs: SquadChannel) -> Bool {
        return lhs.timeStamp > rhs.timeStamp
    }
}

struct SquadPlaceholder: SquadPrimaryKey {
    let content: String
}

extension SquadActivity: SquadPrimaryKey {}
extension FlickModel: SquadPrimaryKey {}

class SquadReactor: Reactor {
    
    enum Action {
        // 刷新会话列表
        case refreshChannels(RefreshChannelsAction)
        // 刷新活动
        case refreshPage(RefreshsPageAction)
        // 请求squad详情
        case requestSquad(id: Int)
        // 获取登录状态
        case connectStatus(ConnectStatus)
    }
    
    enum Mutation {
        case setChannels(Array<SquadChannel>)
        case setPage(activitys: Array<SquadActivity>, flicks: Array<FlickModel>)
        case setSquadDetail(detail: SquadDetail, channels: Array<SquadChannel>)
        case setOneOrTheOther(loginStateDidExpired: Bool?, toast: String?)
        case setToast(String)
        case setLoading(Bool)
    }
    
    struct State {
        var repos = Array<Array<SquadPrimaryKey>>(repeating: [], count: 3)
        // 登录状态是否已过期
        var loginStateDidExpired: Bool = false
        // 是否处于加载中
        var isLoading: Bool?
        // 错误提示
        var toast: String?
        // 当前squad的资料
        var currentSquadDetail: SquadDetail?
    }
    
    var initialState = State()
    var provider = OnlineProvider<SquadAPI>()
    
    var loginStatusDidChanged: ReplaySubject<ConnectStatus>!
    // 当前置顶的squad的id
    var currentSquadId: Int
    
    init(currentSquadId: Int) {
        self.currentSquadId = currentSquadId
    }
    
    func transform(action: Observable<SquadReactor.Action>) -> Observable<SquadReactor.Action> {
        let status = loginStatusDidChanged.distinctUntilChanged().map{ Action.connectStatus($0) }
        return Observable.merge(action, status)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refreshChannels(let _action):
            let channels = currentState.repos[2] as! Array<SquadChannel>
            switch _action {
            case .update(let list):
                var newChannels = Array<SquadChannel>()
                for channel in channels {
                    if let conversation = list.first(where: { $0.groupID == channel.sessionId }), let lastMessage = conversation.lastMessage, lastMessage.msgID != nil {
                        let message = MessageElem(timMessage: lastMessage)
                        var newChannel = channel
                        newChannel.timeStamp = message.sentDate
                        newChannel.content = message.description
                        newChannel.unreadCount = Int(conversation.unreadCount)
                        newChannels.append(newChannel)
                    } else {
                        newChannels.append(channel)
                    }
                }
                return Observable.just(.setChannels(newChannels.sorted()))
            case .insert(let list):
                
                var otherChannels = Array<SquadChannel>()
                for conversation in list {
                    let isContains = channels.contains(where: { $0.sessionId == conversation.groupID })
                    if !isContains {
                        
                        var timeStamp: Date = Date.distantFuture
                        var content: String = ""
                        // 创建完群后生成的会话会包括一条空的message, 所以要根据msgID过滤掉
                        if let lastMessage = conversation.lastMessage, lastMessage.msgID != nil {
                            let message = MessageElem(timMessage: lastMessage)
                            timeStamp = message.sentDate
                            content = message.description
                        }
                        let channel = SquadChannel(sessionId: conversation.groupID, avatar: conversation.faceUrl, title: conversation.showName, content: content, unreadCount: Int(conversation.unreadCount), timeStamp: timeStamp)
                        otherChannels.append(channel)
                    }
                }
                return Observable.just(.setChannels((channels + otherChannels).sorted()))
            }
        case .refreshPage(let _action):
            switch _action {
            case .network:
                
                let acitivityObservable: Observable<Result<[SquadActivity], GeneralError>> = provider.request(target: .queryActivities(squadId: currentSquadId), model: Array<SquadActivity>.self, atKeyPath: .data).asObservable()
                
                let flickObservable: Observable<Result<GeneralModel.List<FlickModel>, GeneralError>> = provider.request(target: .getPageListWithFlick(pageIndex: 1, pageSize: 1, keyword: ""), model: GeneralModel.List<FlickModel>.self, atKeyPath: .data).asObservable()
                
                return Observable.zip(acitivityObservable, flickObservable).map { (aR, fR) in
                    switch (aR, fR) {
                    case (.success(let aList), .success(let fList)):
                        return .setPage(activitys: aList, flicks: fList.records)
                    case (.success(let aList), .failure):
                        return .setPage(activitys: aList, flicks: [])
                    case (.failure, .success(let fList)):
                        return .setPage(activitys: [], flicks: fList.records)
                    case (.failure, .failure):
                        return .setPage(activitys: [], flicks: [])
                    }
                }
                //setPage
            case .cache:
                return .empty()
            }
        
        case .requestSquad(let id):
            return self.querySquad(id: id).do(onNext: { [unowned self] mutation in
                // 切换squad成功后, 将currentSquadId更新为最新的squadId
                guard case .setSquadDetail = mutation else { return }
                self.currentSquadId = id
            })
        case .connectStatus(let status):
            /// 检查登录状态
            guard let user = User.currentUser() else {
                return .just(.setOneOrTheOther(loginStateDidExpired: true, toast: nil))
            }
            
            // 更加连接状态, 做出相应处理
            switch status {
            case .onConnectFailed(let s):
                return .just(.setToast(s))
            case .onKickedOffline, .onUserSigExpired:
                return .just(.setOneOrTheOther(loginStateDidExpired: true, toast: nil))
            default:
                break
            }
            
            return checkoutLoginStatus(userId: String(user.id)).flatMap { [unowned self] result -> Observable<Mutation> in
                switch result {
                case .success:
                    let id = self.currentSquadId
                    return self.querySquad(id: id)
                case .failure:
                    return Observable.just(.setOneOrTheOther(loginStateDidExpired: true, toast: nil))
                }
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let s):
            state.isLoading = s
        case .setChannels(let channelds):
            state.isLoading = false
            state.repos[2] = channelds
        case let .setPage(activities, flicks):
            if activities.isEmpty {
                state.repos[1] = [SquadPlaceholder(content: "No activities currently planned. Create one!")]
            } else {
                state.repos[1] = activities
            }
            if flicks.isEmpty {
                state.repos[0] = [SquadPlaceholder(content: "No flicks currently planned. ")]
            } else {
                state.repos[0] = flicks
            }
        case let .setOneOrTheOther(loginStateDidExpired, toast):
            state.isLoading = false
            if toast != nil {
                state.toast = toast
            } else {
                state.loginStateDidExpired = loginStateDidExpired!
            }
        case .setToast(let str):
            state.isLoading = false
            state.toast = str
        case let .setSquadDetail(detail, channelds):
            state.isLoading = false
            state.repos[2] = channelds
            detail.activities.flatMap {
                if $0.isEmpty {
                    state.repos[1] = [SquadPlaceholder(content: "No activities currently planned. Create one!")]
                } else {
                    state.repos[1] = $0
                }
            }
            detail.flicks.flatMap {
                if $0.isEmpty {
                    state.repos[0] = [SquadPlaceholder(content: "No flicks currently planned. ")]
                } else {
                    state.repos[0] = $0
                }
            }
            state.currentSquadDetail = detail
        }
        return state
    }
    
    // 根据squadId查询详情, 并绑定到mutation上
    private func querySquad(id: Int) -> Observable<Mutation> {
        return provider
            .request(target: .querySquad(id: id, setTop: true), model: SquadDetail.self, atKeyPath: .data)
            .asObservable()
            .flatMap { [unowned self] result -> Observable<Result<SquadDetail, GeneralError>> in
                switch result {
                case .success(let detail):
                    // 根据详情, 去查询当前squad下存在的所有channel, 后期开发可以只使用一个接口, 现在需要查三次浪费资源
                    let channedl: Observable<Result<SquadDetail, GeneralError>> = self.provider.request(target: .getSquadChannel(squadId: detail.id), model: Array<CreateChannel>.self, atKeyPath: .data).asObservable().map {
                        switch $0 {
                        case .success(let list):
                            return .success(detail.addChannels(list))
                        case .failure(let error):
                            return .failure(error)
                        }
                    }
                    
                    let activities: Observable<Result<SquadDetail, GeneralError>> = self.provider.request(target: .queryActivities(squadId: detail.id), model: Array<SquadActivity>.self, atKeyPath: .data).asObservable().map {
                        switch $0 {
                        case .success(let list):
                            return .success(detail.addActivities(list))
                        case .failure(let error):
                            return .failure(error)
                        }
                    }
                    
                    let flicks: Observable<Result<SquadDetail, GeneralError>> = self.provider.request(target: .getPageListWithFlick(pageIndex: 1, pageSize: 1, keyword: ""), model: GeneralModel.List<FlickModel>.self, atKeyPath: .data).asObservable().map {
                        switch $0 {
                        case .success(let page):
                            return .success(detail.addFlicks(page.records))
                        case .failure(let error):
                            return .failure(error)
                        }
                    }
                    
                    return channedl.concat(activities).concat(flicks)
                    
                case .failure(let error):
                    return Observable.just(.failure(error))
                }
            }
            .flatMap { [unowned self] result -> Observable<Result<(SquadDetail, Array<SquadChannel>), GeneralError>> in
                switch result {
                case .success(let detail):
                    // 通过squad中的channel列表, 去IM服务器查询这些群的信息
                    let groupIds = detail.channels?.map{ String($0.id) } ?? []
                    return self.queryGroupsFromTIM(groupIds: groupIds).map{ .success((detail, $0)) }
                case .failure(let error):
                    return Observable.just(.failure(error))
                }
            }
            .map { (result) -> Mutation in
                switch result {
                case let .success(detail, channels):
                    return .setSquadDetail(detail: detail, channels: channels)
                case .failure(let error):
                    if case .loginStatusDidExpired = error {
                        return .setOneOrTheOther(loginStateDidExpired: true, toast: nil)
                    } else  {
                        return .setOneOrTheOther(loginStateDidExpired: nil, toast: error.message)
                    }
                }
            }
            .startWith(.setLoading(true))
    }
    
    /// 从TIM中查询我所有的群组信息
    /// - Parameter groupIds: 群组id列表
    private func queryGroupsFromTIM(groupIds: Array<String>) -> Observable<Array<SquadChannel>> {
        
        guard !groupIds.isEmpty else { return Observable.just([]) }
        
        let joinGroups = Observable<Array<V2TIMGroupInfo>>.create { (observer) -> Disposable in
            V2TIMManager.sharedInstance()?.getJoinedGroupList({ (list) in
                observer.onNext(list ?? [])
                observer.onCompleted()
            }, fail: { (_, message) in
                observer.onNext([])
                observer.onCompleted()
            })
            return Disposables.create()
        }
        
        let conversationList = Observable<Array<V2TIMConversation>>.create { (observer) -> Disposable in
            V2TIMManager.sharedInstance()?.getConversationList(0, count: 100, succ: { (conversationList, nextSeq, isFinished) in
                observer.onNext(conversationList ?? [])
                observer.onCompleted()
            }, fail: { (code, message) in
                observer.onNext([])
                observer.onCompleted()
            })
            return Disposables.create()
        }
        
        return Observable.zip(joinGroups, conversationList).map { (groupList, conversationList) -> Array<SquadChannel> in
            var channelsList = Array<SquadChannel>()
            for i in 0..<groupList.count {
                let groupInfo = groupList[i]
                // 只处理当前squad下的群组信息
                guard groupIds.contains(groupInfo.groupID) else { continue }
                let conversation = conversationList.first(where: { $0.groupID == groupInfo.groupID })
                if let lastMessage = conversation?.lastMessage, lastMessage.msgID != nil {
                    // groupInfo.groupID 这里没有解包是没关系的, 只有当会话类型为group时, conversation才会有值
                    let message = MessageElem(timMessage: lastMessage)
                    let channel = SquadChannel(sessionId: groupInfo.groupID, avatar: groupInfo.faceURL, title: groupInfo.groupName, content: message.description, unreadCount: Int(conversation?.unreadCount ?? 0), timeStamp: message.sentDate)
                    channelsList.append(channel)
                } else {
                    // 获取群信息
                    let channel = SquadChannel(sessionId: groupInfo.groupID, avatar: groupInfo.faceURL, title: groupInfo.groupName, content: "", unreadCount: Int(conversation?.unreadCount ?? 0), timeStamp: Date.distantFuture)
                    channelsList.append(channel)
                }
            }
            return channelsList
        }
    }
    
    /// 检查登录状态
    private func checkoutLoginStatus(userId: String) -> Observable<Result<Void, GeneralError>>{
        return Observable.create { (observer) -> Disposable in
            
            if TIMManager.sharedInstance()?.getLoginStatus() == TIMLoginStatus.STATUS_LOGINED {
                observer.onNext(.success(()))
                observer.onCompleted()
                return Disposables.create()
            }
            
            TIMManager.sharedInstance()?.autoLogin(userId, succ: {
                observer.onNext(.success(()))
                observer.onCompleted()
            }, fail: { (code, message) in
                observer.onNext(.failure(.custom(message ?? "未知错误")))
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
    }
}
