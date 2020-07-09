//
//  MyProfileFooterView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/8.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MyProfileFooterView: BaseView {
    
    fileprivate struct Model {
        // 字体
        let title: String
        // 字体是否加粗
        let isBold: Bool
    }
    
    private var itemSubject = PublishSubject<String>()
    var itemSelected: Observable<String> {
        return itemSubject.asObservable()
    }
    
    var addTapped: Observable<Void> {
        return addBtn.rx.tap.asObservable()
    }
    
    private var addBtn = UIButton()
    private var stackView: UIStackView!
    private var line = CALayer()
    private var contentView = UIView()
    
    override func setupView() {
        
        let models = [Model(title: "Profile", isBold: false),
                      Model(title: "Notifications", isBold: false),
                      Model(title: "Invite Friends", isBold: false),
                      Model(title: "Help", isBold: false),
                      Model(title: "Log Out", isBold: true)]
        
        stackView = UIStackView(arrangedSubviews: models.enumerated().map { (index, model) -> UIView in
            let btn = UIButton()
            btn.tag = 100 + index
            btn.setTitle(model.title, for: .normal)
            btn.titleLabel?.font = model.isBold
                ? UIFont.systemFont(ofSize: 16, weight: .semibold)
                : UIFont.systemFont(ofSize: 16, weight: .regular)
            btn.theme.titleColor(from: UIColor.text, for: .normal)
            btn.contentHorizontalAlignment = .left
            btn.addTarget(self, action: #selector(itemDidTapped(sender:)), for: .touchUpInside)
            return btn
        })
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        addBtn.setTitle("New Squad", for: .normal)
        addBtn.setImage(UIImage(named: "Union Icon"), for: .normal)
        addBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        addBtn.theme.titleColor(from: UIColor.text, for: .normal)
        addBtn.contentHorizontalAlignment = .left
        addBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        addBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        
        line.theme.backgroundColor = UIColor.textGray.map{ $0?.cgColor }
        
        addSubviews(contentView)
        contentView.addSubviews(addBtn, stackView)
        contentView.layer.addSublayer(line)
        contentView.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 20, y: 0, width: UIScreen.main.bounds.width - 100, height: 20)
        gradientLayer.colors = [UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1).cgColor,
                                UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.3)
        layer.addSublayer(gradientLayer)
        backgroundColor = .clear
    }
    
    @objc
    private func itemDidTapped(sender: UIButton) {
        var text = ""
        switch sender.tag - 100 {
        case 0: text = "profile"
        case 1: text = "notifications"
        case 2: text = "inviteFrients"
        case 3: text = "help"
        case 4: text = "logOut"
        default: fatalError("没有配置")
        }
        itemSubject.onNext(text)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = CGRect(x: 0, y: 20, width: bounds.width, height: bounds.height - 20)
        addBtn.frame = CGRect(x: 34, y: 4, width: bounds.width - 68, height: 40)
        line.frame = CGRect(x: 30, y: addBtn.frame.maxY + 5, width: bounds.width - 60, height: 0.5)
        stackView.frame = CGRect(x: 34, y: line.frame.maxY + 13, width: bounds.width - 68, height: 160)
    }
}
