//
//  UIColor+Squads.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import DynamicColor
import RxSwift
import RxTheme

extension UIColor {
    
    /// 主题色
    static var primary: Observable<UIColor?> {
        return themeService.attrStream { $0.primary }
    }
    
    static var primaryDark: Observable<UIColor?> {
        return themeService.attrStream { $0.primaryDark }
    }
    static var secondary: Observable<UIColor?> {
        return themeService.attrStream { $0.secondary }
    }
    static var secondaryDark: Observable<UIColor?> {
        return themeService.attrStream { $0.secondaryDark }
    }
    static var separator: Observable<UIColor?> {
        return themeService.attrStream { $0.separator }
    }
    static var text: Observable<UIColor?> {
        return themeService.attrStream { $0.text }
    }
    static var textGray: Observable<UIColor?> {
        return themeService.attrStream { $0.textGray }
    }
    static var background: Observable<UIColor?> {
        return themeService.attrStream { $0.background }
    }
}
