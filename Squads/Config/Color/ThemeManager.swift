//
//  ThemeManager.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxTheme

let globalStatusBarStyle = BehaviorRelay<UIStatusBarStyle>(value: .default)
let themeService = ThemeType.service(initial: ThemeType.currentTheme())

enum ThemeType: ThemeProvider {
    
    case light
    case dark
    
    var associatedObject: Theme {
        switch self {
        case .light: return LightTheme()
        case .dark: return DarkTheme()
        }
    }
    
    var isDark: Bool {
        switch self {
        case .dark: return true
        default: return false
        }
    }
    
    /// 切换主题类型
    func toggled() -> ThemeType {
        var theme: ThemeType
        switch self {
        case .light: theme = .dark
        case .dark: theme = .light
        }
        theme.save()
        return theme
    }
    
    /// 保存主题
    func save() {
        UserDefaults.standard.isDark = isDark
    }
    
    static func currentTheme() -> ThemeType {
        
        var theme: ThemeType
        
        if UserDefaults.standard.isDark {
            theme = ThemeType.dark
        } else {
            theme = ThemeType.light
        }
        
        theme.save()
        return theme
    }
}

protocol Theme {
    var primary: UIColor { get }
    var primaryDark: UIColor { get }
    var secondary: UIColor { get }
    var secondaryDark: UIColor { get }
    var separator: UIColor { get }
    var text: UIColor { get }
    var textGray: UIColor { get }
    var background: UIColor { get }
    var statusBarStyle: UIStatusBarStyle { get }
    var barStyle: UIBarStyle { get }
    var keyboardAppearance: UIKeyboardAppearance { get }
    var blurStyle: UIBlurEffect.Style { get }
}

struct LightTheme: Theme {
    
    var text: UIColor = UIColor(hexString: "#2c2f36")
    
    var textGray: UIColor = UIColor(hexString: "#666666")
    
    var background: UIColor = .white
    
    var primaryDark: UIColor = .white
    
    var secondary: UIColor = .white
    
    var secondaryDark: UIColor = .white
    
    var primary: UIColor = UIColor.white
    
    var separator: UIColor = UIColor.lightGray
    
    var statusBarStyle: UIStatusBarStyle = .default
    
    var barStyle: UIBarStyle = .default
    
    var keyboardAppearance: UIKeyboardAppearance = .light
    
    var blurStyle: UIBlurEffect.Style = .extraLight
    
}

struct DarkTheme: Theme {
    
    var primaryDark: UIColor = .black
    
    var secondary: UIColor = .black
    
    var secondaryDark: UIColor = .black
    
    var text: UIColor = .black
    
    var textGray: UIColor = .black
    
    var background: UIColor = .black
    
    var primary: UIColor = .black
    
    var separator: UIColor = .lightGray
    
    var statusBarStyle: UIStatusBarStyle = .lightContent
    
    var barStyle: UIBarStyle = .black
    
    var keyboardAppearance: UIKeyboardAppearance = .dark
    
    var blurStyle: UIBlurEffect.Style = .dark
    
}

extension Reactive where Base: UIApplication {
    
    var statusBarStyle: Binder<UIStatusBarStyle> {
        return Binder(self.base) { view, attr in
            globalStatusBarStyle.accept(attr)
        }
    }
    
}
