//
//  SingleChooseTimeView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/16.
//  Copyright © 2020 Squads. All rights reserved.
//  单列选择时间视图

import UIKit

// Frame.Origin.Y 固定为320
class SingleChooseTimeView: UIView {

    var axisView = TimeLineAxisControl()
    private(set) var sectionView: ActivityTimeSectionView<TimeLineCollectionView>!
    
    var currentSelectedTimes: TimePeriod? {
        return sectionView.itemView.currentSelectedTimes
    }
    
    init(cellStyle: TimeLineCollectionView.CellStyle) {
        super.init(frame: .zero)
        
        let collectionView = TimeLineCollectionView()
        switch cellStyle {
        case .dash:
            collectionView.canEdit = true
            collectionView.cellStyle = .dash
        case .num:
            collectionView.canEdit = true
            collectionView.cellStyle = .num
            collectionView.adjustSelectedRect = true
            collectionView.cancelChangedTimeWhenSelected = true
            collectionView.insertSelectedRect = UIEdgeInsets(top: -10, left: -5, bottom: 10, right: -5)
            
            collectionView.foregroundView?.pendingEvent.layer.cornerRadius = 9
            collectionView.foregroundView?.pendingEvent.layer.borderWidth = 8
            collectionView.foregroundView?.pendingEvent.layer.borderColor = UIColor.white.cgColor
            collectionView.foregroundView?.pendingEvent.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            collectionView.foregroundView?.pendingEvent.layer.shadowOpacity = 1
            collectionView.foregroundView?.pendingEvent.layer.shadowRadius = 4
            collectionView.foregroundView?.pendingEvent.layer.shadowOffset = CGSize(width: 0, height: 4)
        case .normal:
            break
        }
        
        sectionView = ActivityTimeSectionView(itemView: collectionView)
        sectionView.headerTitleStyle.textAlignment = .center
        sectionView.headerTitleStyle.textColor = UIColor.secondary
        sectionView.headerTitleStyle.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        axisView.indicatorsMarginRight = 5
        addSubviews(axisView, sectionView)
        
        axisView.scrollDidStop = { hour in
            collectionView.scrollHalfHour(hour * 2)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isFirstSetData: Bool = true
    func setDataSource(originList: Array<TimePeriod>) {
        
        sectionView.itemView.setDataSource(originList)
        
        if isFirstSetData {
            axisView.scrollToCurrentDate()
            isFirstSetData = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        axisView.frame = CGRect(x: 0, y: 4, width: 50, height: 300)
        sectionView.frame = CGRect(x: axisView.frame.maxX + 8, y: 0, width: bounds.width - axisView.frame.maxX, height: 320)
    }
}
