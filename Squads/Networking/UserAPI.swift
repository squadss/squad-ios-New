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
    case login
}

extension UserAPI: TargetType, AccessTokenAuthorizable {
    var baseURL: URL {
        return URL(string: "http://api.baijuncheng.com:4443/common")!
    }
    
    var path: String {
        switch self {
        case .login:
            return "haha"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login: return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .login:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var authorizationType: AuthorizationType {
        return .basic
    }
    
}
