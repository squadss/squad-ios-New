//
//  OnlineProvider.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/4.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import RxSwift
//import Codextended

final class OnlineProvider<Target> where Target: Moya.TargetType {
    
    enum ParseKeyPath {
        case data
        case custom(String)
        
        var format: String {
            switch self {
            case .data: return "data"
            case .custom(let v): return v
            }
        }
    }
    
    let provider: MoyaProvider<Target>
    
    static var plugins: [PluginType] {
        
        let logger = NetworkLogger()
        
        var list: Array<PluginType> = [logger]
        
        if let token = UserDefaults.standard.token, token.isEmpty == false {
            list.append(CustomTokenPlugin { token })
        }
        
        return list
    }
    
    init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = OnlineProvider.neverStub,
         plugins: [PluginType] = OnlineProvider.plugins,
         trackInflights: Bool = false) {
        
        self.provider = MoyaProvider(endpointClosure: endpointClosure,
                                     requestClosure: requestClosure,
                                     stubClosure: stubClosure,
                                     callbackQueue: nil,
                                     manager: MoyaProvider<Target>.defaultAlamofireManager(),
                                     plugins: plugins,
                                     trackInflights: trackInflights)
    }
    
    func request(target: Target) -> Single<Response> {
        return provider.rx
            .request(target)
            .filterSuccessfulStatusCodes()
    }
    
    
    func request<T: Decodable>(target: Target, model: T.Type = T.self, atKeyPath: ParseKeyPath) -> Single<Swift.Result<T, GeneralError>> {
        return request(target: target, model: model, atKeyPath: atKeyPath.format)
    }
    
    func request<T: Decodable>(target: Target, model: T.Type = T.self, atKeyPath: String? = nil) -> Single<Swift.Result<T, GeneralError>> {
        return request(target: target)
            .map{ try model.decodeJSON(from: $0, designatedPath: atKeyPath) }
            .map{ object in
                if object is GeneralModel.Plain {
                    let plain = (object as! GeneralModel.Plain)
                    if !plain.success {
                        return .failure(.newwork(code: plain.code, message: plain.message))
                    }
                }
                return .success(object)
            }
            .catchError({ (error)  in
                guard let moyaError = error as? MoyaError else {
                    return .never()
                }
                return .just(.failure(GeneralError.from(error: moyaError)))
            })
            .do(onSuccess: {
                #if DEBUG
                if case .failure(let error) = $0 {
                    print(error.message)
                }
                #endif
            })
        
    }
    
    //还未实现
    func requestPlain(target: Target) -> Single<GeneralModel.Plain> {
        return .never()
    }
    
    final class func neverStub(_: Target) -> Moya.StubBehavior {
        return .never
    }
}

public extension Reactive where Base: MoyaProviderType {
    
    /// Designated request-making method.
    ///
    /// - Parameters:
    ///   - token: Entity, which provides specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Single response object.
    func request(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Single<Swift.Result<Response, MoyaError>> {
        return Single.create { [weak base] single in
            let cancellableToken = base?.request(token, callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                case let .success(response):
                    single(.success(.success(response)))
                case let .failure(error):
                    single(.success(.failure(error)))
                }
            }
            
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
}

extension Swift.Result {
    var error: Failure? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}

public struct CustomTokenPlugin: PluginType {

    /// A closure returning the access token to be applied in the header.
    public let tokenClosure: () -> String

    /**
     Initialize a new `AccessTokenPlugin`.

     - parameters:
       - tokenClosure: A closure returning the token to be applied in the pattern `Authorization: <AuthorizationType> <token>`
    */
    public init(tokenClosure: @escaping () -> String) {
        self.tokenClosure = tokenClosure
    }

    /**
     Prepare a request by adding an authorization header if necessary.

     - parameters:
       - request: The request to modify.
       - target: The target of the request.
     - returns: The modified `URLRequest`.
    */
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.addValue(tokenClosure(), forHTTPHeaderField: "token")
        return request
    }
}
