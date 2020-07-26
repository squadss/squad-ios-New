//
//  File.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa
import ImSDK

class LoginReactor: Reactor {
    
    struct Model: Codable {
        let loginAccountVo: User
        let token: String
    }
    
    enum Action {
        case login(username: String, password: String)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setSuccess(Model)
        case setToast(String)
    }
    
    struct State {
        var loading: Bool?
        var toast: String?
        var success: Model?
    }
    
    var initialState: State
    var provider = OnlineProvider<UserAPI>()
    
    init() {
        initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .login(username, password):
            return provider.request(target: .signIn(username: username, password: password), model: Model.self, atKeyPath: .data)
                .asObservable()
                .flatMap({ result -> Observable<Result<Model, GeneralError>> in
                    switch result {
                    case .success(let model):
                        let param = TIMLoginParam()
                        param.appidAt3rd = "1400144517"
                        param.identifier = "eppeo1"
                        param.userSig = "eJxlz1FPgzAQwPF3PgXhdca0HcVh4gNDkjEkIdMSs5cG18KOKe1oUafxuxtxiSTe6**fu9yn47qu93B3f1ntdmroLLcnLT332vWQd-GHWoPgleXzXvxD*a6hl7yqrexHxJRSgtC0ASE7CzWcC6m1VHjiRhz4eOR3gY8Q9n2Kr6YJNCPmCYvTZan3hSkWJnuK2V6EW4UbUbb9bCsbErHjBiXLrI3NCg4RJJFlgS5Ky8R6eMuOESWPG-vclvj2lObmY*YP67ZapXUXqvxmctLCizx-FNKABmRBJvoqewOqGwOCMMVkjn7Gc76cb79fXgI_"
                        return self.loaginTIM(param: param).map { (subResult)  in
                            switch subResult {
                            case .success:
                                return .success(model)
                            case .failure(let error):
                                return .failure(error)
                            }
                        }
                    case .failure(let error):
                        return Observable.just(.failure(error))
                    }
                })
                .map{ result in
                    switch result {
                    case .success(let model):
                        return Mutation.setSuccess(model)
                    case .failure(let error):
                        return Mutation.setToast(error.message)
                    }
                }
                .startWith(.setLoading(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let s):
            state.loading = s
        case .setSuccess(let s):
            state.loading = false
            state.success = s
            state.toast = "Login successful!"
        case .setToast(let t):
            state.loading = false
            state.toast = t
        }
        return state
    }
    
    /// 登录IM
    private func loaginTIM(param: TIMLoginParam) -> Observable<Result<Void, GeneralError>> {
        return Observable.create { (observer) -> Disposable in
            
            TIMManager.sharedInstance()?.login(param, succ: {
                observer.onNext(.success(()))
                observer.onCompleted()
            }, fail: { (code, message) in
                observer.onNext(.failure(.custom(message ?? "未知错误")))
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
    }
}

