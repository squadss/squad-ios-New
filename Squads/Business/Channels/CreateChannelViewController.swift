//
//  CreateChannelViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/9/4.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class CreateChannelViewController: ReactorViewController<CreateChannelReactor> {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func setupView() {
        let createView = CreateChannelsView()
//        createView.bounds = CGRect(x: 0, y: 0, width: navView.bounds.width - 32, height: 357)
//        createView.center = CGPoint(x: navView.bounds.midX, y: navView.bounds.midY - 100)
        createView.backgroundColor = .white
        createView.layer.cornerRadius = 8
        createView.layer.shadowOpacity = 1
        createView.layer.shadowRadius = 20
        createView.layer.shadowOffset = CGSize(width: 0, height: 2)
        createView.layer.shadowColor = UIColor(red: 0.148, green: 0.141, blue: 0.512, alpha: 0.25).cgColor
//        self.createChannelsView = createView
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        let effectView = UIVisualEffectView(effect: blurEffect)
//        effectView.frame = navView.bounds
//        effectView.contentView.addSubview(createView)
//        navView.addSubview(effectView)
//
        createView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.25, animations: {
            createView.transform = CGAffineTransform.identity
        })
        
//        createView.confirmBtn.addTarget(self, action: #selector(createChannelConfirmBtnDidTapped(sender:)), for: .touchUpInside)
//        createView.closeBtn.addTarget(self, action: #selector(createChannelCloseBtnDidTapped), for: .touchUpInside)
    }
    
    override func bind(reactor: CreateChannelReactor) {
        
    }
    
}
