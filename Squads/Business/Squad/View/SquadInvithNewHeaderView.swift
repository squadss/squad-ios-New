//
//  SquadInvithNewHeaderView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/19.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class SquadInvithNewHeaderView: BaseView {
    
    var insertBottom: CGFloat = 0
    var label = UILabel()
    var inviteBtn = CornersButton()
    
    var contentView: UIView! {
        didSet {
            oldValue?.removeFromSuperview()
            addSubview(contentView)
        }
    }
    
    override func setupView() {
        
        label.font = UIFont.systemFont(ofSize: 16)
        label.theme.textColor = UIColor.text
        label.textAlignment = .center
        label.text = "Who else is in your squad?"
        
        inviteBtn.radius = 2
        inviteBtn.setImage(UIImage(named: "Invite Link"), for: .normal)
        inviteBtn.setTitle("Invite to Group via Link", for: .normal)
        inviteBtn.setTitleColor(.white, for: .normal)
        inviteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        inviteBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        inviteBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        inviteBtn.setBackgroundImage(UIImage(color: UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 1)), for: .normal)
        
        addSubviews(inviteBtn, label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        inviteBtn.frame = CGRect(x: (bounds.width - 168)/2,
                                 y: bounds.height - 21 - 36 - insertBottom,
                                 width: 168, height: 36)
        
        label.frame = CGRect(x: 20, y: inviteBtn.frame.minY - 22 - 20,
                             width: bounds.width - 40, height: 20)
        
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: label.frame.minY)
    }
    
}
