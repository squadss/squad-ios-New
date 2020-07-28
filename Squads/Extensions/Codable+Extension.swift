//
//  Codable+Extension.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import Moya

// 添加编码的方法
extension Encodable {
    
    /// 遵守Codable协议的对象转json字符串
    func toJSONString(encoder: JSONEncoder = JSONEncoder()) -> String? {
        guard let data = toData(encoder: encoder) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// 对象转换成jsonObject
    func toJSONObject(encoder: JSONEncoder = JSONEncoder(), options: JSONSerialization.ReadingOptions = .allowFragments) -> Any? {
        guard let data = try? encoder.encode(self) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: options)
    }
    
    /// 转为字典(只有第一层可以转, 如果属性为结构体属性, 则失败, 参考: https://hisoka0917.github.io/swift/2018/10/19/convert-struct-to-dictionary/)
    func toDictionary(encoder: JSONEncoder = JSONEncoder(), options: JSONSerialization.ReadingOptions = .allowFragments) -> [String: Any]? {
        return toJSONObject(encoder: encoder, options: options) as? [String: Any]
    }
    
    /// 将对象转为data
    func toData(encoder: JSONEncoder = JSONEncoder()) -> Data? {
        return try? encoder.encode(self)
    }
}


//添加解码的方法
extension Decodable {
    
    /// json字符串转对象&数组
    static func decodeJSON(from string: String?, designatedPath: String? = nil, decoder: JSONDecoder = JSONDecoder()) throws -> Self {
        
        guard let data = string?.data(using: .utf8) else {
            throw GeneralError.mapping("数据解析失败")
        }
        
        let jsonData = getInnerObject(inside: data, by: designatedPath)
        
        if let unwrappedJSonData = jsonData {
            return try decoder.decode(Self.self, from: unwrappedJSonData)
        }
        else {
            throw GeneralError.mapping("数据解析失败")
        }
    }
    
    /// jsonObject转换对象或者数组
    static func decodeJSON(from jsonObject: Any?, designatedPath: String? = nil, decoder: JSONDecoder = JSONDecoder()) -> Self? {
        guard let unwrappedJsonObject = jsonObject, JSONSerialization.isValidJSONObject(unwrappedJsonObject) else {
            return nil
        }
        let data = try? JSONSerialization.data(withJSONObject: unwrappedJsonObject, options: [])
        let jsonData = getInnerObject(inside: data, by: designatedPath)

        if let unwrappedJSonData = jsonData {
            return try? decoder.decode(Self.self, from: unwrappedJSonData)
        }
        
        return nil
    }
    
    /// 将data映射为model
    static func decodeJSON(from data: Data, decoder: JSONDecoder = JSONDecoder()) throws -> Self {
        return try decoder.decode(Self.self, from: data)
    }
    
    static func decodeJSON(from response: Response, designatedPath: String? = nil, decoder: JSONDecoder = JSONDecoder()) throws -> Self {
        
        let data = response.data
        
        let serializeToData: (Any) throws -> Data? = { (jsonObject) in
            guard JSONSerialization.isValidJSONObject(jsonObject) else {
                return nil
            }
            do {
                return try JSONSerialization.data(withJSONObject: jsonObject)
            } catch {
                throw MoyaError.jsonMapping(response)
            }
        }
        
        let jsonData: Data
        keyPathCheck: if let keyPath = designatedPath {
            
            let json = try response.mapJSON()
            
            let object = getInnerObject(inside: json, by: keyPath)
            
            guard let jsonObject = object else {
                jsonData = data
                break keyPathCheck
            }
            
            if jsonObject is NSNull {
                do {
                    if let data = try serializeToData(json) {
                        let message = try decoder.decode(GeneralModel.Plain.self, from: data).message
                        throw MoyaError.requestMapping(message)
                    }
                } catch let error {
                    throw MoyaError.objectMapping(error, response)
                }
            }
            
            if let data = try serializeToData(jsonObject) {
                jsonData = data
            } else {
                let wrappedJsonObject = ["value": jsonObject]
                let wrappedJsonData: Data
                if let data = try serializeToData(wrappedJsonObject) {
                    wrappedJsonData = data
                } else {
                    throw MoyaError.jsonMapping(response)
                }
                do {
                    return try decoder.decode(DecodableWrapper<Self>.self, from: wrappedJsonData).value
                } catch let error {
                    throw MoyaError.objectMapping(error, response)
                }
            }
        } else {
            jsonData = data
        }
        do {
            if jsonData.count < 1 {
                if let emptyJSONObjectData = "{}".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(Self.self, from: emptyJSONObjectData) {
                    return emptyDecodableValue
                } else if let emptyJSONArrayData = "[{}]".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(Self.self, from: emptyJSONArrayData) {
                    return emptyDecodableValue
                }
            }
            return try decoder.decode(Self.self, from: jsonData)
        } catch let error {
            throw MoyaError.objectMapping(error, response)
        }
    }
}


private struct DecodableWrapper<T: Decodable>: Decodable {
    let value: T
}

fileprivate func getInnerObject(inside jsonData: Data?, by designatedPath: String? = nil) -> Data? {
    guard let unwrappedJsonData = jsonData, let path = designatedPath else {
        return jsonData
    }
    let jsonObject = try? JSONSerialization.jsonObject(with: unwrappedJsonData, options: .allowFragments)
    let object = getInnerObject(inside: jsonObject, by: path)
    return object.flatMap({ try? JSONSerialization.data(withJSONObject: $0, options: []) })
}

fileprivate func getInnerObject(inside object: Any?, by designatedPath: String?) -> Any? {
    var result: Any? = object
    var abort = false
    
    //以"."字符分割字符串
    if let paths = designatedPath?.components(separatedBy: "."), paths.count > 0 {
        var next = object as? [String: Any]
        paths.forEach({ (seg) in
            if seg.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" || abort {
                return
            }
            if let _next = next?[seg] {
                result = _next
                next = _next as? [String: Any]
            } else {
                abort = true
            }
        })
    }
    return abort ? nil : result
}
