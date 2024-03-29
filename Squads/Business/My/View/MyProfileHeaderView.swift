//
//  MyProfileHeaderView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/8.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class MyProfileHeaderView: BaseView {
    
    var avatarBtn = UIButton()
    var nicknameLab = UILabel()
    var contentLab = UILabel()
    
    var applyBtn = UIButton()
    private var line = UIView()
    private var titleLab = UILabel()
    
    override func setupView() {
        
        applyBtn.isHidden = true
        applyBtn.contentHorizontalAlignment = .right
        applyBtn.theme.titleColor(from: UIColor.secondary, for: .normal)
        applyBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        
        titleLab.text = "Squads"
        titleLab.theme.textColor = UIColor.text
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        nicknameLab.theme.textColor = UIColor.text
        nicknameLab.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        contentLab.theme.textColor = UIColor.textGray
        contentLab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        avatarBtn.imageView?.contentMode = .scaleAspectFill
        avatarBtn.imageView?.layer.cornerRadius = 24
        avatarBtn.imageView?.layer.masksToBounds = true
        
        line.theme.backgroundColor = UIColor.textGray
        addSubviews(avatarBtn, nicknameLab, contentLab, applyBtn, line, titleLab)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarBtn.frame = CGRect(x: 34, y: 0, width: 48, height: 48)
        nicknameLab.frame = CGRect(x: avatarBtn.frame.maxX + 16, y: 2, width: bounds.width - avatarBtn.frame.maxX - 20, height: 20)
        contentLab.frame = CGRect(x: nicknameLab.frame.minX, y: nicknameLab.frame.maxY, width: nicknameLab.frame.width, height: 17)
        line.frame = CGRect(x: 30, y: avatarBtn.frame.maxY + 25, width: bounds.width - 60, height: 0.5)
        titleLab.frame = CGRect(x: 34, y: line.frame.maxY + 10, width: 60, height: 14)
        applyBtn.frame = CGRect(x: bounds.width - 134, y: line.frame.maxY, width: 100, height: 37)
    }
}
