//
//  SquadInvithNewReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources

class SquadInvithNewReactor: Reactor {
    
    struct Member: Equatable {
        var user: User
        var isAdded: Bool = false
        var isColsable: Bool = true
        
        static func == (lhs: Member, rhs: Member) -> Bool {
            return lhs.user == rhs.user
        }
    }
    
    enum Action {
        case deleteSelectedMember(Member)
        case addSelectedMember(Member)
        case request
    }
    
    enum Mutation {
        case setDeleteMember(Member)
        case setAddMember(Member)
        case setRequestResult(Result<Void, GeneralError>)
    }
    
    struct State {
        var repos: Array<[Member]>
        var members: Array<Member>?
        var requestResult: Result<Void, GeneralError>?
    }
    
    var initialState: State
    
    init() {
        initialState = State(repos: [
                [
                    Member(user: User(username: "1"), isAdded: false, isColsable: true),
                    Member(user: User(username: "2"), isAdded: false, isColsable: true)
                ],
                [
                    Member(user: User(username: "3"), isAdded: false, isColsable: true),
                    Member(user: User(username: "4"), isAdded: false, isColsable: true)
                ]
            ]
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .deleteSelectedMember(let member):
            return Observable.just(.setDeleteMember(member))
        case .addSelectedMember(let member):
            return Observable.just(.setAddMember(member))
        case .request:
            return Observable.just(.setRequestResult(.success(())))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setAddMember(let member):
            
            if state.members == nil {
                //FIXME: - 当前User为测试数据
                let current = Member(user: User(username: "-1"), isAdded: false, isColsable: false)
                state.members = [current, member]
            } else {
                state.members?.append(member)
            }
            
            for s_index in 0..<state.repos.count {
                let section = state.repos[s_index]
                for i_index in 0..<section.count {
                    var item = section[i_index]
                    if item == member {
                        item.isAdded = true
                        state.repos[s_index][i_index] = item
                        break
                    }
                }
            }
        case .setDeleteMember(let member):
            state.members?.removeAll(where: { $0 == member })
            for s_index in 0..<state.repos.count {
                let section = state.repos[s_index]
                for i_index in 0..<section.count {
                    var item = section[i_index]
                    if item == member {
                        item.isAdded = false
                        state.repos[s_index][i_index] = item
                        break
                    }
                }
            }
        case .setRequestResult(let result):
            state.requestResult = result
        }
        return state
    }
}

