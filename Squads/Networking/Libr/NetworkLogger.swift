//
//  NetworkLogger.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/4.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import Result
import Moya

struct LogModel {
    
    var request: URLRequest?
    
    var response: HTTPURLResponse?
    
    var data: Data?
    
    var error: Error?
    
    let task: Moya.Task
    
    init(task: Moya.Task) {
        
        self.task = task
        
    }
}

extension LogModel: CustomDebugStringConvertible {
    
    var debugDescription: String {
        if let unwrappedError = error {
            return requestString + responseString + dataString + "\n-错误: \(unwrappedError.localizedDescription)" + "\n******over*******\n"
        }
        else {
            return requestString + responseString + dataString + "\n******over*******\n"
        }
    }
    
    var params: String {
        if case .requestParameters(let params, _) = task {
            if let data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
                if let str = String(data: data, encoding: String.Encoding.utf8) {
                    return str
                }
            }
        }
        return "为空"
    }
}

extension LogModel {
    
    var requestString: String {
        
        let address = request?.url?.absoluteString ?? String()
        let head = request?.allHTTPHeaderFields ?? Dictionary<String,String>()
        let method = request?.httpMethod ?? String()
        
        
        
        return "******start*******\n-地址: \(address) \n-头部: \(head) \n-方法: \(method) \n-参数: \(params) \n"
    }
    
    var responseString: String {
        
        let status = response?.statusCode
        
        if let unwrapped = status {
            return "-响应: \(unwrapped)\n"
        }
        else {
            return "-响应: 未知\n"
        }
    }
    
    var dataString: String {
        
        var temp = ""
        
        if let unwrappedData = data {
            temp = String(data: unwrappedData, encoding: .utf8)!
        }
        else {
            temp = "data为空"
        }
        
        return temp
    }
    
}

struct RequestLogger: CustomDebugStringConvertible {
    
    enum Component: Comparable {
        case header(String)
        case url(String)
        case body(String)
        case method(String)
        case responseSuccess(String)
        case responseFailure(String)
        
        var description: String {
            switch self {
            case .header(let v):
                return "\n🥊  Header: \(v)"
            case .body(let v):
                return "\n🥊    Body: \(v)"
            case .method(let v):
                return "\n🥊  Method: \(v)"
            case .responseSuccess(let v):
                return "\n✅        : \(v)"
            case .responseFailure(let v):
                return "\n❌        : \(v)"
            case .url(let v):
                return "\n🥊     URL: \(v)"
            }
        }
        
        var index: Int {
            switch self {
            case .header: return 0
            case .method: return 10
            case .body: return 20
            case .responseSuccess: return 30
            case .responseFailure: return 31
            case .url: return 1
            }
        }
        
        static func < (lhs: Component, rhs: Component) -> Bool {
            return lhs.index < rhs.index
        }
    }
    
    private var list = Array<Component>()
    
    mutating func clear() {
        list.removeAll(keepingCapacity: true)
    }
    
    mutating func addHeader(_ dict: [String: String]) {
        let str = dict.reduce("\n") { (total, arg1) -> String in
            return total + arg1.key + ":" + arg1.value + "\n"
        }
        list.append(.header(str))
    }
    
    mutating func addBody(_ task: Moya.Task) {
        var params: String {
            if case .requestParameters(let params, _) = task {
                if let data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
                    if let str = String(data: data, encoding: String.Encoding.utf8) {
                        return str
                    }
                }
            }
            return "nil"
        }
        list.append(.body(params))
    }
    
    mutating func addMethod(_ value: String) {
        list.append(.method(value))
    }
    
    mutating func addURL(_ value: String) {
        list.append(.url(value))
    }
    
    mutating func addResponse(_ result: Result<Moya.Response, Moya.MoyaError>) {
        switch result {
        case .success(let response):
            let dataString = String(data: response.data, encoding: .utf8) ?? ""
            list.append(.responseSuccess("状态: \(response.statusCode) \n" + "数据: \n" + dataString))
        case .failure(let error):
            list.append(.responseFailure("错误:" + GeneralError.from(error: error).message))
        }
    }
    
    var debugDescription: String {
        return list.sorted().reduce("\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>start", { (total, component) -> String in
            total + component.description
        })
    }
}

final class NetworkLogger: PluginType {
    
    var logger = RequestLogger()
    
    private var isStart: Bool = false
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        logger.clear()
        return request
    }
    
    func willSend(_ request: RequestType, target: TargetType) {
        logger.addHeader(request.request?.allHTTPHeaderFields ?? [:])
        logger.addMethod(request.request?.httpMethod ?? "nil")
        logger.addURL(request.request?.url?.absoluteString ?? "nil")
        logger.addBody(target.task)
        isStart = true
    }
    
    func didReceive(_ result: Result<Moya.Response, Moya.MoyaError>, target: TargetType) {
        logger.addResponse(result)
        
        // 避免此方法调用多次
        if isStart {
            isStart = false
            debugPrint(logger)
        }
    }
    
    
}
