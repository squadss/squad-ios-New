//
//  SingleChooseTimeView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/16.
//  Copyright © 2020 Squads. All rights reserved.
//  单列选择时间视图

import UIKit

// Frame.Origin.Y 固定为320
class SingleChooseTimeView: BaseView {

    var axisView = TimeAxisView()
    var contentView = SlidableTimeView()
    
    override func setupView() {
        
        contentView.headerTitleStyle.textAlignment = .center
        contentView.headerTitleStyle.textColor = UIColor.secondary
        contentView.headerTitleStyle.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        axisView.list = ["11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM"]
        axisView.insert = UIEdgeInsets(top: 15, left: 5, bottom: 24, right: 0)
        axisView.isHiddenLine = true
        addSubviews(axisView, contentView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        axisView.frame = CGRect(x: 0, y: 4, width: 45, height: 300)
        contentView.frame = CGRect(x: axisView.frame.maxX, y: 0, width: bounds.width - axisView.frame.maxX, height: 320)
    }
}
