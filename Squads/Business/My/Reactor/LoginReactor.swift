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

class LoginReactor: Reactor {
    
    struct TimVo: Codable {
        let userId: String
        let sdkappid: Int
        let userSig: String
    }
    
    struct Model: Codable {
        let loginAccountVo: User
        let token: String
        let timAccountVo: TimVo
        var topSquad: Int?
        
        enum CodingKeys: String, CodingKey {
            case loginAccountVo
            case token
            case timAccountVo
        }
        
        init(from decoder: Decoder) throws {
            loginAccountVo = try decoder.decode("loginAccountVo")
            token = try decoder.decode("token")
            timAccountVo = try decoder.decode("timAccountVo")
        }
        
        func addTopSquad(squadId: Int?) -> Model {
            var model = self
            model.topSquad = squadId
            return model
        }
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
    // 这里后期可以通过接口优化, 在登录接口直接返回是否存在topSquad即可, 省的我们自己去查一遍, 待优化!
    private var _squadProvider: OnlineProvider<SquadAPI>!
    
    init() {
        initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .login(username, password):
            return provider.request(target: .signIn(username: username, password: password), model: Model.self, atKeyPath: .data)
                .asObservable()
                .do(onNext: {
                    // 放在这里保存token只是便于请求queryAllSquads接口时, 可以带上token, 我们后期在接口上会进行优化, 登录完成后, 自动调用查询topSquad数据, 就不需要我们手动调接口了
                    if case let .success(model) = $0 {
                        UserDefaults.standard.token = model.token
                    }
                })
                .flatMap{ [unowned self] result -> Observable<Result<Model, GeneralError>> in
                    switch result {
                    case .success(let model):
                        return self.isExistTopSquad.map { .success(model.addTopSquad(squadId: $0)) }
                    case .failure(let error):
                        return Observable.just(.failure(error))
                    }
                }
                .flatMap({ result -> Observable<Result<Model, GeneralError>> in
                    switch result {
                    case .success(let model):
                        let param = TIMLoginParam()
                        param.appidAt3rd = "\(model.timAccountVo.sdkappid)"
                        param.identifier = model.timAccountVo.userId
                        param.userSig = model.timAccountVo.userSig
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
    
    /// 是否存在置顶squad, 因为服务器没有设计这个接口, 所以我们需要从"我加入的所有squad"列表中去找, 如果为空, 表示用户没有加入过任何一个squad, 然后我们需要引导用户去创建自己的squad, 如果列表中有值, 那么我们默认取列表中第一个值返回
    private var isExistTopSquad: Observable<Int?> {
        // 之所以要在这里做懒加载, 是因为OnlineProvider初始化时, 会自动写入token, 如果放在上面初始化反而不行, 因为那时候token还是空的
        if _squadProvider == nil {
            _squadProvider = OnlineProvider<SquadAPI>()
        }
        return _squadProvider.request(target: .queryAllSquads, model: Array<SquadDetail>.self, atKeyPath: .data)
            .asObservable()
            .map { (result) in
                if case .success(let list) = result, !list.isEmpty {
                    return list[0].id
                }
                return nil
            }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let s):
            state.toast = nil
            state.loading = s
        case .setSuccess(let s):
            state.loading = false
            state.success = s
            state.toast = NSLocalizedString("system.loginSuccess", comment: "")
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

