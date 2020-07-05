//
//  UserAPI.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Alamofire

enum UserAPI {
    // 用户注册
    case signUp(username: String, password: String, rePassword: String, inviteCode: String)
    // 用户登录
    case signIn(username: String, password: String)
    // 根据token获取系统登录用户信息
    case getAccountInfo
    // 获取账号id获取用户详情
    case account(id: String)
}

extension UserAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: "http://squad.wieed.com:8888/api/")!
    }
    
    var path: String {
        switch self {
        case .signUp:
            return "signup"
        case .signIn:
            return "signin"
        case .getAccountInfo:
            return "getAccountInfo"
        case .account(let id):
            return "account/" + id
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp, .signIn:
            return .post
        case .getAccountInfo, .account:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case let .signUp(username, password, rePassword, inviteCode):
            var dic: [String: String] = [:]
            dic["username"] = username
            dic["password"] = password
            dic["rePassword"] = rePassword
            dic["inviteCode"] = inviteCode
            return .requestParameters(parameters: dic, encoding: JSONEncoding.default)
        case let .signIn(username, password):
            var dic: [String: String] = [:]
            dic["username"] = username
            dic["password"] = password
            return .requestParameters(parameters: dic, encoding: JSONEncoding.default)
        case .getAccountInfo, .account:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
