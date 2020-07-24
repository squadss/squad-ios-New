//
//  UIViewController+CustomTitleView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/19.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

/**
 
         let titleView = NavigationBarTitleView()
         titleView.button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
         titleView.button.setTitle("Squad Page", for: .normal)
         titleView.button.theme.titleColor(from: UIColor.text, for: .normal)
         titleView.button.addTarget(self, action: #selector(titleBtnDidTapped), for: .touchUpInside)
         titleView.insert = UIEdgeInsets.zero
         addToTitleView(titleView)
 
 */
extension BaseViewController {
    
    func addToTitleView(_ subview: UIView) {
        
        if subview.frame == .zero {
            subview.frame = CGRect(x: 0, y: 0, width: 150, height: 44)
        }
        
        let titleView = CustomNavigtaionTitleView(frame: subview.frame)
        titleView.clipsToBounds = true
        titleView.menuView = subview
        navigationItem.titleView = titleView
    }
}


fileprivate class CustomNavigtaionTitleView: BaseView {
    
    var menuView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            menuView.flatMap{ addSubview($0) }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        menuView?.frame = bounds
    }
}

class NavigationBarTitleView: BaseView {
    
    var button = UIButton()
    var insert = UIEdgeInsets.zero
    
    override func setupView() {
        addSubview(button)
    }
    
    override func layoutSubviews() {
        button.frame = CGRect(x: insert.left, y: insert.top,
                              width: bounds.width - insert.left - insert.right,
                              height: bounds.height - insert.top - insert.bottom)
    }
}
