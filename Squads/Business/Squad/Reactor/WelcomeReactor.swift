//
//  WelcomeReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/2.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class WelcomeReactor: Reactor {
    
    enum Action {
        case requestSquadDetail(code: String)
        case joinSquad(accountId: Int)
    }
    
    enum Mutation {
        case setSquadDetail(SquadDetail?)
        case setToast(String)
        case setLoading(Bool)
        case setJoinState(Bool, String)
    }
    
    struct State {
        var toast: String?
        var isLoading: Bool?
        var squadDetail: SquadDetail?
        var joinSquadId: Int?
    }
    
    var initialState = State()
    
    var provider = OnlineProvider<SquadAPI>()
    
    init() { }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestSquadDetail(let inviteCode):
            return provider.request(target: .querySquadByInviteCode(code: inviteCode), model: SquadDetail.self, atKeyPath: .data).asObservable()
                .map { result in
                    switch result {
                    case .success(let model): return .setSquadDetail(model)
                    case .failure: return .setSquadDetail(nil)
                    }
                }
                .startWith(.setLoading(true))
        case .joinSquad(let accountId):
            guard let squadId = currentState.squadDetail?.id else {
                return Observable.just(.setToast(NSLocalizedString("squadDetail.notFoundSquadTip", comment: "")))
            }
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
        case .setSquadDetail(let detail):
            state.isLoading = false
            state.squadDetail = detail
        case let .setJoinState(s, toast):
            if s {
                state.joinSquadId = state.squadDetail?.id
            } else {
                state.joinSquadId = nil
            }
            state.toast = toast
            state.isLoading = false
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
                        asyncGroup.leave()
                    }) { (code, message) in
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
