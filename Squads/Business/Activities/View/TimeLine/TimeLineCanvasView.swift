//
//  TimeLineCanvasView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/22.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class TimeLineCanvasView: BaseView {
    
    // 每一项的行高
    var gridHeight: CGFloat = 25
    
    // 每一项的行宽
    var gridWidth: CGFloat {
        return bounds.width / CGFloat(max(column, 1))
    }
    
    // 列数
    var column: Int = 1 {
        didSet {
            guard column != oldValue else { return }
            drawBorderPath()
        }
    }
    
    // 行数
    var row: Int = 10 {
        didSet {
            drawBorderPath()
        }
    }
    
    override var frame: CGRect {
        didSet {
            drawBorderPath()
        }
    }
    
    private var borderLayer = CAShapeLayer()
    private var backgroundLayers = Array<TimeLineLayer>()
    
    override func setupView() {
        borderLayer.lineWidth = 1
        borderLayer.theme.strokeColor = UIColor.textGray.map{ $0?.cgColor }
        borderLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(borderLayer)
        layer.masksToBounds = true
    }
    
    private func drawBorderPath() {
        let outsideRect = CGRect(x: 0, y: 0, width: bounds.width, height: CGFloat(row) * gridHeight)
        let bezi = UIBezierPath(rect: outsideRect)
        (0..<(row - 1)).forEach { index in
            bezi.move(to: CGPoint(x: 0, y: gridHeight * CGFloat(index + 1)))
            bezi.addLine(to: CGPoint(x: bounds.width, y: gridHeight * CGFloat(index + 1)))
        }
        (0..<column).forEach { index in
            bezi.move(to: CGPoint(x: gridWidth * CGFloat(index + 1), y: 0))
            bezi.addLine(to: CGPoint(x: gridWidth * CGFloat(index + 1), y: CGFloat(row) * gridHeight))
        }
        borderLayer.path = bezi.cgPath
    }
    
    /// 插入一个layer
    /// - Parameter color: 背景色
    /// - Parameter rowIndex: 列的索引  从0开始 小于row的值
    /// - Parameter start: 开始的位置 一个完整的格步长为3
    /// - Parameter end: 结束的位置 一个完整的格步长为3
    /// - Parameter key: 标示此layer, 便于后期对其操作
    @discardableResult
    func insertColor(_ color: UIColor, withRect rect: CGRect? = nil, key: String? = nil) -> TimeLineLayer? {
        
        var subLayer: TimeLineLayer?
        if let unwrappedKey = key {
            subLayer = layer.sublayers?.reversed().first(where: {
                return ($0 as? TimeLineLayer)?.key == unwrappedKey
            }) as? TimeLineLayer
        }
        
        if subLayer == nil {
            subLayer = getLayerFromCache(key: key)
            layer.insertSublayer(subLayer!, at: 0)
        }
        
        if let unwrappedRect = rect {
            subLayer?.path = UIBezierPath(rect: unwrappedRect).cgPath
        }
        
        subLayer?.fillColor = color.cgColor
        return subLayer
    }
    
    /// 根据标示移除一个layer
    /// - Parameter key : 标示
    func removeColor(_ key: String) {
        let subLayer = layer.sublayers?.reversed().first(where: { (layer) -> Bool in
            if let itemLayer = layer as? TimeLineLayer {
                return itemLayer.key == key
            }
            return false
        })
        subLayer?.removeFromSuperlayer()
        cacheLayer(subLayer as! TimeLineLayer)
    }
    
    /// 清空所有的颜色值
    func clearColors() {
        layer.sublayers?.filter{ $0.isKind(of: TimeLineLayer.self) }.forEach {
            $0.removeFromSuperlayer()
            cacheLayer($0 as! TimeLineLayer)
        }
    }
    
    private func cacheLayer(_ layer: TimeLineLayer) {
        backgroundLayers.append(layer)
    }
    
    private func getLayerFromCache(key: String?) -> TimeLineLayer {
        if let layer = backgroundLayers.last {
            backgroundLayers.removeLast()
            layer.key = key
            return layer
        }
        let layer = TimeLineLayer()
        layer.key = key
        layer.bounds = bounds
        layer.anchorPoint = .zero
        return layer
    }
}
