//
//  MultipleChooseTimeView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/18.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

// Frame.Origin.Y 固定为320
class MultipleChooseTimeView: UIView {

    // 两个item之间的距离
    var margin: CGFloat = 9
    
    var axisView = TimeLineAxisControl()
    var displayView: ActivityTimeSectionView<TimeLineCollectionView>!
    private var drawView: ActivityTimeSectionView<TimeLineCollectionView>!
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        let pageView = TimeLineCollectionView()
        pageView.canEdit = true
        pageView.cellStyle = .normal
        
        let tapView = TimeLineCollectionView()
        tapView.cellStyle = .num
        
        displayView = ActivityTimeSectionView<TimeLineCollectionView>(itemView: tapView)
        displayView.title = "SQUAD AVAILABILIT"
        
        drawView = ActivityTimeSectionView<TimeLineCollectionView>(itemView: pageView)
        drawView.title = "CLICK YOUR TIME"
        
        addSubviews(axisView, displayView, drawView)
        
        axisView.scrollDidStop = { [unowned self] hour in
            let animated: Bool = self.isFirstSetData ? false : true
            pageView.scrollHalfHour(hour * 2, animated: animated)
            tapView.scrollHalfHour(hour * 2, animated: animated)
        }
        
        pageView.timePeriodsDidSelectedCompletion = { list in
            tapView.setDataSource(self.originList + list)
        }
    }
    
    private var originList = Array<TimePeriod>()
    private var isFirstSetData: Bool = true
    func setDataSource(myTime: Array<TimePeriod>, originList: Array<TimePeriod>) {
        
        self.originList = originList
        self.originList.removeAll(where: { myTime.contains($0) })
        
        drawView.itemView.setDataSource(myTime)
        displayView.itemView.setDataSource(originList)
        
        if isFirstSetData {
            axisView.scrollToCurrentDate()
            isFirstSetData = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        axisView.frame = CGRect(x: 0, y: 4, width: 55, height: 300)
        let itemWidth = (bounds.width - axisView.frame.maxX - margin)/2
        displayView.frame = CGRect(x: axisView.frame.maxX, y: 0, width: itemWidth, height: 320)
        drawView.frame = CGRect(x: displayView.frame.maxX + margin, y: 0, width: itemWidth, height: 320)
    }
}
