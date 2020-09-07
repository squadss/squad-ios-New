//
//  GeneralError.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import Moya

enum GeneralError: Error {
    case unknown    //未知错误
    case custom(String) //自定义错误, 一般提示给用户
    case mapping(String)   //解析失败, 一般不提示给用户, 只本地调试log使用
    case newwork(GeneralModel.Plain) //服务器错误
    case noConnection   //没有连接服务器
    case loginStatusDidExpired  //登录已过期
}

extension GeneralError {
    var code: Int? {
        switch self {
        case .custom, .unknown, .mapping:
            return nil
        case let .newwork(plain):
            return plain.code
        case .noConnection:
            return nil
        case .loginStatusDidExpired:
            return nil
        }
    }
    
    //服务器拒绝受理
    var rejectAccept: Bool {
        guard let unwrappedCode = code else {
            return false
        }
        /*
         40010      账号不存在或密码错误
         
         */
        switch unwrappedCode {
        case 40010:
            return true
        default:
            return false
        }
    }
    
    var message: String {
        switch self {
        case let .custom(str):
            return str
        case .unknown:
            return "未知错误"
        case let .mapping(str):
            return str
        case let .newwork(plain):
            return plain.message
        case .noConnection:
            return "网络不通"
        case .loginStatusDidExpired:
            return "登录已过期"
        }
    }
    
    static func from(error: MoyaError) -> GeneralError {
        switch error {
        case .requestMapping:
            return .mapping("请求URL路径不正确")
        case .encodableMapping:
            return .mapping("未能将可编码对象编码成数据")
        case .imageMapping:
            return .mapping("未能将数据映射成图像")
        case .parameterEncoding:
            return .mapping("未能为URLRequest编码参数")
        case let .jsonMapping(response):
            if let model = try? response.map(GeneralModel.Plain.self) {
                return .newwork(model)
            } else {
                return .unknown
            }
        case let .objectMapping(error, response):
            if error is DecodingError {
                let absoluteString = response.request.flatMap{ $0.url?.absoluteString } ?? ""
                let responseString = (String(data: response.data, encoding: .utf8) ?? "未知")
                return .mapping("❌解析错误:\n URL: \(absoluteString) \n Response: \(responseString) \n Error: \(error)")
            } else if let model = try? response.map(GeneralModel.Plain.self) {
                return .newwork(model)
            } else {
                return .unknown
            }
        case let .statusCode(response):
            do {
                let plain = try response.map(GeneralModel.Plain.self)
                switch plain.code {
                case 401:
                    //{"code":401,"message":"非法访问","success":false,"time":"2020-07-24 21:56:51"}
                    return .loginStatusDidExpired
                default:
                    return .newwork(plain)
                }
            } catch {
                return .mapping("请求错误：\(response.statusCode), 描述：" + response.description)
            }
        case let .stringMapping(response):
            return .mapping("解析字符串错误：\(String(describing: try? response.mapString()))")
        case let .underlying(error, _):
            let nsError = error as NSError
            if nsError.code == -1009 {
                return .noConnection
            }
            return .custom(error.localizedDescription)
        }
    }
}

//extension Result where Failure == GeneralError {
//
//    static func toList<T>(list: [Any]?, error: EMError?, type: Array<T>.Type = Array<T>.self) -> Result<Array<T>, GeneralError> {
//        if let unwrappedError = error {
//            return .failure(unwrappedError.toIMError)
//        }
//        else if let unwrappedList = list as? [T] {
//            return .success(unwrappedList)
//        }
//        else {
//            return .success([])
//        }
//    }
//
//    static func toObject<T>(object: Any?, error: EMError?, type: T.Type = T.self) -> Result<T, GeneralError> {
//        if let unwrappedObject = object as? T {
//            return .success(unwrappedObject)
//        }
//        else if let unwrappedError = error {
//            return .failure(unwrappedError.toIMError)
//        }
//        else {
//            return .failure(.unknown)
//        }
//    }
//
//    static func toVoid(error: EMError?) -> Result<Void, GeneralError> {
//        if let unwrappedError = error {
//            return .failure(unwrappedError.toIMError)
//        }
//        else {
//            return .success(())
//        }
//    }
//}
