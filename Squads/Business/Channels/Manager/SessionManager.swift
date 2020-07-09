//
//  SessionManager.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/9.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ImSDK

public struct ChatNotification {
//    public let receiver: Sender
    public let content: String?
    public let unreadCount: Int
}

final class SessionManager {
    
    static let `default` = SessionManager()
    
    public func register(accountType: String, appidAt3rd: Int32, completion: @escaping (ChatNotification) -> Void){
        
        let sdkConfig = TIMSdkConfig()
        sdkConfig.sdkAppId = appidAt3rd
        sdkConfig.disableLogPrint = true //禁止在控制台打印
        TIMManager.sharedInstance().initSdk(sdkConfig)
        
        let userConfig = TIMUserConfig()
        userConfig.enableReadReceipt = true //开启已读回执
//        userConfig.disableRecnetContact = true //不开启最近联系人
        TIMManager.sharedInstance().setUserConfig(userConfig)
        
        onResponseNotification(completion: completion)
        
    }
    
    //开启消息监听, 避免消息监听遗漏, 要放在登录方法调用之前
    private func onResponseNotification(completion: @escaping (ChatNotification) -> Void) {
        
//        centralManager.listenterMessages{ [unowned self] (receiverId, content, unreadCount) in
//            
//            self.userManager.queryFriendProfile(id: receiverId, result: { result in
//            
//                var sender: Sender {
//                    if case .success(let value) = result {
//                        return value
//                    }
//                    else {
//                        return Sender(id: receiverId)
//                    }
//                }
//                
//                let notification = ChatNotification(receiver: sender, content: content, unreadCount: unreadCount)
//                completion(notification)
//            })
//            
//        }
    }
}
