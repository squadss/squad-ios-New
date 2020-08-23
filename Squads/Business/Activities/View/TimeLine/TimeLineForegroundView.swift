//
//  TimeLineForegroundView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/22.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

protocol TimeLineForegroundViewDelegate: class {
    func foregroundView(_ view: TimeLineForegroundView, didSelectedArea rect: CGRect)
    func foregroundView(_ view: TimeLineForegroundView, willDisplay identifier: String) -> Array<CGRect>
    func foregroundView(_ view: TimeLineForegroundView, didEndTouch rect: CGRect)
}

final class TimeLineForegroundView: BaseView {
    
    weak var delegate: TimeLineForegroundViewDelegate?
    private(set) var pendingEvent = UIView()
    private var prevOffset: CGPoint = .zero
    private var lockSlideDirection: Bool?
    private var panGestureRecognizer = UIPanGestureRecognizer()
    
    var gridHeight: CGFloat = 25
    // 自动调整对齐的尺寸
    var adjustSelectedRect: Bool = false
    // 增加内边距
    var insertSelectedRect: UIEdgeInsets = .zero
    
    override func setupView() {
        super.setupView()
        panGestureRecognizer.addTarget(self, action: #selector(handleResizeHandlePanGesture(_:)))
        panGestureRecognizer.cancelsTouchesInView = true
        addGestureRecognizer(panGestureRecognizer)
        
        pendingEvent = UIView()
        pendingEvent.isHidden = true
        pendingEvent.backgroundColor = UIColor.clear
        addSubview(pendingEvent)
    }
    
    @objc
    func handleResizeHandlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        if sender.state == .began {
            let location = sender.location(in: self)
            
            // 触摸点还在当前视图上, 修改当前视图的尺寸, 触摸点不在当前视图上, 需计算pendingEvent的尺寸
            let isContains: Bool = pendingEvent.frame.contains(location)
            pendingEvent.isHidden = !isContains
            
            if pendingEvent.isHidden {
                pendingEvent.isHidden = false
                
                let referenceRectList = delegate?.foregroundView(self, willDisplay: "") ?? []
                if referenceRectList.isEmpty {
                    pendingEvent.frame = CGRect(x: 0, y: location.y, width: bounds.width, height: gridHeight).inset(by: insertSelectedRect)
                } else {
                    if let index = referenceRectList.firstIndex(where: { $0.contains(location) }) {
                        
                        var i = max(referenceRectList.count - index - 1, index)
                        var currentRect = referenceRectList[index]
                        
                        var low: Int = index
                        var high: Int = index
                        
                        while i > 0 {
                            
                            low -= 1
                            high += 1
                            
                            let prevRect = referenceRectList[safe: low]
                            let nextRect = referenceRectList[safe: high]
                            
                            //判断当前cell, 是否和前后元素相邻, 如果相邻取出组合在一起的尺寸
                            if let unwrappedRect = prevRect, unwrappedRect.isAdjoin(currentRect) {
                                currentRect = unwrappedRect.union(currentRect)
                            }
                            
                            if let unwrappedRect = nextRect, unwrappedRect.isAdjoin(currentRect) {
                                currentRect = unwrappedRect.union(currentRect)
                            }
                            
                            i -= 1
                        }
                        pendingEvent.frame = currentRect.inset(by: insertSelectedRect)
                    } else {
                        //当前点没有在选中cell上, 需要新创建图形
                        pendingEvent.frame = CGRect(x: 0, y: location.y, width: bounds.width, height: gridHeight).inset(by: insertSelectedRect)
                    }
                }
            }
        }
        
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
        
        switch lockSlideDirection {
        case .some(true):
            //头部
            suggestedEventFrame.origin.y += diff.y
            suggestedEventFrame.size.height -= diff.y
        case .some(false):
            //尾部
            suggestedEventFrame.size.height += diff.y
        case .none:
            break
        }
        
        // 到达临界点, 改变方向
        if suggestedEventFrame.height <= 0.5 {
            if diff.y > 0 {
                lockSlideDirection = false
            } else {
                lockSlideDirection = true
            }
        }
        
        if suggestedEventFrame.size.height >= 0 && suggestedEventFrame.minY >= insertSelectedRect.top && suggestedEventFrame.maxY <= insertSelectedRect.bottom + bounds.height {
            pendingEvent.frame = suggestedEventFrame
            prevOffset = newCoord
            delegate?.foregroundView(self, didSelectedArea: pendingEvent.frame)
        }
        
        if sender.state == .ended {
            
            if adjustSelectedRect {
                var newRect = pendingEvent.frame
                newRect.origin.y = round(newRect.origin.y / gridHeight) * gridHeight
                newRect.size.height = round(newRect.size.height / gridHeight) * gridHeight
                pendingEvent.frame = newRect
                delegate?.foregroundView(self, didSelectedArea: pendingEvent.frame)
                delegate?.foregroundView(self, didEndTouch: pendingEvent.frame)
            }
            
            lockSlideDirection = nil
        }
    }
    
}

