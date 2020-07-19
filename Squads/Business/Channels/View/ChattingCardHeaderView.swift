//
//  ChattingCardHeaderView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/11.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class ChattingCardHeaderView: BaseView {
    
    var titleLab = UILabel()
    var switchBtn = UIButton()
    
    override func setupView() {
        
        titleLab.text = "Chat"
        titleLab.textColor = .black
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        
        switchBtn.setImage(UIImage(named: "Channels Up"), for: .normal)
        switchBtn.setImage(UIImage(named: "Channels Back"), for: .selected)
        
        addSubviews(titleLab, switchBtn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLab.frame = CGRect(x: 33, y: (bounds.height - 17)/2, width: 50, height: 17)
        switchBtn.frame = CGRect(x: bounds.width - 70, y: 0, width: 70, height: bounds.height)
    }
}
