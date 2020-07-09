//
//  BrickInputFieldStyle.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/9.
//  Copyright © 2020 Squads. All rights reserved.
//  方块形状的文本框样式

import UIKit

protocol BrickInputFieldStyle: class {
    func configInputField(_ textField: UITextField, placeholder: String)
}

extension BrickInputFieldStyle where Self: UIViewController {
    func configInputField(_ textField: UITextField, placeholder: String) {
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.clearButtonMode = .whileEditing
        textField.textColor = .white
        textField.tintColor = .white
        textField.leftViewMode = .always
        textField.inputAssistantItem.leadingBarButtonGroups = []
        textField.inputAssistantItem.trailingBarButtonGroups = []
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 40))
        if #available(iOS 13.0, *) {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
                .foregroundColor: UIColor(white: 1, alpha: 0.7),
                .font: UIFont.systemFont(ofSize: 16),
                .paragraphStyle: paragraphStyle
            ])
        } else {
            textField.placeholder = placeholder
            textField.setValue(UIColor(white: 1, alpha: 0.7), forKeyPath: "_placeholderLabel.textColor")
            textField.setValue(UIFont.systemFont(ofSize: 16), forKeyPath: "_placeholderLabel.font")
            textField.setValue(NSTextAlignment.left.rawValue, forKeyPath: "_placeholderLabel.textAlignment")
        }
    }
}