extension CGRect {
    
    /// 判断两个矩形是否相邻
    /// - Parameter other: 参考的矩形
    /// - Parameter duration: 容差, 两个矩形之前的距离不大于duration都属于挨着, 默认是1pt
    func isAdjoin(_ other: CGRect, duration: CGFloat = 1) -> Bool {
        if self.minX == other.minX {
            if self.minY < other.minY && self.maxY <= other.maxY {
                let value = other.minY - self.maxY
                return value >= 0 && value <= duration
            } else if other.minY < minY && other.maxY <= maxY {
                let value = minY - other.maxY
                return value >= 0 && value <= duration
            }
        } else if minY == other.minY {
            if self.minX < other.minX && self.maxX <= other.maxX {
                let value = other.minX - self.maxX
                return value >= 0 && value <= duration
            } else if other.minX < minX && other.maxX <= maxX {
                let value = minX - other.maxX
                return value >= 0 && value <= duration
            }
        }
        return false
    }
}

class GridCell: BaseCollectionViewCell {
    
    // 显示的数量
    var num: Int = 0
    
    // 是否为奇数
    var isOdd: Bool = false
    
}

class SolidBoardGridCell: GridCell {
    
    var marginLeft: CGFloat = 13
    
    override var num: Int {
        didSet {
            guard num != oldValue else { return }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            switch num {
            case 0:
                backgroundLayer.backgroundColor = UIColor.clear.cgColor
            case 1:
                backgroundLayer.backgroundColor = TimeColor.level1.uiColor.cgColor
            case 2:
                backgroundLayer.backgroundColor = TimeColor.level2.uiColor.cgColor
            case 3:
                backgroundLayer.backgroundColor = TimeColor.level3.uiColor.cgColor
            case 4:
                backgroundLayer.backgroundColor = TimeColor.level4.uiColor.cgColor
            case 5:
                backgroundLayer.backgroundColor = TimeColor.level5.uiColor.cgColor
            default:
                backgroundLayer.backgroundColor = UIColor.black.cgColor
            }
            CATransaction.commit()
        }
    }
    
    private var borderLine = CAShapeLayer()
    private var outsideLine = CALayer()
    private var backgroundLayer = CALayer()
    
    override func setupView() {
        
        borderLine.lineWidth = 1
        borderLine.theme.strokeColor = UIColor.textGray.map{ $0?.cgColor }
        
        backgroundLayer.backgroundColor = UIColor.clear.cgColor
        outsideLine.theme.backgroundColor = UIColor.textGray.map{ $0?.cgColor }
        
        contentView.layer.addSublayer(borderLine)
        contentView.layer.addSublayer(backgroundLayer)
        contentView.layer.addSublayer(outsideLine)
        
        layoutBorderLine()
    }
    
