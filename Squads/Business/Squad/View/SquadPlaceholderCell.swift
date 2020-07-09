//
//  SquadPlaceholderCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class SquadPlaceholderCell: BaseTableViewCell {
    
    var content: String? {
        didSet {
            descriptionLab.text = content
        }
    }
    
    private var descriptionLab = UILabel()
    
    override func setupView() {
        descriptionLab.textAlignment = .center
        descriptionLab.font = UIFont.systemFont(ofSize: 16)
        descriptionLab.theme.textColor = UIColor.textGray
        contentView.addSubview(descriptionLab)
        descriptionLab.snp.makeConstraints { (maker) in
            maker.leading.trailing.centerY.equalToSuperview()
        }
    }
}
