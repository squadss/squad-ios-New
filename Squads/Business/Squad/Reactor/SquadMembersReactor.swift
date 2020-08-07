//
//  SquadMembersReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class SquadMembersReactor: Reactor {
    
    enum Action {
        case refreshList
    }
    
    enum Mutation {
        case setRepos(Array<User>)
        case setToast(String)
        case setLoading(Bool)
    }
    
    struct State {
        var repos = Array<User>()
        var isLoading: Bool?
        var toast: String?
    }
    
    var initialState: State
    let squadId: Int
    
    var provider = OnlineProvider<SquadAPI>()
    
    init(squadId: Int) {
        self.squadId = squadId
        initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refreshList:
            return provider.request(target: .getMembersFromSquad(squadId: squadId), model: Array<User>.self, atKeyPath: .data).asObservable().map { result in
                switch result {
                case .success(let list): return .setRepos(list)
                case .failure(let error): return .setToast(error.message)
                }
            }.startWith(.setLoading(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let s):
            state.toast = nil
            state.isLoading = s
        case .setToast(let s):
            state.isLoading = false
            state.toast = s
        case .setRepos(let list):
            state.isLoading = false
            state.repos = list
        }
        return state
    }
}

