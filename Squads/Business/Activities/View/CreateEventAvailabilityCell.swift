//
//  CreateEventAvailabilityCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/11.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class CreateEventAvailabilityCell: BaseTableViewCell {
    
    var dateList: Array<Date>? {
        set {
            guard let dateList = newValue else { return }
            chooseTimeView.leftView.contentView?.dateList = dateList
            chooseTimeView.rightView.contentView?.dateList = dateList
            chooseTimeView.leftView.axisXDates = ActivityTimeLineAxisXDate(dateList: dateList.map{ $0.timeIntervalSince1970 })
            chooseTimeView.rightView.axisXDates = ActivityTimeLineAxisXDate(dateList: dateList.map{ $0.timeIntervalSince1970 })
        }
        get {
            return chooseTimeView.leftView.contentView?.dateList
        }
    }
    
    private var chooseTimeView = MultipleChooseTimeView()
    
    override func setupView() {
        
        let leftView = TimeLineDrawTapView()
        chooseTimeView.leftView.set(leftView)
        chooseTimeView.leftView.title = "SQUAD AVAILABILITY"
        chooseTimeView.leftView.headerTitleStyle.textColor = UIColor.textGray
        
        let rightView = TimeLineDrawPageView()
        rightView.color = .lightGray
        rightView.foregroundViewStyle.backgroundColor = UIColor(hexString: "#EC6256")
        chooseTimeView.rightView.set(rightView)
        chooseTimeView.rightView.title = "CLICK YOUR TIME"
        chooseTimeView.rightView.headerTitleStyle.textColor = UIColor.textGray
        
        contentView.addSubview(chooseTimeView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chooseTimeView.frame = CGRect(x: 20, y: 10, width: bounds.width - 40, height: bounds.height - 20)
    }
    
}
