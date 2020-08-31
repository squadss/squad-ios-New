//
//  FriendProfileReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class FriendProfileReactor: Reactor {
    
    struct UserParams {
        var nickname: String?
        var gender: Gender?
        var phone: String?
        private var username: String?
        var avatar: Data?
        
        var formatUsername: String? {
            if username?.hasPrefix("@") == true {
                return username?.substring(fromIndex: 1)
            }
            return username
        }
        
        init(params: Array<(String, String?)>?, avatar: Data?) {
            params?.forEach {
                switch $0 {
                case "Name": nickname = $1
                case "USER": username = $1
                case "PHONE": phone = $1
                case "Gender": gender = $1.flatMap { Gender(title: $0) }
                default:
                    assert(true)
                }
            }
            self.avatar = avatar
        }
        
        func isEquad(to repos: Array<Model>?) -> Bool {
            guard let unwrappedRepos = repos, unwrappedRepos.count == 4 else {
                return false
            }
            if avatar != nil {
                return false
            }
            if unwrappedRepos[0].content == nickname
                && unwrappedRepos[1].content == username
                && unwrappedRepos[2].content == phone
            && unwrappedRepos[3].content == gender?.rawValue {
                return true
            }
            return false
        }
    }
    
    struct Model: Equatable {
        var title: String
        var content: String
        var isEnabled: Bool = false
        var isShowTextField: Bool = true
        
        static func == (lhs: Model, rhs: Model) -> Bool {
            return lhs.title == rhs.title && lhs.content == rhs.content
        }
    }
    
    enum Action {
        case requestUserInfo
        case updateUserInfo(UserParams)
        case toggleEnable
    }
    
    enum Mutation {
        case setUser(User)
        case setToast(String, Bool)
        case setLoading(Bool)
        case setToggleEdit
    }
    
    struct State {
        var isLoading: Bool?
        var toast: (String, Bool)?
        var isOwner: Bool
        var avatar: URL?
        var repos: Array<Model>
    }
    
    let accountId: Int
    var initialState: State
    var provider = OnlineProvider<UserAPI>()
    private var localUser = User.currentUser()
    
    init(accountId: Int) {
        self.accountId = accountId
        let repos = ["Name", "USER", "PHONE", "Gender"].map{
            return Model(title: $0, content: "")
        }
        initialState = State(isOwner: localUser?.id == accountId, repos: repos)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestUserInfo:
            return provider.request(target: .account(id: accountId), model: User.self, atKeyPath: .data).asObservable().do(onNext: { [unowned self]result in
                if case .success(let user) = result, user.id == self.localUser?.id {
                    user.save()
                    self.localUser = user
                }
            }).map { result in
                switch result {
                case .success(let user): return .setUser(user)
                case .failure(let error): return .setToast(error.message, false)
                }
            }.startWith(.setLoading(true))
        case .updateUserInfo(let params):
            return provider.request(target: .update(accountId: accountId,
                                                    phoneNumber: params.phone,
                                                    nationCode: localUser?.nationCode,
                                                    username: params.formatUsername,
                                                    nickname: params.nickname,
                                                    gender: params.gender,
                                                    avatar: params.avatar),
                                    model: GeneralModel.Plain.self).asObservable().map { result in
            switch result {
            case .success: return .setToast("", true)
            case .failure(let error): return .setToast(error.message, false)
            }
            }.startWith(.setLoading(true))
        case .toggleEnable:
            return .just(.setToggleEdit)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let s):
            state.toast = nil
            state.isLoading = s
        case let .setToast(str, isSuccess):
            state.isLoading = false
            state.toast = (str, isSuccess)
        case .setUser(let user):
            state.isLoading = false
            state.repos[0].content = user.nickname
            state.repos[1].content = "@" + user.username
            state.repos[2].content = user.phoneNumber ?? ""
            state.repos[3].content = user.gender.rawValue
            state.repos[3].isShowTextField = false
            state.avatar = user.avatar.asURL
        case .setToggleEdit:
            state.repos.enumerated().forEach({ (offset, elem) in
                state.repos[offset].isEnabled.toggle()
            })
        }
        return state
    }
}
