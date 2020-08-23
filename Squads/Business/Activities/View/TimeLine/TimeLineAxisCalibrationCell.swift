//
//  TimeLineAxisCalibrationCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/16.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class TimeLineAxisCalibrationCell: BaseTableViewCell {

    var titleLab = UILabel()
    private var line = UIView()
    
    override func setupView() {
        
        titleLab.textAlignment = .center
        titleLab.theme.textColor = UIColor.secondary
        titleLab.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        
        line.backgroundColor = UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 1)
        contentView.addSubviews(titleLab, line)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLab.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 12)
        line.frame = CGRect(x: bounds.width/2 - 5, y: bounds.height/2 - 0.25 + 6, width: 10, height: 0.5)
    }
}
