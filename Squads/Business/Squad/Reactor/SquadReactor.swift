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

struct SquadSqroll: SquadPrimaryKey {
    var list: Array<String>
}

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
        return lhs.timeStamp < rhs.timeStamp
    }
}

struct SquadActivity: SquadPrimaryKey {
    
}

struct SquadPlaceholder: SquadPrimaryKey {
    let content: String = "No activities currently planned. Create one!"
}

class SquadReactor: Reactor {
    
    enum Action {
        // 刷新会话列表
        case refreshChannels(RefreshChannelsAction)
        // 请求squad详情
        case requestSquad(id: String)
        // 获取登录状态
        case connectStatus(ConnectStatus)
    }
    
    enum Mutation {
        case setChannels(Array<SquadChannel>)
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
        // 当前置顶的squad的id
        var currentSquadId: Int
    }
    
    var initialState: State
    var provider = OnlineProvider<SquadAPI>()
    
    var loginStatusDidChanged: PublishRelay<ConnectStatus>!
    
    init(currentSquadId: Int) {
        initialState = State(currentSquadId: currentSquadId)
        initialState.repos[0] = [SquadSqroll(list: ["http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg","http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg", "http://image.biaobaiju.com/uploads/20180803/23/1533309822-GCcDphRmqw.jpg"])]
        initialState.repos[1] = [SquadActivity(), SquadActivity()]
    }
    
    func transform(action: Observable<SquadReactor.Action>) -> Observable<SquadReactor.Action> {
        return Observable.merge(action, loginStatusDidChanged.map{ Action.connectStatus($0) })
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refreshChannels(let action):
            let channels = currentState.repos[2] as! Array<SquadChannel>
            switch action {
            case .update(let list):
                var newChannels = Array<SquadChannel>()
                for channel in channels {
                    if let conversation = list.first(where: { $0.groupID == channel.sessionId }), let lastMessage = conversation.lastMessage {
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
                        if let lastMessage = conversation.lastMessage {
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
        case .requestSquad(let id):
            return provider.request(target: .querySquad(id: id, setTop: true), model: SquadDetail.self, atKeyPath: .data)
                .asObservable()
                .flatMap { result -> Observable<Result<SquadDetail, GeneralError>> in
                    switch result {
                    case .success(let detail):
                        return self.provider.request(target: .getSquadChannel(squadId: detail.id), model: Array<CreateChannel>.self, atKeyPath: .data).asObservable().map {
                            switch $0 {
                            case .success(let list):
                                return .success(detail.addChannels(list))
                            case .failure(let error):
                                return .failure(error)
                            }
                        }
                    case .failure(let error):
                        return Observable.just(.failure(error))
                    }
                }
                .flatMap { [unowned self] result -> Observable<Result<Array<SquadChannel>, GeneralError>> in
                    switch result {
                    case .success(let detail):
                        // 通过squad中的列表, 去IM服务器查询这些群的信息
                        let groupIds = detail.channels?.map{ String($0.id) } ?? []
                        return self.queryGroupsFromTIM(groupIds: groupIds).map{ .success($0) }
                    case .failure(let error):
                        return Observable.just(.failure(error))
                    }
                }
                .map { (result) -> Mutation in
                    switch result {
                    case .success(let channelsList):
                        return .setChannels(channelsList)
                    case .failure(let error):
                        if case .loginStatusDidExpired = error {
                            return .setOneOrTheOther(loginStateDidExpired: true, toast: nil)
                        } else {
                            return .setOneOrTheOther(loginStateDidExpired: nil, toast: error.message)
                        }
                    }
                }
                .startWith(.setLoading(true))
        case .connectStatus(let status):
            /// 检查登录状态
            guard let user = User.currentUser(), case .onConnectSuccess = status else {
                return .just(.setOneOrTheOther(loginStateDidExpired: true, toast: nil))
            }
            return checkoutLoginStatus(userId: String(user.id))
                .map { result -> Result<Void, GeneralError> in
                    switch result {
                    case .success: return .success(())
                    case .failure: return .failure(.loginStatusDidExpired)
                    }
                }
                .flatMap { [unowned self] result -> Single<Result<SquadDetail, GeneralError>> in
                    // 查询当前置顶的squad详情, 然后拿到该squad下的群列表
                    switch result {
                    case .success:
                        return self.provider.request(target: .quardTopSquad, model: SquadDetail.self, atKeyPath: .data)
                    case .failure(let error):
                        return Single.just(.failure(error))
                    }
                }
                .flatMap { result -> Observable<Result<SquadDetail, GeneralError>> in
                    switch result {
                    case .success(let detail):
                        return self.provider.request(target: .getSquadChannel(squadId: detail.id), model: Array<CreateChannel>.self, atKeyPath: .data).asObservable().map {
                            switch $0 {
                            case .success(let list):
                                return .success(detail.addChannels(list))
                            case .failure(let error):
                                return .failure(error)
                            }
                        }
                    case .failure(let error):
                        return Observable.just(.failure(error))
                    }
                }
                .flatMap { [unowned self] result -> Observable<Result<Array<SquadChannel>, GeneralError>> in
                    switch result {
                    case .success(let detail):
                        // 通过squad中的列表, 去IM服务器查询这些群的信息
                        let groupIds = detail.channels?.map{ String($0.id) } ?? []
                        return self.queryGroupsFromTIM(groupIds: groupIds).map{ .success($0) }
                    case .failure(let error):
                        return Observable.just(.failure(error))
                    }
                }
                .map { (result) -> Mutation in
                    switch result {
                    case .success(let channelsList):
                        return .setChannels(channelsList)
                    case .failure(let error):
                        if case .loginStatusDidExpired = error {
                            return .setOneOrTheOther(loginStateDidExpired: true, toast: nil)
                        } else {
                            return .setOneOrTheOther(loginStateDidExpired: nil, toast: error.message)
                        }
                    }
                }
                .startWith(.setLoading(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let s):
            state.isLoading = s
        case .setChannels(let list):
            state.isLoading = false
            state.repos[2] = list
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
        }
        return state
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
                let conversation = conversationList.first(where: { $0.groupID == groupInfo.groupID })
                if let lastMessage = conversation?.lastMessage {
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
