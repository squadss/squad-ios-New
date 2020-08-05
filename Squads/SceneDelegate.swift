//
//  SceneDelegate.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import JXPhotoBrowser

class AuthManager {
    
    static let shared = AuthManager()
    private var token = XAppToken()
    private let loggedIn = BehaviorRelay<Bool>(value: false)
    
    var hasValidToken: Bool {
        return token.isValid
    }
    
    var isLoggedIn: Observable<Bool> {
        return loggedIn.asObservable()
    }
    
    init() {
        loggedIn.accept(hasValidToken)
    }
    
    class func setToken(_ value: XAppToken) {
        AuthManager.shared.token = value
    }
    
    class func removeToken() {
        AuthManager.shared.token.token = nil
    }
}

enum ConnectStatus: Equatable {
    // 正在连接到腾讯云服务器
    case onConnecting
    // 连接成功
    case onConnectSuccess
    // 连接失败
    case onConnectFailed(String)
    // 被踢下线
    case onKickedOffline
    // 登录认证过期
    case onUserSigExpired
    // 用户资料更新
    case onSelfInfoUpdated(V2TIMUserFullInfo)
    
    static func == (lhs: ConnectStatus, rhs: ConnectStatus) -> Bool {
        switch (lhs, rhs) {
        case (.onConnecting, onConnecting),
             (.onConnectSuccess, .onConnectSuccess),
             (.onConnectFailed, .onConnectFailed),
             (.onKickedOffline, .onKickedOffline),
             (.onUserSigExpired, .onUserSigExpired):
            return true
        case (.onSelfInfoUpdated(let l), .onSelfInfoUpdated(let r)):
            return l.gender == r.gender
                && l.selfSignature == r.selfSignature
                && l.allowType == r.allowType
        default:
            return false
        }
    }
}

final class Application: NSObject {
    
    static let shared = Application()
    let authManager: AuthManager
    private var window: UIWindow?
    // 之所以用RelaySubject不用PublicSubject是因为需要在订阅时自动发送一次状态, 适用在用户先去登录页面, 这时connect流已经产生了, 当用户登录完成来到squad页面时, 就需要保存原来的流去唤醒它
    private var loginStatusDidChanged = ReplaySubject<ConnectStatus>.create(bufferSize: 1)
    
    private override init() {
        authManager = AuthManager.shared
        super.init()
        setupLibs()
    }
    
    func presentInitialScreent(in window: UIWindow? = nil) {
        
        if let unwrappedWindow = window {
            self.window = unwrappedWindow
        }
        
        if authManager.hasValidToken {
            if let squadId = UserDefaults.standard.topSquad {
                let reactor = SquadReactor(currentSquadId: squadId)
                reactor.loginStatusDidChanged = loginStatusDidChanged
                let squadVC = SquadViewController(reactor: reactor)
                let nav = BaseNavigationController(rootViewController: squadVC)
                self.window?.rootViewController = nav
            } else {
                let createSquadVC = CreateSquadViewController()
                createSquadVC.isShowLeftBarButtonItem = false
                let nav = BaseNavigationController(rootViewController: createSquadVC)
                self.window?.rootViewController = nav
            }
        } else {
            let reactor = LoginReactor()
            let loginVC = LoginViewController(reactor: reactor)
            let nav = UINavigationController(rootViewController: loginVC)
            self.window?.rootViewController = nav
        }
    }
    
    // 配置第三方启动库
    private func setupLibs() {
        setupIM()
    }
    
    private func setupIM() {
        // 配置IM
        let config = V2TIMSDKConfig()
        config.logLevel = .LOG_NONE
        V2TIMManager.sharedInstance()?.initSDK(App.Account.TIMAppKey, config: config, listener: self)
    }
}

//MARK: - 监听 V2TIMSDKListener 回调
extension Application: V2TIMSDKListener {
    
    // 连接腾讯云服务器失败
    func onConnectFailed(_ code: Int32, err: String!) {
        loginStatusDidChanged.onNext(.onConnectFailed(err))
    }
    
    // 已经成功连接到腾讯云服务器
    func onConnectSuccess() {
        loginStatusDidChanged.onNext(.onConnectSuccess)
    }
    
    // 正在连接到腾讯云服务器
    func onConnecting() {
        loginStatusDidChanged.onNext(.onConnecting)
    }
    
    /// 当前用户被踢下线，此时可以 UI 提示用户，并再次调用 V2TIMManager 的 login() 函数重新登录。
    func onKickedOffline() {
        loginStatusDidChanged.onNext(.onKickedOffline)
    }

    /// 在线时票据过期：此时您需要生成新的 userSig 并再次调用 V2TIMManager 的 login() 函数重新登录。
    func onUserSigExpired() {
        loginStatusDidChanged.onNext(.onUserSigExpired)
    }
    /// 当前用户的资料发生了更新
    func onSelfInfoUpdated(_ Info: V2TIMUserFullInfo!) {
        loginStatusDidChanged.onNext(.onSelfInfoUpdated(Info))
    }
}


@available(iOS 13, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
       
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .white
        Application.shared.presentInitialScreent(in: window)
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // 仅仅支持iOS 13以上的方法, 这里修改完记得修改appdelete中对应的方法
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
            return
        }
        
        if let webpageURL = userActivity.webpageURL {
            if webpageURL.host == App.AssociatedDomains {
                //获取邀请码
                if let code = pathComponentsParse(url: webpageURL, key: "invite") {
                    let reactor = WelcomeReactor(inviteCode: code)
                    let welcomeVC = WelcomeViewController(reactor: reactor)
                    let nav = BaseNavigationController(rootViewController: welcomeVC)
                    nav.modalPresentationStyle = .fullScreen
                    JXPhotoBrowser.topMost?.present(nav, animated: true)
                } else {
                    let view = UIApplication.shared.keyWindow
                    view?.showToast(message: "Your request could not be processed")
                }
            } else {
                UIApplication.shared.open(webpageURL, options: .init(), completionHandler: nil)
            }
        }
    }
    
    private func pathComponentsParse(url: URL, key: String) -> String? {
        let pathComponents = url.pathComponents
        guard pathComponents.count >= 2 else { return nil }
        for i in 0..<pathComponents.count {
            let pathComponent = pathComponents[i]
            if key == pathComponent && i != pathComponents.count - 1 {
                return pathComponents[i + 1]
            }
        }
        return nil
    }
}

