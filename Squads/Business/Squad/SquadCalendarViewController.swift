//
//  SquadCalendarViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import Hero

class SquadCalendarViewController: ReactorViewController<SquadCalendarReactor> {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.theme.backgroundColor = UIColor.background
    }
    

    override func setupView() {
        
        //自定义导航栏按钮
        let leftBtn = UIButton()
        leftBtn.setTitle("Cancel", for: .normal)
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        leftBtn.theme.titleColor(from: UIColor.text, for: .normal)
        leftBtn.addTarget(self, action: #selector(leftBtnDidTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        //自定义右导航按钮
        let rightBtn = UIButton()
        rightBtn.setTitle("Save", for: .normal)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        rightBtn.setTitleColor(UIColor(red: 0.925, green: 0.384, blue: 0.337, alpha: 1), for: .normal)
        rightBtn.addTarget(self, action: #selector(rightBtnBtnDidTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: 1000, height: 1000)
        view.addSubview(scrollView)
        
        let btn = UIButton()
        btn.addTarget(self, action: #selector(btnDidTapped), for: .touchUpInside)
        btn.backgroundColor = .red
        btn.hero.id = "batMan"
        btn.frame = CGRect(x: 100, y: 300, width: 300, height: 300)
        scrollView.addSubview(btn)
    }
    
    @objc
    private func btnDidTapped() {
        let reactor = ChattingReactor()
        let chattingVC = ChattingViewController(reactor: reactor)
        let nav = BaseNavigationController(rootViewController: chattingVC)
        nav.hero.isEnabled = true
        nav.hero.modalAnimationType = .selectBy(presenting: .fade, dismissing: .fade)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc
    private func leftBtnDidTapped() {
        dismiss(animated: true)
    }
    
    @objc
    private func rightBtnBtnDidTapped() {
        dismiss(animated: true)
    }
}

