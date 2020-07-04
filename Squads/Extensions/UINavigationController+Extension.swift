//
//  UINavigationController+Extension.swift
//  FlowerField
//
//  Created by 武飞跃 on 2020/3/31.
//  Copyright © 2020 武飞跃. All rights reserved.
//

import UIKit

// navigationController 之前的一次判断 是否可以 pop
public protocol PopControlAble {
    func shouldPop(controller: UINavigationController) -> Bool
}

extension UINavigationController: UIGestureRecognizerDelegate {
    
    // left pan gesture
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let popController = self.topViewController as? PopControlAble,
            gestureRecognizer == self.interactivePopGestureRecognizer
            else { return true }
        
        return popController.shouldPop(controller: self)
    }
}

fileprivate var KInteractivePopGestureRecognizer: Void?

extension UINavigationController: LoadWithApplicationLaunchedable {
    
    public static func initializeLoad() {
        SwizzledReplace(
            with: UINavigationController.self,
            originalSelector: #selector(UINavigationBarDelegate.navigationBar(_:shouldPop:)),
            swizzledSelector: #selector(swizzled_navigationBar(_:shouldPop:)))
        
        SwizzledReplace(
            with: UINavigationController.self,
            originalSelector: #selector(viewWillAppear(_:)),
            swizzledSelector: #selector(swizzled_viewWillAppear(_:)))
    }
    
    @objc public func swizzled_viewWillAppear(_ animated: Bool) {
        self.swizzled_viewWillAppear(animated)
        
        // 引用避免释放
        objc_setAssociatedObject(self, &KInteractivePopGestureRecognizer, self.interactivePopGestureRecognizer, .OBJC_ASSOCIATION_ASSIGN)
        self.interactivePopGestureRecognizer?.delegate = self
        
        // 遇到 ImagePickerController 在 初始化的时候已经设置了 delegate，如果这里不做处理的话，ImagePickerController 就无效
        if self.delegate == nil {
            self.delegate = self
        }
    }
}

extension UINavigationController {
    
    // backButton tap
    @objc
    func swizzled_navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        
        guard let vc = self.topViewController, item == vc.navigationItem else { return true }
        
        guard let popController = vc as? PopControlAble else {
            return swizzled_navigationBar(navigationBar, shouldPop: item)
        }
        
        if popController.shouldPop(controller: self) { // if enable, call origin method
            return swizzled_navigationBar(navigationBar, shouldPop: item)
        } else { // if not, can't pop
            return false
        }
        
    }
    
}


/// 不需要导航栏
public protocol HideNaivationBarable {}

public protocol DisableInteractiveGestureable {}

extension UINavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let navi: Any? = navigationController
        let vc: Any? = viewController
        guard let _ = navi as? UINavigationController,
            let _ = vc as? UIViewController else { return }
        // 在extension 里重新定义一份，不依赖 APP config，iOS 10 之前的系统导航栏动画取消，防止系统的bug造成的navigationContoller里 VC栈数据混乱
        var needNavigationAnimation: Bool
        if #available(iOS 11, *) {
            needNavigationAnimation = true
        } else {
            needNavigationAnimation = false
        }
        navigationController.setNavigationBarHidden(viewController is HideNaivationBarable, animated: needNavigationAnimation)
    }
    
    //FIXME: - 如果重新定义了 UINavigationControllerDelegate，需要实现下面逻辑来解决 navigationController 跟视图
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let isEnabled = viewController != navigationController.viewControllers.first && !(viewController is DisableInteractiveGestureable)
        navigationController.interactivePopGestureRecognizer?.isEnabled = isEnabled
    }
}
