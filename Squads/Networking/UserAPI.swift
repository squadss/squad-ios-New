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
    /* inviteCode: 绑定的邀请码 */
    /* nationCode: 国家（或地区）码 */
    /* phoneNumber: 手机号码，普通格式，示例如：13711112222。 */
    /* purePhoneNumber: +[国家或地区码][手机号] ，示例如：+8613711112222， 其中前面有一个+号 ，86为国家码 */
    /* avatar: 用户头像 */
    case signUp(username: String, password: String, inviteCode: String, nationCode: String, phoneNumber: String, purePhoneNumber: String, nickname: String, avatar: Data)
    
    // 用户登录
    case signIn(username: String, password: String)
    
    // 退出
    case logout
    
    /// 校验验证输入的验证码
    /* nationCode: 国家（或地区）码 */
    /* phoneNumber: 手机号码，普通格式，示例如：13711112222。 */
    /* purePhoneNumber: +[国家或地区码][手机号] 例如值为: "+86" */
    /* code: 验证码 */
    case verificationcode(nationCode: String, phoneNumber: String, purePhoneNumber: String, code: String)
    
    /// 通过手机号获取验证码
    /* nationCode: 国家（或地区）码 */
    /* phoneNumber: 手机号码，普通格式，示例如：13711112222。 */
    /* purePhoneNumber: +[国家或地区码][手机号] 例如值为: "+86" */
    /* code: 验证码 */
    case getverificationcode(nationCode: String, phoneNumber: String, purePhoneNumber: String, code: String)
    
    // 根据token获取系统登录用户信息
    case getAccountInfo
    
    // 获取账号id获取用户详情
    case account(id: String)
    
    /// 修改用户信息
    case update(phoneNumber: String?, nationCode: String?, password: String?, nickname: String?, gender: Gender?, avatar: Data?)
}

extension UserAPI: TargetType {
    
    var baseURL: URL {
        //115.159.208.16:8888/api
        return URL(string: "http://squad.wieed.com:8888/api/")!
    }
    
    var path: String {
        switch self {
        case .signUp:
            return "user/signup"
        case .signIn:
            return "user/signin"
        case .getAccountInfo:
            return "user/getLoginUserInfo"
        case .account(let id):
            return "user/account/" + id
        case .update:
            return "user/update"
        case .verificationcode:
            return "user/verificationCode"
        case .getverificationcode:
            return "user/getVerificationCode"
        case .logout:
            return "user/logout"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp, .signIn, .update, .verificationcode, .getverificationcode, .logout:
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
        case let .signUp(username, password, inviteCode, nationCode, phoneNumber, purePhoneNumber, nickname, avatarDate):
            var dic: [String: String] = [:]
            dic["username"] = username
            dic["password"] = password
            dic["rePassword"] = password
            dic["inviteCode"] = inviteCode
            dic["nationCode"] = nationCode
            dic["phoneNumber"] = phoneNumber
            dic["purePhoneNumber"] = purePhoneNumber
            dic["nickname"] = nickname
            dic["headimgBase64"] = avatarDate.base64EncodedString(options: .lineLength64Characters)
            return .requestParameters(parameters: dic, encoding: JSONEncoding.default)
        case let .signIn(username, password):
            var dic: [String: String] = [:]
            dic["username"] = username
            dic["password"] = password
            return .requestParameters(parameters: dic, encoding: JSONEncoding.default)
        case .getAccountInfo, .account, .logout:
            return .requestPlain
        case .verificationcode(let nationCode, let phoneNumber, let purePhoneNumber, let code):
            let params = ["nationCode": nationCode, "phoneNumber": phoneNumber, "purePhoneNumber": purePhoneNumber, "code": code]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getverificationcode(let nationCode, let phoneNumber, let purePhoneNumber, let code):
            let params = ["nationCode": nationCode, "phoneNumber": phoneNumber, "purePhoneNumber": purePhoneNumber, "code": code]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .update(let phoneNumber, let nationCode, let password, let nickname, let gender, let avatar):
            var params = Dictionary<String, Any>()
            phoneNumber.flatMap{ params["phoneNumber"] = $0 }
            nationCode.flatMap{ params["nationCode"] = $0 }
            password.flatMap{ params["password"] = $0 }
            nickname.flatMap{ params["nickname"] = $0 }
            gender.flatMap{ params["gender"] = $0.rawValue }
            avatar.flatMap{ params["headimgurl"] = $0.base64EncodedString(options: .lineLength64Characters) }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
