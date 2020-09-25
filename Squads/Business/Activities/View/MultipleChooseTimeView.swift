//
//  MultipleChooseTimeView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/18.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// Frame.Origin.Y 固定为320
class MultipleChooseTimeView: UIView {

    // 两个item之间的距离
    var margin: CGFloat = 9
    
    var didEndSelectedTimeObservable: Observable<Array<TimePeriod>> {
        return drawView.itemView.didEndSelectedTimeObservable
    }
    
    private var axisView = TimeLineAxisControl(frame: CGRect(x: 0, y: 0, width: 60, height: 320))
    private var drawView: ActivityTimeSectionView<TimeLineCollectionView>!
    private var displayView: ActivityTimeSectionView<TimeLineCollectionView>!
    
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
        
        displayView = ActivityTimeSectionView(itemView: tapView)
        displayView.title = "SQUAD AVAILABILITY"
        
        drawView = ActivityTimeSectionView(itemView: pageView)
        drawView.title = "CLICK YOUR TIME"
        
        axisView.layout.indicatorsInsert = UIEdgeInsets(top: 6, left: 0, bottom: 36, right: 3)
        axisView.layout.topHandlerMarginTop = 3
        axisView.layout.bottomHanderMarginBottom = 34
        addSubviews(axisView, displayView, drawView)
        
        axisView.scrollDidStop = { [unowned self] hour in
            let animated: Bool = self.isFirstSetData ? false : true
            pageView.scrollHalfHour(hour * 2, animated: animated)
            tapView.scrollHalfHour(hour * 2, animated: animated)
        }
        
        pageView.timePeriodsDidSelectedCompletion = { myTime in
            print(myTime)
            tapView.setDataSource(self.exceptOwnList + myTime)
        }
    }
    
    // 除了我的其余所有的时间段数组
    private var exceptOwnList = Array<TimePeriod>()
    private var isFirstSetData: Bool = true
    func setDataSource(myTime: Array<TimePeriod>, originList: Array<TimePeriod>) {
        
        guard !originList.isEmpty else { return }
        
        displayView.itemView.setDataSource(originList)
        
        // 将自己选择的时间剔除掉, 便于在选择时间后, 重新加上选择的时间, 才是所有的时间
        var _originList = originList
        // myTime可能为空, 如果不是创建者而是参与者,他第一次进来就是空
        if !myTime.isEmpty {
            myTime.forEach {
                if let index = _originList.firstIndex(of: $0) {
                    _originList.remove(at: index)
                }
            }
            drawView.itemView.setDataSource(myTime)
        } else {
            drawView.itemView.setDataSource([], startOffTime: originList.first?.startOffTime)
        }
        self.exceptOwnList = _originList
        
        if isFirstSetData {
            axisView.scrollToAdaptDate(array: originList)
            isFirstSetData = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        axisView.frame.origin.y = 4
        axisView.frame.size.height -= 4
        let itemWidth = (bounds.width - axisView.frame.maxX - margin)/2
        displayView.frame = CGRect(x: axisView.frame.maxX, y: 0,
                                   width: itemWidth, height: axisView.frame.height)
        drawView.frame = CGRect(x: displayView.frame.maxX + margin, y: 0,
                                width: itemWidth, height: axisView.frame.height)
    }
}
