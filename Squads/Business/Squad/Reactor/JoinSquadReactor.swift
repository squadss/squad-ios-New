//
//  JoinSquadReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/19.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class JoinSquadReactor: Reactor {
    
    enum Action {
        case requestSquadDetail
        case joinSquad(accountId: Int, squadId: Int)
    }
    
    enum Mutation {
        case setSquadDetail(SquadDetail, User?)
        case setToast(String)
        case setLoading(Bool)
        case setJoinState(Bool, String)
    }
    
    struct State {
        var toast: String?
        var isLoading: Bool?
        var squadDetail: SquadDetail?
        var user: User?
        var joinSuccess: Bool?
    }
    
    let inviteCode: String
    let inviterAccountId: Int
    var initialState = State()
    var provider = OnlineProvider<SquadAPI>()
    var _userProvider = OnlineProvider<UserAPI>()
    
    init(inviteCode: String, inviterAccountId: Int) {
        self.inviteCode = inviteCode
        self.inviterAccountId = inviterAccountId
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestSquadDetail:
            
            let userObservable = _userProvider.request(target: .account(id: inviterAccountId), model: User.self, atKeyPath: .data).asObservable()
            
            let squadObservable = provider.request(target: .querySquadByInviteCode(code: inviteCode), model: SquadDetail.self, atKeyPath: .data).asObservable()
            
            return Observable.zip(userObservable, squadObservable)
                .map { (userResult, squadResult) in
                    switch (userResult, squadResult) {
                    case (.success(let user), .success(let squad)):
                        return .setSquadDetail(squad, user)
                    case (.failure, .failure(let error)), (.success, .failure(let error)):
                        return .setToast(error.message)
                    case (.failure, .success(let squad)):
                        return .setSquadDetail(squad, nil)
                    }
                }
                .startWith(.setLoading(true))
        case .joinSquad(let accountId, let squadId):
            // 先将用户加入到squad中, 再将用户邀请到squad下面所有的群中
            let addMember = provider.request(target: .addMember(squadId: squadId, accountId: accountId), model: GeneralModel.Plain.self).asObservable()
            let channels = provider.request(target: .getSquadChannel(squadId: squadId), model: Array<CreateChannel>.self, atKeyPath: .data).asObservable()
            
            return Observable
                .zip(addMember, channels)
                .flatMap { (joinResult, channelsResult) -> Observable<Result<Void, GeneralError>> in
                    switch (joinResult, channelsResult) {
                    case (.success, .success(let channels)):
                        return self.joinGroup(groupdList: channels.map{ String($0.id) }).map{ .success(()) }
                    case (.failure(let error), .success):
                        return Observable.just(.failure(error))
                    case (.failure(let error), .failure):
                        return Observable.just(.failure(error))
                    case (.success, .failure):
                        return Observable.just(.success(()))
                    }
                }
                .map { result in
                    switch result {
                    case .success: return .setJoinState(true, NSLocalizedString("squadDetail.joinSquadSuccessTip", comment: ""))
                    case .failure(let error): return .setToast(error.message)
                    }
                }
                .startWith(.setLoading(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setToast(let s):
            state.isLoading = false
            state.toast = s
        case .setLoading(let s):
            state.toast = nil
            state.isLoading = s
        case let .setSquadDetail(detail, user):
            state.isLoading = false
            state.user = user
            state.squadDetail = detail
        case let .setJoinState(s, toast):
            state.isLoading = false
            state.joinSuccess = s
            state.toast = toast
        }
        return state
    }
    
    private func joinGroup(groupdList: Array<String>) -> Observable<Void> {
        return Observable.create { (observer) -> Disposable in
            
            let groupManager = TIMManager.sharedInstance()?.groupManager()
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                let asyncGroup = DispatchGroup()
                for groupId in groupdList {
                    
                    asyncGroup.enter()
                    groupManager?.joinGroup(groupId, msg: "", succ: {
                        print("加入成功")
                        asyncGroup.leave()
                    }) { (code, message) in
                        print("加入失败")
                        asyncGroup.leave()
                    }
                }
                
                asyncGroup.notify(queue: .main, execute: {
                    observer.onNext(())
                    observer.onCompleted()
                })
            }
            
            return Disposables.create()
        }
        
    }
}
