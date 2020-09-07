//
//  ActivityTimeLineView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/22.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

struct ActivityTimeSectionStyle {
    var font: UIFont
    var textAlignment: NSTextAlignment
    var textColor: Observable<UIColor?>
   
    static let small = ActivityTimeSectionStyle(font: .systemFont(ofSize: 9, weight: .bold), textAlignment: .center, textColor: UIColor.secondary)
}

class ActivityTimeSectionView<T: UIView>: UIView {
    
    struct AxisXDate {
        var dateList: Array<Date>
        var dateFormatter: (Date) -> String
        
        init(dateList: Array<Date>, dateFormatter: @escaping (Date) -> String = dateFormatter) {
            self.dateList = dateList
            self.dateFormatter = dateFormatter
        }
        
        static func dateFormatter(date: Date) -> String {
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
    
    // X轴时间列表
    var axisXDates = AxisXDate(dateList: []) {
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
    var headerTitleStyle = ActivityTimeSectionStyle.small {
        didSet {
            titleLab.textAlignment = headerTitleStyle.textAlignment
            titleLab.theme.textColor = headerTitleStyle.textColor
            titleLab.font = headerTitleStyle.font
        }
    }
    
    // X轴标题样式
    var axisXTitleStyle = ActivityTimeSectionStyle.small
    
    private var titleLab = UILabel()
    private(set) var itemView: T!
    private var bottomStackView = UIStackView()
    private var pool = ReusePool<UILabel>()
    
    init(itemView: T) {
        super.init(frame: .zero)
        self.itemView = itemView
        addSubview(itemView)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.alignment = .fill
        addSubviews(titleLab, bottomStackView)
        headerTitleStyle = ActivityTimeSectionStyle.small
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
        itemView?.frame = CGRect(x: 0, y: titleLab.frame.maxY + 5, width: bounds.width, height: 250)
        let contentFrame = itemView?.frame ?? CGRect(x: 0, y: titleLab.frame.maxY + 5, width: 0, height: 0)
        bottomStackView.frame = CGRect(x: 0, y: contentFrame.maxY, width: bounds.width, height: 45)
    }
}
