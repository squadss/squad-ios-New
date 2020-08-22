//
//  FlicksAPI.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/2.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Alamofire

enum FlicksAPI {

}

extension FlicksAPI: TargetType {
    
    var baseURL: URL {
        //115.159.208.16:8888/api
        return URL(string: "http://squad.wieed.com:8888/api/")!
    }
    
    var path: String {
        switch self {
        default:
            return "user/logout"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
