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
        case handlerGoing(isAccept: Bool, activityId: Int)
        case didDisplayCell(SquadActivity)
    }
    
    enum Mutation {
        case setActivities(Array<SquadActivity>)
        case setToast(String)
        case setLoading(Bool)
        case setDetail(SquadActivity)
        case setPrepareMembers(Array<ActivityMember>, detail: SquadActivity)
        case setSetTimeMembers(accept: Array<User>, reject: Array<User>, detail: SquadActivity)
        case setGoingStatus(activityId: Int, isGoing: Bool, toast: String)
        // 标记为正在请求中状态
        case flagRequestStatus(detail: SquadActivity)
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
        case let .handlerGoing(isAccept, activityId):
            return provider.request(target: .updateGoingStatus(activityId: activityId, isAccept: isAccept), model: GeneralModel.Plain.self).asObservable().map { result in
                switch result {
                case .success(let plain): return .setGoingStatus(activityId: activityId, isGoing: isAccept, toast: plain.message)
                case .failure(let error): return .setToast(error.message)
                }
            }
        case .didDisplayCell(let detail):
            switch detail.activityStatus {
            case .prepare:
                guard detail.responsedMembers == nil && !detail.requestStatus else { return .empty() }
                return provider.request(target: .getResponded(activityId: detail.id), model: Array<ActivityMember>.self, atKeyPath: .data).asObservable().map { result in
                    switch result {
                    case .success(let list): return .setPrepareMembers(list, detail: detail)
                    case .failure: return .setPrepareMembers([], detail: detail)
                    }
                }.startWith(.flagRequestStatus(detail: detail))
            case .setTime:
                guard detail.goingMembers == nil && !detail.requestStatus else { return .empty() }
                
                let rejectMemberObservable = provider.request(target: .queryMembersActivityGoingStatus(activityId: detail.id, isAccept: false), model: Array<User>.self, atKeyPath: .data).asObservable()
                
                let acceptMembersObservable = provider.request(target: .queryMembersActivityGoingStatus(activityId: detail.id, isAccept: true), model: Array<User>.self, atKeyPath: .data).asObservable()
                
                return Observable.zip(rejectMemberObservable, acceptMembersObservable).map { (rejectResult, acceptResult) -> Mutation in
                    switch (rejectResult, acceptResult) {
                    case (.success(let r_list), .success(let a_list)): return .setSetTimeMembers(accept: a_list, reject: r_list, detail: detail)
                    case (.failure, .success(let a_list)): return .setSetTimeMembers(accept: a_list, reject: [], detail: detail)
                    case (.failure, .failure): return .setSetTimeMembers(accept: [], reject: [], detail: detail)
                    case (.success(let r_list), .failure): return .setSetTimeMembers(accept: [], reject: r_list, detail: detail)
                    }
                }.startWith(.flagRequestStatus(detail: detail))
            }
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
        case let .setGoingStatus(activityId, isGoing, s):
            if let index = state.repos.firstIndex(where: { $0.id == activityId }), let user = User.currentUser() {
                if isGoing {
                    state.repos[index].goingMembers?.append(user)
                    state.repos[index].rejectMembers?.removeAll(where: { $0 == user })
                } else {
                    state.repos[index].rejectMembers?.append(user)
                    state.repos[index].goingMembers?.removeAll(where: { $0 == user })
                }
            }
            state.toast = s
        case let .setPrepareMembers(list, detail):
            if let index = state.repos.firstIndex(of: detail) {
                state.repos[index] = detail.fromPrepareMembers(responede: list, waiting: nil)
            }
        case let .setSetTimeMembers(accept, reject, detail):
            if let index = state.repos.firstIndex(of: detail) {
                state.repos[index] = detail.fromGoingMembers(accept: accept, reject: reject)
            }
        case .flagRequestStatus(let detail):
            if let index = state.repos.firstIndex(of: detail) {
                state.repos[index] = detail.requestingStatus()
            }
        }
        return state
    }
}

