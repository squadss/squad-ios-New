//
//  UITextField+Extension.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/21.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

// 给UITextField或UITextView添加inputAccessoryView
protocol InputAccessoryViewDelegate: class {
    var inputAccessoryView: UIView? { set get }
}

extension InputAccessoryViewDelegate {
    
    func setInputAccessoryView(title: String = "Done", target: Any?, selector: Selector) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        let spaceBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let completedB = UIButton(type: .system)
        completedB.setTitle(title, for: .normal)
        completedB.theme.titleColor(from: UIColor.text, for: .normal)
        completedB.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        completedB.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        completedB.addTarget(target, action: selector, for: .touchUpInside)
        
        let completedBtn = UIBarButtonItem(customView: completedB)
        completedBtn.tintColor = .blue
        toolbar.items = [spaceBtn, completedBtn]
        
        inputAccessoryView = toolbar
    }
}

extension UITextView: InputAccessoryViewDelegate {}
extension UITextField: InputAccessoryViewDelegate {}
