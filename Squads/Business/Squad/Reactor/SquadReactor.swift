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
import ImSDK

protocol SquadPrimaryKey { }

struct SquadSqroll: SquadPrimaryKey {
    var list: Array<String>
}

struct SquadChannel: SquadPrimaryKey {
    let sessionId: String
    var avatar: String?
    var title: String = ""
    var content: String = ""
    var unreadCount: Int = 0
    var dateString: String = ""
}

struct SquadActivity: SquadPrimaryKey {
    
}

struct SquadPlaceholder: SquadPrimaryKey {
    let content: String = "No activities currently planned. Create one!"
}

class SquadReactor: Reactor {
    
    enum Action {
        // 刷新会话列表
        case refreshChannels
        // 初始化SDK
        case initialSDK
        // 请求squad详情
        case requestSquad(id: String)
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
        var currentSquadId: String
    }
    
    var initialState: State
    var provider = OnlineProvider<SquadAPI>(stubClosure: { (api)  in
        switch api {
        case .querySquad, .quardTopSquad: return .delayed(seconds: 1)
        default: return .never
        }
    })
    
    init(currentSquadId: String) {
        initialState = State(currentSquadId: currentSquadId)
        
        initialState.repos[0] = [SquadSqroll(list: ["http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg","http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg", "http://image.biaobaiju.com/uploads/20180803/23/1533309822-GCcDphRmqw.jpg"])]
        initialState.repos[1] = [SquadActivity(), SquadActivity()]
        initialState.repos[2] = [SquadChannel(sessionId: "1", avatar: "http://image.biaobaiju.com/uploads/20180803/23/1533309822-GCcDphRmqw.jpg", title: "Main", content: "Danny: Yeah I Know", unreadCount: 1, dateString: "10:10 PM"),
                                 SquadChannel(sessionId: "1", avatar: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg", title: "Main", content: "Danny: Yeah I Know", unreadCount: 1, dateString: "10:10 PM")]
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refreshChannels:
            //TODO: - 刷新数据
            return .never()
        case .requestSquad(let id):
            return provider.request(target: .querySquad(id: id, setTop: true), model: SquadDetail.self, atKeyPath: .data)
                .asObservable()
                .flatMap { [unowned self] result -> Observable<Result<Array<SquadChannel>, GeneralError>> in
                    switch result {
                    case .success(let detail):
                        // 通过squad中的列表, 去IM服务器查询这些群的信息
                        return self.queryGroupsFromTIM(groupIds: ["123", "234"])
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
        case .initialSDK:
            guard let user = User.currentUser() else {
                return .just(.setOneOrTheOther(loginStateDidExpired: true, toast: nil))
            }
            return checkoutLoginStatus(userId: user.username)
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
                .flatMap { [unowned self] result -> Observable<Result<Array<SquadChannel>, GeneralError>> in
                    switch result {
                    case .success(let detail):
                        // 通过squad中的列表, 去IM服务器查询这些群的信息
                        return self.queryGroupsFromTIM(groupIds: ["123", "234"])
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
    func queryGroupsFromTIM(groupIds: Array<String>) -> Observable<Result<Array<SquadChannel>, GeneralError>> {
        return Observable.create { (observer) -> Disposable in
            
            let groupManager = TIMManager.sharedInstance()?.groupManager()
            let conversationList = TIMManager.sharedInstance()?.getConversationList() ?? []
            
            groupManager?.getGroupInfo(groupIds, succ: { (list) in
                let groupList = list as? Array<TIMGroupInfo> ?? []
                var channelsList = Array<SquadChannel>()
                for i in 0..<groupList.count {
                    let groupInfo = groupList[i]
                    let conversation = conversationList.first(where: { $0.getReceiver() == groupInfo.group })
                    let message = MessageElem(message: groupInfo.lastMsg)
                    let channel = SquadChannel(sessionId: groupInfo.group,
                                               avatar: groupInfo.faceURL,
                                               title: groupInfo.groupName,
                                               content: message.description,
                                               unreadCount: Int(conversation?.getUnReadMessageNum() ?? 0),
                                               dateString: message.dateString)
                    channelsList.append(channel)
                }
                observer.onNext(.success(channelsList))
                observer.onCompleted()
            }, fail: { (code, message) in
                observer.onNext(.failure(.custom(message ?? "未知错误")))
                observer.onCompleted()
            })
            
            return Disposables.create()
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
    
    /*
     本地存在很多的会话
     本地存在很多的群
     
     一个squad对应很多的群
     
     
     */
    
    private func request(groupIds: Array<String>) {
        
        // 通过服务器返回的群组列表, 去查询本地的群组列表信息
        
        // 获取所有的会话列表, 可以通过筛选会话对象, 获取当前的未读消息数
        let conversationList = ConversationManager.shared.getConversation()
        
    }
    
    /// 获取Squad数据
    /// 先读取本地信息, 读取成功后刷新页面, 同时发起请求同步服务器数据
    private func loadSquadDetail() -> Observable<Result<Void, GeneralError>> {
//        return provider.request(target: , model: <#T##Decodable.Protocol#>, atKeyPath: <#T##OnlineProvider<SquadAPI>.ParseKeyPath#>)
        return Observable.just(.success(()))
    }
}

extension TIMGroupInfo {
    
//    var channel: SquadChannel {
//        return SquadChannel(sessionId: <#T##String#>, avatar: <#T##String?#>, title: <#T##String#>, content: <#T##String#>, unreadCount: <#T##Int#>, dateString: <#T##String#>)
//    }
    
}
