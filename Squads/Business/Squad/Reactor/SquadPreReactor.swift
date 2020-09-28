//
//  SquadPreReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class SquadPreReactor: Reactor {
    
    struct Model {
        let title: String
        var isHight: Bool = false
    }
    
    enum Action {
        case refreshSquadDetail
        case setDetail(avatar: Data?, squadName: String?)
    }
    
    enum Mutation {
        case setSquadDetail(SquadDetail, toast: String?)
        case setToast(String)
        case setLoading(Bool)
    }
    
    struct State {
        let repos: Array<Model> = [
            Model(title: "MEMBERS"),Model(title: "NOTIFICATIONS"),
            Model(title: "CUSTOMIZE THEME"),
            Model(title: "INVITH NEW"),
            Model(title: "LEAVE SQUAD", isHight: true)
        ]
        var squadDetail: SquadDetail?
        var toast: String?
        var isLoading: Bool?
    }
    
    let squadId: Int
    var initialState: State
    var provider = OnlineProvider<SquadAPI>()
    
    init(squadId: Int) {
        self.squadId = squadId
        initialState = State()
    }
    
    init(squadDetail: SquadDetail) {
        squadId = squadDetail.id
        initialState = State(squadDetail: squadDetail)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refreshSquadDetail:
            return provider.request(target: .querySquad(id: squadId, setTop: false), model: SquadDetail.self, atKeyPath: .data).asObservable().map { result in
                switch result {
                case .success(let detail): return .setSquadDetail(detail, toast: nil)
                case .failure(let error): return .setToast(error.message)
                }
            }.startWith(.setLoading(true))
        case let .setDetail(avatar, squadName):
            return provider.request(target: .updateSquad(id: squadId, name: squadName, avator: avatar), model: SquadDetail.self, atKeyPath: .data).asObservable().map { result in
                switch result {
                case .success(let detail):
                    let toast = NSLocalizedString("system.updateSuccess", comment: "")
                    return .setSquadDetail(detail, toast: toast)
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
        case .setSquadDetail(let detail, let toast):
            state.isLoading = false
            state.toast = toast
            state.squadDetail = detail
        }
        return state
    }
}

