//
//  ActivityTimeLineView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/22.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

struct ActivityTimeLineAxisXDate {
    var dateList: Array<TimeInterval>
    var dateFormatter: (TimeInterval) -> String
    
    init(dateList: Array<TimeInterval>, dateFormatter: @escaping (TimeInterval) -> String = dateFormatter) {
        self.dateList = dateList
        self.dateFormatter = dateFormatter
    }
    
    static func dateFormatter(timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        let calendar = Calendar.current
        let dateComponets = calendar.dateComponents([.year, .month, .weekday, .day], from: date)
        switch dateComponets.weekday {
        case 1:
            // 星期天
            return "Sun"
        case 2:
            // 星期一
            return "Mon"
        case 3:
            //星期二
            return "Tues"
        case 4:
            //星期三
            return "Wed"
        case 5:
            //星期四
            return "Thur"
        case 6:
            //星期五
            return "Fri"
        case 7:
            //星期六
            return "Sat"
        default:
            return ""
        }
    }
}

struct ActivityTimeLineStyle {
    var font: UIFont
    var textAlignment: NSTextAlignment
    var textColor: Observable<UIColor?>
   
    static let small = ActivityTimeLineStyle(font: .systemFont(ofSize: 9, weight: .bold),
                                             textAlignment: .center,
                                             textColor: UIColor.secondary)
}

class ActivityTimeLineView: BaseView {
    
    // X轴时间列表
    var axisXDates: ActivityTimeLineAxisXDate! {
        didSet {
            prepareBottomLabels()
        }
    }
    
    // 标题
    var title: String! {
        didSet {
            titleLab.text = title
        }
    }
    
    // 头部样式
    var headerTitleStyle = ActivityTimeLineStyle.small {
        didSet {
            titleLab.textAlignment = headerTitleStyle.textAlignment
            titleLab.theme.textColor = headerTitleStyle.textColor
            titleLab.font = headerTitleStyle.font
        }
    }
    
    // X轴标题样式
    var axisXTitleStyle = ActivityTimeLineStyle.small
    
    private var titleLab = UILabel()
    private(set) var contentView: TimeLineDrawView?
    private var bottomStackView = UIStackView()
    private var pool = ReusePool<UILabel>()
    
    override func setupView() {
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.alignment = .fill
        addSubviews(titleLab, bottomStackView)
        headerTitleStyle = ActivityTimeLineStyle.small
    }
    
    func set(_ contentView: TimeLineDrawView) {
        self.contentView?.removeFromSuperview()
        addSubview(contentView)
        self.contentView = contentView
    }
    
    private func prepareBottomLabels() {
        pool.enqueue(views: bottomStackView.arrangedSubviews.map{ $0 as! UILabel })
        bottomStackView.arrangedSubviews.forEach {
            bottomStackView.removeArrangedSubview($0)
        }
        axisXDates.dateList.forEach { timeInterval in
            let label = pool.dequeue()
            label.font = axisXTitleStyle.font
            label.text = axisXDates.dateFormatter(timeInterval)
            label.textAlignment = axisXTitleStyle.textAlignment
            label.theme.textColor = axisXTitleStyle.textColor
            bottomStackView.addArrangedSubview(label)
        }
    }
  
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLab.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 17)
        contentView?.frame = CGRect(x: 0, y: titleLab.frame.maxY + 5, width: bounds.width, height: 250)
        let contentFrame = contentView?.frame ?? CGRect(x: 0, y: titleLab.frame.maxY + 5, width: 0, height: 0)
        bottomStackView.frame = CGRect(x: 0, y: contentFrame.maxY, width: bounds.width, height: 45)
    }
}
