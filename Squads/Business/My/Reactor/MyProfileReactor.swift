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
    
    enum Action {
        case requestAllSquads
    }
    
    enum Mutation {
        case setRepos(Array<SquadDetail>)
        case setToast(String)
        case setLoading(Bool)
    }
    
    struct State {
        var repos: Array<SquadDetail>
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
        case .requestAllSquads:
            
//            let conversationsObservable = Observable<Array<V2TIMConversation>>.create { (observer) -> Disposable in
//                V2TIMManager.sharedInstance()?.getConversationList(0, count: 100, succ: { (conversationList, nextSeq, isFinished) in
//                    observer.onNext(conversationList ?? [])
//                    observer.onCompleted()
//                }, fail: { (code, message) in
//                    observer.onNext([])
//                    observer.onCompleted()
//                })
//                return Disposables.create()
//            }
            
//            let squadsObservable: Observable<Array<SquadDetail>> = provider
//                .request(target: .queryAllSquads, model: Array<SquadDetail>.self, atKeyPath: .data)
//                .asObservable()
//                .map { (result) in
//                    switch result {
//                    case .success(let list):
//                        return list
//                    case .failure:
//                        return []
//                    }
//                }
            
//            return Observable.zip(conversationsObservable, squadsObservable).map { (conversationList, squadList) -> Mutation in
//
//            }
            
            return provider.request(target: .queryAllSquads, model: Array<SquadDetail>.self, atKeyPath: .data)
                .asObservable()
                .map { (result) in
                    switch result {
                    case .success(let list):
                        return .setRepos(list)
                    case .failure(let error):
                        return .setToast(error.message)
                    }
                }
                .startWith(.setLoading(true))
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
}

