//
//  SquadActivitiesReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class SquadActivitiesReactor: Reactor {
    
    enum Action {
        case requestList
//        case updateDetail(SquadActivity)
    }
    
    enum Mutation {
        case setActivities(Array<SquadActivity>)
        case setToast(String)
        case setLoading(Bool)
        case setDetail(SquadActivity)
    }
    
    struct State {
        var toast: String?
        var isLoading: Bool?
        var repos = Array<SquadActivity>()
    }
    
    let squadId: Int
    var initialState = State()
    var provider = OnlineProvider<SquadAPI>()
    
    init(squadId: Int) {
        self.squadId = squadId
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestList:
            return provider.request(target: .queryActivities(squadId: squadId), model: Array<SquadActivity>.self, atKeyPath: .data).asObservable().map { result in
                switch result {
                case .success(let list): return .setActivities(list)
                case .failure(let error): return .setToast(error.message)
                }
            }.startWith(.setLoading(true))
//        case .updateDetail(let detial):
//            return provider.request(target: .updateActivityMemberInfo(activityId: detial.activityId, myTime: nil, isGoing: detial), model: GeneralModel.Plain.self).asObservable().map { result in
//                switch result {
//                case .success(let plain): return .setToast(plain.message)
//                case .failure(let error): return .setToast(error.message)
//                }
//            }
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
        case .setActivities(let list):
            state.isLoading = false
            state.repos = list
        case .setDetail(let detail):
            state.isLoading = false
            if let index = state.repos.firstIndex(of: detail) {
                state.repos[index] = detail
            }
        }
        return state
    }
}

