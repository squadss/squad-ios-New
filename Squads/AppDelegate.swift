//
//  AppDelegate.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import MonkeyKing
import ImSDK
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// 判断程序是通过icon主屏幕图标打开的还是通过推送消息打开的
    private var isLaunchedByNotification: Bool = false
    
    static var shared: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 在初始化的时候替换默认方法
        InitializeNSObjects([
            UINavigationController.self
        ])
        
        // 配置IM
        let config = TIMSdkConfig()
        config.sdkAppId = 1400144517
        config.disableLogPrint = false //禁止在控制台打印
        TIMManager.sharedInstance()?.initSdk(config)
        
        //注册远程推送
        registerNotification(launchOptions)
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if MonkeyKing.handleOpenURL(url) {
            return true
        }
        return false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        var unreadCount: Int32 = 0
        if let conversations = TIMManager.sharedInstance()?.getConversationList() {
            unreadCount = conversations.reduce(0) { (total, conversation) -> Int32 in
                return total + conversation.getUnReadMessageNum()
            }
        }
        
        let param = TIMBackgroundParam()
        param.groupUnread = unreadCount
        TIMManager.sharedInstance()?.doBackground(param, succ: {
            //TODO:
        }, fail: { (code, message) in
            print("Message: \(String(describing: message))")
        })
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        TIMManager.sharedInstance()?.doForeground({
            //TODO:
        }, fail: { (code, message) in
            print("Message: \(String(describing: message))")
        })
    }
    
    //接收到推送
    private func alreadyDidReceiveNotificaction(application: Any, userInfo: [AnyHashable : Any]) {
        //程序关闭状态点击推送消息打开
        if isLaunchedByNotification {
            //TODO:
            
        } else {
            //前台运行
            if UIApplication.shared.applicationState == .active {
                //处于前台不处理
//                EMClient.shared()?.application(application, didReceiveRemoteNotification: userInfo)
//                TIMManager.sharedInstance()?.setAPNS(<#T##config: TIMAPNSConfig!##TIMAPNSConfig!#>, succ: <#T##TIMSucc!##TIMSucc!##() -> Void#>, fail: <#T##TIMFail!##TIMFail!##(Int32, String?) -> Void#>)
            }
            else {
                //TODO:
            }
            
            //收到推送消息手机振动
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            //收到推送消息播放音效
            AudioServicesPlaySystemSoundWithCompletion(1007) {}
        }
        
        //设置应用程序角标为0
//        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    //将得到的deviceToken传给SDK
    func registerAPNS(with deviceToken: Data) {
        DispatchQueue.global().async {
            let param = TIMTokenParam()
            param.token = deviceToken
            TIMManager.sharedInstance()?.setToken(param, succ: {
                //TODO:
            }, fail: { (code, message) in
                print("注册token失败: \(String(describing: message))")
            })
        }
    }
    
    //MARK: - 推送申请授权
    
    /// 注册推送
    func registerNotification(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        if let _ = launchOptions?[.remoteNotification] as? [String: Any?] {
            self.isLaunchedByNotification = true
        }
        else {
            self.isLaunchedByNotification = false
        }
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        //获取通知设置消息
        center.getNotificationSettings { (setting) in
            
            if setting.authorizationStatus == .notDetermined {
                //用户还没有决定应用程序是否可以发布用户通知。
                
                //TODO: 弹出授权框
                //申请授权
                center.requestAuthorization(options: [.alert, .badge, .sound]) { (isCompleted, error) in
                    if error == nil {
                        print("注册成功")
                    }
                }
                
            }
            //用户不同意授权
            else if setting.authorizationStatus == .denied {
                guard let appSettingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                
                let alertVC = UIAlertController(title: "友情提示",
                                                message: "建议您开启通知功能，以便及时获取相关信息",
                                                preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "忽略", style: .cancel, handler: nil))
                alertVC.addAction(UIAlertAction(title: "去开启", style: .default, handler: { _ in
                    if UIApplication.shared.canOpenURL(appSettingsURL) {
                        UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
                    }
                }))
                
                let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                rootViewController?.present(alertVC, animated: true)
            }
        }
    }
    
    //MARK: - 准备注册推送通知
    //用户同意后，会调用此程序，获取系统的deviceToken，应把deviceToken传给服务器保存，此函数会在程序每次启动时调用(前提是用户允许通知)：
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //保存到本地并上传到服务器
        registerAPNS(with: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //注册远程推送遇到失败了
        print("注册失败")
    }
    
    
    //MARK: - 有通知过来，需要调用方法处理结果
    
    /// iOS 10 以下
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        alreadyDidReceiveNotificaction(application: application, userInfo: userInfo)
        completionHandler(.newData)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
   
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        alreadyDidReceiveNotificaction(application: UIApplication.shared, userInfo: userInfo)
        
        completionHandler()
    }
}
