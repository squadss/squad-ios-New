//
//  SquadPreViewCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class SquadPreViewCell: BaseTableViewCell {
    
    var titleLab = UILabel()
    private var attachView = UIImageView()
    
    override func setupView() {
        
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLab.theme.textColor = UIColor.textGray
        titleLab.theme.highlightedTextColor = UIColor.secondary
        
        attachView.contentMode = .center
        attachView.image = UIImage(named: "Cell Attach")
        
        contentView.addSubviews(titleLab, attachView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLab.frame = CGRect(x: 73, y: (bounds.height - 20)/2, width: 200, height: 20)
        attachView.frame = CGRect(x: bounds.width - 73 - 15, y: (bounds.height - 15)/2, width: 15, height: 15)
    }
}