    private func layoutBorderLine() {
        
        let borderPath = CGMutablePath()
        borderPath.move(to: CGPoint(x: marginLeft, y: 0))
        borderPath.addLine(to: CGPoint(x: marginLeft, y: bounds.height))
        borderPath.move(to: CGPoint(x: bounds.width - 0.5, y: 0))
        borderPath.addLine(to: CGPoint(x: bounds.width - 0.5, y: bounds.height))
        borderLine.path = borderPath
        
        let outsidePath = CGMutablePath()
        outsidePath.move(to: .zero)
        outsidePath.addLine(to: CGPoint(x: bounds.width, y: 0))
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        borderLine.frame = bounds
        backgroundLayer.anchorPoint = .zero
        backgroundLayer.bounds = CGRect(x: 0, y: 0, width: bounds.width - marginLeft + 0.5, height: bounds.height)
        backgroundLayer.position = CGPoint(x: marginLeft - 0.5, y: 0)
        outsideLine.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1)
        CATransaction.commit()
    }
}

class DashBoardGridCell: GridCell {
    
    var marginLeft: CGFloat = 13
    
    override var num: Int {
        didSet {
            guard num != oldValue else { return }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            switch num {
            case 0:
                backgroundLayer.backgroundColor = UIColor.clear.cgColor
            case 1:
                backgroundLayer.backgroundColor = TimeColor.level1.uiColor.cgColor
            case 2:
                backgroundLayer.backgroundColor = TimeColor.level2.uiColor.cgColor
            case 3:
                backgroundLayer.backgroundColor = TimeColor.level3.uiColor.cgColor
            case 4:
                backgroundLayer.backgroundColor = TimeColor.level4.uiColor.cgColor
            case 5:
                backgroundLayer.backgroundColor = TimeColor.level5.uiColor.cgColor
            default:
                backgroundLayer.backgroundColor = UIColor.black.cgColor
            }
            CATransaction.commit()
        }
    }
    
    private var backgroundLayer = CALayer()
    private var dashLine = CAShapeLayer()
    private var borderLine = CAShapeLayer()
    
    override func setupView() {
        
        borderLine.lineWidth = 1
        borderLine.theme.strokeColor = UIColor.textGray.map{ $0?.cgColor }
        
        dashLine.lineWidth = 1
        dashLine.lineDashPattern = [3, 6] as [NSNumber]
        dashLine.fillColor = UIColor.clear.cgColor
        dashLine.theme.strokeColor = UIColor.textGray.map{ $0?.cgColor }
        
        contentView.layer.addSublayer(borderLine)
        contentView.layer.addSublayer(backgroundLayer)
        contentView.layer.addSublayer(dashLine)
        
        layoutBorderLine()
    }
    
    private func layoutBorderLine() {
        
        let borderPath = CGMutablePath()
        borderPath.move(to: CGPoint(x: marginLeft, y: 0))
        borderPath.addLine(to: CGPoint(x: marginLeft, y: bounds.height))
        borderPath.move(to: CGPoint(x: bounds.width  - 0.5, y: 0))
        borderPath.addLine(to: CGPoint(x: bounds.width  - 0.5, y: bounds.height))
        borderLine.path = borderPath
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: marginLeft, y: 0))
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        dashLine.path = path
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        borderLine.frame = bounds
        backgroundLayer.anchorPoint = .zero
        backgroundLayer.bounds = CGRect(x: 0, y: 0, width: bounds.width - marginLeft + 0.5, height: bounds.height)
        backgroundLayer.position = CGPoint(x: marginLeft - 0.5, y: 0)
        dashLine.frame = bounds
        CATransaction.commit()
    }
}

class NumberGridCell: GridCell {
    
    private var numLab = UILabel()
    private var borderLine = CAShapeLayer()
    private var backgroundLayer = CALayer()
    
