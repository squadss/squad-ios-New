//
//  ApplyListReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/18.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class ApplyListReactor: Reactor {
    
    enum Action {
        case requestAllRecord
        case joinSquad(Int)
    }
    
    enum Mutation {
        case setRepos(Array<Invitation>)
        case setToast(String)
        case setLoading(Bool)
        case setInvite(squadId: Int, state: Invitation.Status, toast: String)
    }
    
    struct State {
        var repos: Array<Invitation>
        var toast: String?
        var isLoading: Bool?
    }
    
    var initialState: State
    var provider = OnlineProvider<SquadAPI>()
    
    init() {
        initialState = State(repos: [])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestAllRecord:
            return provider.request(target: .myInviteRecords, model: Array<Invitation>.self, atKeyPath: .data).asObservable().map { result in
                switch result {
                case .success(let list): return .setRepos(list)
                case .failure(let error): return .setToast(error.message)
                }
            }.startWith(.setLoading(true))
        case .joinSquad(let squadId):
            let accountId = User.currentUser()!.id
            return provider.request(target: .addMember(squadId: squadId, accountId: accountId), model: GeneralModel.Plain.self).asObservable().map { result in
                switch result {
                case .success(let plain): return .setInvite(squadId: squadId, state: .accepted, toast: plain.message)
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
        case let .setInvite(squadId, s, toast):
            if let index = state.repos.firstIndex(where: { $0.inviteSquadId == squadId }) {
                state.repos[index].inviteStatus = s
                state.isLoading = false
                state.toast = toast
            }
        }
        return state
    }
}
