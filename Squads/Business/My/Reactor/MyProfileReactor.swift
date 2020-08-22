//
//  MyProfileReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class MyProfileReactor: Reactor {
    
    struct Model {
        var squadDetail: SquadDetail
        var unreadCount: Int
        // 保存会话中未读消息的字典  key: groupId, value: unreadCount
        var unreadCountDict: Dictionary<String, Int>
    }
    
    enum Action {
        // 请求所有的squad
        case requestAllSquads
        // 刷新会话列表
        case refreshChannels(RefreshChannelsAction)
    }
    
    enum Mutation {
        case setRepos(Array<Model>)
        case setToast(String)
        case setLoading(Bool)
    }
    
    struct State {
        var repos: Array<Model>
        var toast: String?
        var loading: Bool?
    }
    
    var initialState: State
    var provider = OnlineProvider<SquadAPI>()
    
    init() {
        initialState = State(repos: [])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refreshChannels(let action):
            switch action {
            case .update(let list):
                // 更新当前会话, 不需要从服务器重新查每个squad下对应的channel
                var newSquadList = currentState.repos
                for conversation in list {
                    for i in 0..<newSquadList.count {
                        let squad = newSquadList[i]
                        let channels = squad.squadDetail.channels
                        if channels?.contains(where: { String($0.id) == conversation.groupID }) == true {
                            // 将除了本次会话的其余全部会话中的未读消息数加一起 + 本次会话的未读消息数 = squad中总值
                            let currentUnreadCount = Int(conversation.unreadCount)
                            let otherUnreadCount = squad.unreadCountDict
                                .filter { (key, _) -> Bool in key != conversation.groupID }
                                .reduce(0) { (total, dict) -> Int in total + dict.value }
                            newSquadList[i].unreadCount = currentUnreadCount + otherUnreadCount
                            newSquadList[i].unreadCountDict[conversation.groupID] = currentUnreadCount
                            break
                        }
                    }
                }
                return Observable.just(.setRepos(newSquadList))
            case .insert:
                return self.requestAllSquads()
            }
        case .requestAllSquads:
            return self.requestAllSquads()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setRepos(let list):
            state.loading = false
            state.repos = list
        case .setLoading(let s):
            state.toast = nil
            state.loading = s
        case .setToast(let s):
            state.loading = false
            state.toast = s
        }
        return state
    }
    
    // 重新请求全部的squad并计算它的未读消息数
    private func requestAllSquads() -> Observable<Mutation> {
        
        // 我的会话列表
        let conversationsObservable = Observable<Array<V2TIMConversation>>.create { (observer) -> Disposable in
            V2TIMManager.sharedInstance()?.getConversationList(0, count: 100, succ: { (conversationList, nextSeq, isFinished) in
                observer.onNext(conversationList ?? [])
                observer.onCompleted()
            }, fail: { (code, message) in
                observer.onNext([])
                observer.onCompleted()
            })
            return Disposables.create()
        }
        
        // 我的squad列表
        let squadsObservable: Observable<Result<Array<SquadDetail>, GeneralError>> = provider
            .request(target: .queryAllSquads, model: Array<SquadDetail>.self, atKeyPath: .data)
            .asObservable()
            
        return Observable.zip(conversationsObservable, squadsObservable).map { (conversationList, squadResult) -> Mutation in
            switch squadResult {
            case .success(let squadList):
                var list = Array<Model>()
                var newConversationList = conversationList
                for squad in squadList {
                    var unreadCount: Int = 0
                    var unreadCountDict = Dictionary<String, Int>()
                    if let channels = squad.channels {
                        var alreadyExistConversation = Array<V2TIMConversation>()
                        for conversation in newConversationList {
                            let isContains = channels.contains(where: { String($0.id) == conversation.groupID })
                            if isContains {
                                unreadCountDict[conversation.groupID] = Int(conversation.unreadCount)
                                unreadCount += unreadCountDict[conversation.groupID, default: 0]
                                alreadyExistConversation.append(conversation)
                            }
                        }
                        newConversationList.removeAll(where: { alreadyExistConversation.contains($0) })
                    }
                    list.append(Model(squadDetail: squad, unreadCount: unreadCount, unreadCountDict: unreadCountDict))
                }
                return .setRepos(list)
            case .failure(let error):
                return .setToast(error.message)
            }
        }.startWith(.setLoading(true))
    }
}

