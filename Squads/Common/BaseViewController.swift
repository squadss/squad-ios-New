//
//  BaseViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, CustomNavigationBarItem {

    // 创建自定义返回按钮
    var allowedCustomBackBarItem: Bool {
        return true
    }
    
    // 使用友盟统计
    var allowedEnableUMCommon: Bool {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if allowedEnableUMCommon {
            let stringClass = NSStringFromClass(self.classForCoder)
            MobClick.beginLogPageView(stringClass)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if allowedEnableUMCommon {
            let stringClass = NSStringFromClass(self.classForCoder)
            MobClick.beginLogPageView(stringClass)
        }
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
//        let backItem = UIBarButtonItem()
//        backItem.title = "Back"
//        backItem.style = .plain
//        navigationItem.backBarButtonItem = backItem
//        navigationController?.navigationBar.backIndicatorImage = UIImage()//backImage
//        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()//backImage
        
        let backImage = UIImage(named:"gener_navigation_back")?.withRenderingMode(.alwaysOriginal)
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        navigationItem.backBarButtonItem = backItem
    }
}