    override var num: Int {
        didSet {
            guard num != oldValue else { return }
            
            if num == 0 {
                numLab.isHidden = true
            } else {
                numLab.isHidden = false
                numLab.text = String(num)
            }
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            switch num {
            case 0:
                backgroundLayer.backgroundColor = UIColor.clear.cgColor
            case 1:
                backgroundLayer.backgroundColor = TimeColor.level1.uiColor.cgColor
            case 2:
                backgroundLayer.backgroundColor = TimeColor.level2.uiColor.cgColor
            case 3:
                backgroundLayer.backgroundColor = TimeColor.level3.uiColor.cgColor
            case 4:
                backgroundLayer.backgroundColor = TimeColor.level4.uiColor.cgColor
            case 5:
                backgroundLayer.backgroundColor = TimeColor.level5.uiColor.cgColor
            default:
                backgroundLayer.backgroundColor = UIColor.black.cgColor
            }
            CATransaction.commit()
        }
    }
    
    override func setupView() {
        
        let borderPath = CGMutablePath()
        borderPath.move(to: CGPoint(x: 0, y: bounds.height))
        borderPath.addLine(to: CGPoint(x: 0, y: 0))
        borderPath.addLine(to: CGPoint(x: bounds.width - 0.5, y: 0))
        borderPath.addLine(to: CGPoint(x: bounds.width - 0.5, y: bounds.height))
        borderLine.path = borderPath
        borderLine.frame = bounds
        borderLine.theme.strokeColor = UIColor.textGray.map{ $0?.cgColor }
        borderLine.fillColor = UIColor.clear.cgColor
        borderLine.lineWidth = 1
        
        numLab.textAlignment = .center
        numLab.numberOfLines = 1
        numLab.adjustsFontSizeToFitWidth = true
        numLab.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        numLab.theme.textColor = UIColor.secondary
        numLab.backgroundColor = .white
        numLab.layer.cornerRadius = 6.5
        numLab.layer.masksToBounds = true
        
        contentView.layer.addSublayer(borderLine)
        contentView.layer.addSublayer(backgroundLayer)
        contentView.addSubview(numLab)
        
        backgroundLayer.anchorPoint = .zero
        backgroundLayer.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        backgroundLayer.position = CGPoint(x: 0, y: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        numLab.frame = CGRect(x: bounds.width - 13 - 6, y: (bounds.height - 13)/2, width: 13, height: 13)
    }
}

class NormalGridCell: GridCell {
    
    private var borderLine = CAShapeLayer()
    private var backgroundLayer = CALayer()
    
    override var num: Int {
        didSet {
            guard num != oldValue else { return }
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            switch num {
            case 0:
                backgroundLayer.backgroundColor = UIColor.clear.cgColor
            case 1:
                backgroundLayer.backgroundColor = TimeColor.level1.uiColor.cgColor
            case 2:
                backgroundLayer.backgroundColor = TimeColor.level2.uiColor.cgColor
            case 3:
                backgroundLayer.backgroundColor = TimeColor.level3.uiColor.cgColor
            case 4:
                backgroundLayer.backgroundColor = TimeColor.level4.uiColor.cgColor
            case 5:
                backgroundLayer.backgroundColor = TimeColor.level5.uiColor.cgColor
            default:
                backgroundLayer.backgroundColor = UIColor.black.cgColor
            }
            CATransaction.commit()
        }
    }
    
    override func setupView() {
        
        let borderPath = CGMutablePath()
        borderPath.move(to: CGPoint(x: 0, y: bounds.height))
        borderPath.addLine(to: CGPoint(x: 0, y: 0))
        borderPath.addLine(to: CGPoint(x: bounds.width - 0.5, y: 0))
        borderPath.addLine(to: CGPoint(x: bounds.width - 0.5, y: bounds.height))
        borderLine.path = borderPath
        borderLine.frame = bounds
        borderLine.theme.strokeColor = UIColor.textGray.map{ $0?.cgColor }
        borderLine.fillColor = UIColor.clear.cgColor
        borderLine.lineWidth = 1
        
        contentView.layer.addSublayer(borderLine)
        contentView.layer.addSublayer(backgroundLayer)
        
        backgroundLayer.anchorPoint = .zero
        backgroundLayer.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        backgroundLayer.position = CGPoint(x: 0, y: 0)
    }
    
}
