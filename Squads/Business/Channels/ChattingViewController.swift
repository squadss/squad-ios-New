//
//  ChattingViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import Hero

class ChattingViewController: ReactorViewController<ChattingReactor> {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navBarBgAlpha = 0.0
//        self.navBarTintColor = .clear
        
        let btn = UIButton()
        btn.addTarget(self, action: #selector(btnDidTapped), for: .touchUpInside)
        btn.backgroundColor = .red
        btn.frame = CGRect(x: 100, y: 400, width: 200, height: 300)
        btn.hero.id = "batMan"
        view.addSubview(btn)
        
        view.theme.backgroundColor = UIColor.background
    }
    
    @objc
    private func btnDidTapped() {
        dismiss(animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let friendReactor = FriendProfileReactor()
        let friendVC = FriendProfileViewController(reactor: friendReactor)
        navigationController?.pushViewController(friendVC, animated: true)
    }
}
