//
//  Runtime+Extension.swift
//  FlowerField
//
//  Created by 武飞跃 on 2020/3/31.
//  Copyright © 2020 武飞跃. All rights reserved.
//

import UIKit

/// Application 启动之后执行 Swizzed 操作
public protocol LoadWithApplicationLaunchedable {
    static func initializeLoad()
}

/// 初始化需要 Runtime 来 SwizzledReplace 的类型, 需要在 ApplicationDidLaunch 方法里面调用
///
/// - Parameter objcs: 类类型，Runtime交换的类类型
public func InitializeNSObjects(_ objcs: [LoadWithApplicationLaunchedable.Type]) {
    objcs.forEach { item in
        item.initializeLoad()
    }
}

/// Runtime交换两个方法的实现
///
/// - Parameters:
///   - cls: 类类型对象
///   - originalSelector: 原始方法
///   - swizzledSelector: 交换方法
public func SwizzledReplace(with cls: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    
    guard let originalMethod = class_getInstanceMethod(cls, originalSelector),
        let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector) else { return }
    
    let didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    
    // why this
    if didAddMethod {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

