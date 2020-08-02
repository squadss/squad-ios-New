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
        // 获取通讯录中联系人手机号
        case visibleContacts(phoneList: Array<String>, isDenied: Bool)
        // 邀请好友, 生成邀请链接
        case createLink
    }
    
    enum Mutation {
        case setDeleteMember(Member)
        case setAddMember(Member)
        case setInviteSuccess
        case setMembers(members: Array<Member>, isDenied: Bool?)
        case setToast(String)
        case setLinkText(String)
        case setLoading(Bool)
    }
    
    struct State {
        var repos: Array<[Member]>
        var members: Array<Member>?
        // 邀请成功
        var inviteSuccess: Bool?
        // 是否拒绝访问通讯录
        var isDeniedVisibleContacts: Bool?
        // toast
        var toast: String?
        // loading
        var isLoading: Bool?
        // 邀请链接
        var linkText: String?
        
        var isEmptyRepos: Bool {
            return repos[0].isEmpty && repos[1].isEmpty
        }
    }
    
    var initialState: State
    var provider = OnlineProvider<SquadAPI>()
    
    let squadId: Int
    init(squadId: Int) {
        self.squadId = squadId
        initialState = State(repos: [[], []])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .deleteSelectedMember(let member):
            return Observable.just(.setDeleteMember(member))
        case .addSelectedMember(let member):
            return Observable.just(.setAddMember(member))
        case .request:
            let userIds = currentState.members?.map{ $0.user.username } ?? []
            return provider.request(target: .inviteFriends(squadId: squadId, userIds: userIds), model: GeneralModel.Plain.self).asObservable().map { result in
                switch result {
                case .success:
                    return .setInviteSuccess
                case .failure(let error):
                    return .setToast(error.message)
                }
            }
        case let .visibleContacts(phoneList, isDenied):
            return provider.request(target: .isAlreadyRegistered(phoneList: phoneList),
                                    model: Array<User>.self,
                                    atKeyPath: .data).asObservable().map { result in
                switch result {
                case .success(let list):
                    return .setMembers(members: list.map{ Member(user: $0, isAdded: false, isColsable: true) }, isDenied: isDenied)
                case .failure(let error):
                    return .setToast(error.message)
                }
            }
        case .createLink:
            return provider.request(target: .createLinkBySquad(squadId: squadId, nationCode: "+86", phoneNumber: 17771865607), model: String.self, atKeyPath: .data).asObservable().map { result in
                switch result {
                case .success(let linkString):
                    return .setLinkText(linkString)
                case .failure(let error):
                    return .setToast(error.message)
                }
            }.startWith(.setLoading(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        //每次进来都需要置空, 因为这个它只被允许订阅一次
        state.linkText = nil
        
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
        case .setInviteSuccess:
            state.inviteSuccess = true
        case .setToast(let s):
            state.isLoading = false
            state.toast = s
        case .setLoading(let s):
            state.toast = nil
            state.isLoading = s
        case let .setMembers(members, isDenied):
            if isDenied != nil {
                // 更新的通讯录列表
                state.repos[1] = members
                state.isDeniedVisibleContacts = isDenied
            } else {
                // 更新的好友列表
                state.repos[0] = members
            }
        case .setLinkText(let str):
            state.isLoading = false
            state.linkText = str
        }
        return state
    }
}

