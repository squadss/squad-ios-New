//
//  CreateEventLocationCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/31.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class CreateEventLocationCell: BaseTableViewCell {
    
    var titleLab = UILabel()
    var contentLab = UILabel()
    var iconView = UIImageView()
    
    override func setupView() {
        
        titleLab.theme.textColor = UIColor.text
        titleLab.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLab.numberOfLines = 1
        
        contentLab.theme.textColor = UIColor.textGray
        contentLab.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        contentLab.numberOfLines = 1
        
        iconView.contentMode = .center
        contentView.addSubviews(contentLab, titleLab, iconView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconView.frame = CGRect(x: 6, y: (bounds.height - 50)/2, width: 50, height: 50)
        titleLab.frame = CGRect(x: iconView.frame.maxX + 6, y: 10, width: bounds.width - iconView.frame.maxX - 12, height: 20)
        contentLab.frame = CGRect(x: titleLab.frame.minX, y: titleLab.frame.maxY + 10, width: titleLab.frame.width, height: 20)
    }
}
