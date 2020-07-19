//
//  ActivityDetailInfoView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/18.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class ActivityDetailInfoView: BaseView {
    
    // 标题按钮
    var titleBtn = UIButton()
    // 位置按钮
    var locationBtn = UIButton()
    // 预览图
    var previewBtn = UIButton()
    
    override func setupView() {
        
        locationBtn.setImage(UIImage(named: "Activity Location"), for: .normal)
        locationBtn.theme.titleColor(from: UIColor.textGray, for: .normal)
        locationBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        locationBtn.contentHorizontalAlignment = .left
        locationBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        
        previewBtn.imageView?.contentMode = .scaleAspectFit
        
        addSubviews(titleBtn, locationBtn, previewBtn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleBtn.frame = CGRect(x: 0, y: 0, width: 74, height: 26)
        previewBtn.frame = CGRect(x: bounds.width - 36, y: (bounds.height - 36)/2, width: 36, height: 36)
        locationBtn.frame = CGRect(x: 0, y: bounds.height - 44, width: previewBtn.frame.minX - 10, height: 40)
    }
}