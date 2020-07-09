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

final class Application: NSObject {
    
    static let shared = Application()
    let authManager: AuthManager
    private var window: UIWindow?
    
    private override init() {
        authManager = AuthManager.shared
        super.init()
    }
    
    func presentInitialScreent(in window: UIWindow? = nil) {
        
        if let unwrappedWindow = window {
            self.window = unwrappedWindow
        }
        
//        if authManager.hasValidToken {
            let reactor = SquadReactor()
            let squadVC = SquadViewController(reactor: reactor)
            squadVC.title = "Squad Page"
            let nav = BaseNavigationController(rootViewController: squadVC)
            self.window?.rootViewController = nav
//        } else {
//            let reactor = LoginReactor()
//            let loginVC = LoginViewController(reactor: reactor)
//            let nav = UINavigationController(rootViewController: loginVC)
//            self.window?.rootViewController = nav
//        }
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


}

