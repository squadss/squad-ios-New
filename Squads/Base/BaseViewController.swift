//
//  BaseViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, CustomNavigationBarItem {

    var allowedCustomBackBarItem: Bool {
        return true
    }
    
    var isStatusBarHidden: Bool = false {
        didSet {
            guard isStatusBarHidden != oldValue else { return }
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            guard statusBarStyle != oldValue else { return }
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
        
        if allowedCustomBackBarItem {
            setupBackBarItem()
        }
        
        setupView()
        setupConstraints()
        addTouchAction()
    }
    
    func initData() { }
    
    func setupView() { }
    
    func setupConstraints() {}
    
    func addTouchAction() { }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
}

protocol CustomNavigationBarItem: UIViewController {
    func setupBackBarItem()
}

extension CustomNavigationBarItem {
    
    func setupBackBarItem() {
        let backImage = UIImage(named:"navigation_back")?.withRenderingMode(.alwaysOriginal)
        let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        navigationItem.backBarButtonItem = backItem
    }
}
