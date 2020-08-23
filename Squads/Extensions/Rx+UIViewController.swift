//
//  Rx+UIViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/15.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension RxSwift.Reactive where Base: UIViewController {
    public var viewDidLoad: Observable<Void> {
        return methodInvoked(#selector(UIViewController.viewDidLoad))
            .map { _ in return }
    }
    
    public var viewWillAppear: Observable<Void> {
        return methodInvoked(#selector(UIViewController.viewWillAppear))
            .map { _ in return }
    }
}

extension RxSwift.Reactive where Base: UIApplication {
    
    public var delegate: DelegateProxy<UIApplication, UIApplicationDelegate> {
        return RxApplicationDelegateProxy.proxy(for: base)
    }
    
    public var applicationWillEnterForeground: Observable<Void> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationWillEnterForeground(_:))).map{ _ in () }
    }
    
    public var applicationDidEnterBackground: Observable<Void> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationDidEnterBackground(_:)))
            .map { _ in () }
    }
}

open class RxApplicationDelegateProxy: DelegateProxy<UIApplication, UIApplicationDelegate>, DelegateProxyType, UIApplicationDelegate {
    
    // Typed parent object.
    public weak private(set) var application: UIApplication?
    
    init(application: ParentObject) {
        self.application = application
        super.init(parentObject: application, delegateProxy: RxApplicationDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxApplicationDelegateProxy(application: $0) }
    }
    
    public static func currentDelegate(for object: UIApplication) -> UIApplicationDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: UIApplicationDelegate?, to object: UIApplication) {
        object.delegate = delegate
    }
    
    override open func setForwardToDelegate(_ forwardToDelegate: UIApplicationDelegate?, retainDelegate: Bool) {
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: true)
    }
    
}
