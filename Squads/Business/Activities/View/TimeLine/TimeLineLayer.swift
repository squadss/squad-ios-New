//
//  TimeLineLayer.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/22.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class TimeLineLayer: CAShapeLayer {
    
    var rect: CGRect {
        set { path = UIBezierPath(rect: newValue).cgPath }
        get { return path?.boundingBox ?? .zero }
    }
    
    var key: String?
    
    override func removeFromSuperlayer() {
        super.removeFromSuperlayer()
        key = nil
    }
    
    // 设置内容偏移
    func contentOffsetY(_ value: CGFloat) {
        guard !rect.isEmpty else { return }
        rect.origin.y += value
    }
}
