//
//  ActivityCalendarView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/6.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class ActivityCalendarView: BaseView {
    
    var day: String = "" {
        didSet {
            dayLab.text = day
        }
    }
    
    var month: String = "" {
        didSet {
            monthLab.text = month
        }
    }
    
    private var monthLab = UILabel()
    private var dayLab = UILabel()
    
    override func setupView() {
        
        dayLab.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        dayLab.theme.textColor = UIColor.text
        dayLab.textAlignment = .center
        
        monthLab.font = UIFont.systemFont(ofSize: 14)
        monthLab.theme.textColor = UIColor.text
        monthLab.textAlignment = .center
        
        addSubviews(monthLab, dayLab)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let dayHeight: CGFloat = 24
        let monthHeight: CGFloat = 14
        dayLab.frame = CGRect(x: 0, y: (bounds.height - dayHeight - monthHeight)/2 , width: bounds.width, height: dayHeight)
        monthLab.frame = CGRect(x: 0, y: (bounds.height - monthHeight + dayHeight)/2, width: bounds.width, height: monthHeight)
    }
}
