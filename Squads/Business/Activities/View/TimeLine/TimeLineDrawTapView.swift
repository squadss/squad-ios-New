//
//  TimeLineTapView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/22.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimeLineDrawTapView: TimeLineDrawView {
    
    private var longGestureRecognizer = UILongPressGestureRecognizer()
    
    override func setupView() {
        super.setupView()
        longGestureRecognizer.addTarget(self, action: #selector(handleResizeHandleLongResture(_:)))
        longGestureRecognizer.cancelsTouchesInView = true
        addGestureRecognizer(longGestureRecognizer)
    }
    
    @objc
    private func handleResizeHandleLongResture(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            break
        case .ended, .cancelled:
            break
        default:
            break
        }
    }
}

extension Reactive where Base: TimeLineDrawTapView {
    var dataSource: Binder<Array<TimePeriod>> {
        return Binder(base) { drawView, timePeriods in
            //绘制前, 先清空画板
            drawView.clearColors()
            
            var firstTime: TimePeriod?
            var dateList = Array<Date>()
            for time in timePeriods.sorted(by: { $0.middleDate < $1.middleDate }) {
                if let unwrappedFirstTime = firstTime {
                    if !unwrappedFirstTime.middleDate.isSameDay(with: time.middleDate) {
                        dateList.append(time.middleDate)
                    }
                } else {
                    firstTime = time
                    dateList.append(time.middleDate)
                }
            }
            
            drawView.dateList = dateList
            
            timePeriods.forEach{
                drawView.draw(period: $0)
            }
        }
    }
}
