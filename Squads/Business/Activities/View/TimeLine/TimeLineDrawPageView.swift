//
//  TimeLinePageView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/20.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

class TimeLineDrawPageStyle {
    var backgroundColor: UIColor = .red
    var layerColor: UIColor = .clear
    var layerWidth: CGFloat = 0
}

class TimeLineDrawPageView: TimeLineDrawView {
    
    var foregroundViewStyle = TimeLineDrawPageStyle()
    
    private var timePeriodSubject = PublishSubject<TimePeriod>()
    var timePeriodObservable: Observable<TimePeriod> {
        return timePeriodSubject.asObservable()
    }
    
    private let key = "SelectLayerKey"
    private var commonLayer: TimeLineLayer?
    
    override var startOffTime: Int {
        didSet {
            let changed: CGFloat = -CGFloat(startOffTime - oldValue) * gridHeight * 2
            commonLayer?.rect.origin.y += changed
            pendingEvent?.frame.origin.y += changed
        }
    }
    
    private var prevOffset: CGPoint = .zero
    private var pendingEvent: UIView?
    private var lockSlideDirection: Bool?
    private var panGestureRecognizer = UIPanGestureRecognizer()
    
    override func setupView() {
        super.setupView()
        panGestureRecognizer.addTarget(self, action: #selector(handleResizeHandlePanGesture(_:)))
        panGestureRecognizer.cancelsTouchesInView = true
        addGestureRecognizer(panGestureRecognizer)
    }
    
    // 传入一个区域开始绘制矩形, 传入 .zero 表示清空画板
    private func draw(with rect: CGRect) {
        if commonLayer == nil {
            commonLayer = insertColor(color.uiColor, key: key)
        }
        commonLayer?.rect = rect
    }
    
    @objc
    func handleResizeHandlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        if sender.state == .began {
            
            if pendingEvent == nil {
                let eventView = UIView()
                let location = sender.location(in: self)
                eventView.backgroundColor = foregroundViewStyle.backgroundColor
                eventView.layer.borderColor = foregroundViewStyle.layerColor.cgColor
                eventView.layer.borderWidth = foregroundViewStyle.layerWidth
                addSubview(eventView)
                eventView.frame = CGRect(x: adjustOriginXOrderFloor(location.x),
                                         y: adjustOriginYOrderFloor(location.y),
                                         width: gridWidth, height: gridHeight)
                pendingEvent = eventView
            }
        }
        
        if let pendingEvent = pendingEvent {
            
            let newCoord = sender.translation(in: pendingEvent)
            if sender.state == .began {
                prevOffset = newCoord
            }
            
            let diff = CGPoint(x: newCoord.x - prevOffset.x, y: newCoord.y - prevOffset.y)
            var suggestedEventFrame = pendingEvent.frame

            if lockSlideDirection == nil {
                let location = sender.location(in: self)
                lockSlideDirection = location.y < suggestedEventFrame.midY
            }
            
            var backgroundEventFrame: CGRect = suggestedEventFrame
            
            switch lockSlideDirection {
            case .some(true):
                //头部
                suggestedEventFrame.origin.y += diff.y
                suggestedEventFrame.size.height -= diff.y
                
                backgroundEventFrame.origin.y = adjustOriginYOrderFloor(suggestedEventFrame.origin.y + diff.y)
                backgroundEventFrame.size.height = adjustOriginYOrderCeil(suggestedEventFrame.size.height - diff.y)
            case .some(false):
                //尾部
                suggestedEventFrame.size.height += diff.y
                backgroundEventFrame.size.height = adjustOriginYOrderCeil(suggestedEventFrame.size.height + diff.y)
            case .none:
                break
            }
            
            let suggestedEventHeight = suggestedEventFrame.size.height
            
            if suggestedEventHeight >= 0 && backgroundEventFrame.maxY <= bounds.height && suggestedEventFrame.minY >= 0 {
                pendingEvent.frame = suggestedEventFrame
                draw(with: backgroundEventFrame)
                
                prevOffset = newCoord
            }
        }
        
        if sender.state == .ended {
            
            lockSlideDirection = nil
            
            //FIXME: -需要优化
            let drawRect = commonLayer?.rect ?? .zero
            pendingEvent?.frame = drawRect
            
            // 清空画板
//            draw(with: .zero)
            
            // 根据绘制区域获取时间段
            if let timePeriod = getTimePeriod(with: drawRect) {
                timePeriodSubject.onNext(timePeriod)
            }
        }
    }
    
    var selectedTimePeriod: TimePeriod? {
        let drawRect = commonLayer?.rect ?? .zero
        return getTimePeriod(with: drawRect)
    }
}
