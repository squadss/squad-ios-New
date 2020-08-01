//
//  MultipleChooseTimeView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/18.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

// Frame.Origin.Y 固定为320
class MultipleChooseTimeView: BaseView {

    // 两个item之间的距离
    var margin: CGFloat = 9
    
    var axisView = TimeLineAxisView()
    var leftView = ActivityTimeLineView()
    var rightView = ActivityTimeLineView()
    
    override func setupView() {
        axisView.list = ["11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM"]
        axisView.insert = UIEdgeInsets(top: 15, left: 5, bottom: 24, right: 0)
        addSubviews(axisView, leftView, rightView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        axisView.frame = CGRect(x: 0, y: 4, width: 45, height: 300)
        let itemWidth = (bounds.width - axisView.frame.maxX - margin)/2
        leftView.frame = CGRect(x: axisView.frame.maxX, y: 0, width: itemWidth, height: 320)
        rightView.frame = CGRect(x: leftView.frame.maxX + margin, y: 0, width: itemWidth, height: 320)
    }
}
