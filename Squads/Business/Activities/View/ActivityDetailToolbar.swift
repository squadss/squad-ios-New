//
//  ActivityDetailToolbar.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/18.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ActivityDetailToolbar: BaseView {
    
    struct Description {
        
        var isLabel: Bool { return label != nil }
        var isButton: Bool { return button != nil }
        
        fileprivate var label: (text: String, color: UIColor, font: UIFont)?
        fileprivate var button: (flag: String, title: String?, image: UIImage?, showShadow: Bool)?
        
        /// 标题
        /// - Parameter text: 内容
        /// - Parameter color: 颜色 默认白色
        /// - Parameter font: 字体 默认14
        static func title(_ text: String,
                          color: UIColor = .white,
                          font: UIFont = .systemFont(ofSize: 14)) -> Description {
            var description = Description()
            description.label = (text, color, font)
            return description
        }
        
        
        /// 按钮样式
        /// - Parameter flag: 按钮标示, 在代理方法中会
        /// - Parameter title: 按钮标题
        /// - Parameter image: 按钮图片
        /// - Parameter showShadow: 是否显示阴影, 默认不显示
        static func button(flag: String,
                           title: String?,
                           image: UIImage?,
                           showShadow: Bool = false) -> Description {
            var description = Description()
            description.button = (flag, title, image, showShadow)
            return description
        }
    }
    
    // 按钮的圆角
    var buttonCornerRadius: CGFloat = 11
    // 单个按钮显示时, 按钮的尺寸
    var singleButtonSize: CGSize = CGSize(width: 88, height: 22)
    // 多个按钮并排显示时, 每个按钮对应的尺寸
    var multipleButtonSize: CGSize = CGSize(width: 44, height: 44)
    // 多个按钮并排显示时, 按钮之间的间距
    var multipleButtonMargin: CGFloat = 8
    
    // 内边距
    var padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 36, bottom: 0, right: 19)
    
    var dataSource: Array<Description>! {
        didSet {
            setupSubview()
        }
    }
    
    private var didTappedSubject = PublishSubject<String>()
    var didTapped: Observable<String> {
        return didTappedSubject.asObservable()
    }
    
    private func setupSubview() {
        
        subviews.forEach{ $0.removeFromSuperview() }
        
        if let description = dataSource.first(where: { $0.isLabel }) {
            let titleLab = createLab(from: description)
            addSubview(titleLab)
        }
        
        let buttons = dataSource.filter({ $0.isButton })
        if buttons.count > 1 {
            
            let list: Array<UIView> = buttons.map { (description)  in
                return createBtn(from: description)
            }
            
            let stackView = UIStackView(arrangedSubviews: list)
            stackView.axis = .horizontal
            stackView.spacing = multipleButtonMargin
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            addSubview(stackView)
        } else if buttons.count == 1 {
            let btn = createBtn(from: buttons.first!)
            addSubview(btn)
        }
    }
    
    private func createLab(from description: Description) -> UILabel {
        let lab = UILabel()
        guard let style = description.label else {
            return lab
        }
        lab.textColor = style.color
        lab.font = style.font
        lab.text = style.text
        lab.textAlignment = .left
        lab.numberOfLines = 1
        return lab
    }
    
    private func createBtn(from description: Description) -> UIButton {
        let btn = FlagButton()
        guard let style = description.button else {
            return btn
        }
        if let title = style.title {
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            btn.setTitle(title, for: .normal)
            btn.backgroundColor = .white
            btn.setTitleColor(backgroundColor, for: .normal)
        }
        if let image = style.image {
            btn.setImage(image, for: .normal)
        }
        if style.showShadow {
            btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            btn.layer.shadowOpacity = 1
            btn.layer.shadowRadius = 4
            btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
        btn.flag = style.flag
        btn.layer.cornerRadius = buttonCornerRadius
        btn.addTarget(self, action: #selector(btnDidTapped(sender:)), for: .touchUpInside)
        return btn
    }
    
    @objc
    private func btnDidTapped(sender: FlagButton) {
        didTappedSubject.onNext(sender.flag!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let label = subviews.first as? UILabel
        var button: UIView?
        switch subviews.last {
        case is UIStackView:
            button = subviews.last
            let stackView = button as! UIStackView
            let originWidth = CGFloat(stackView.arrangedSubviews.count - 1) * stackView.spacing + CGFloat(stackView.arrangedSubviews.count) * multipleButtonSize.width
            button?.frame = CGRect(x: bounds.width - padding.right - originWidth,
                                   y: (bounds.height - multipleButtonSize.height)/2,
                                   width: originWidth,
                                   height: multipleButtonSize.height)
        case is UIButton:
            button = subviews.last
            button?.frame = CGRect(x: bounds.width - padding.right - singleButtonSize.width,
                                   y: (bounds.height - singleButtonSize.height)/2,
                                   width: singleButtonSize.width,
                                   height: singleButtonSize.height)
        default: break
        }
        let buttonRect = button?.frame ?? CGRect(x: 10, y: 0, width: padding.right, height: 0)
        label?.frame = CGRect(x: padding.left, y: padding.top, width: buttonRect.minX - padding.left, height: bounds.height - padding.top - padding.bottom)
    }
}

fileprivate class FlagButton: UIButton {
    var flag: String?
}
