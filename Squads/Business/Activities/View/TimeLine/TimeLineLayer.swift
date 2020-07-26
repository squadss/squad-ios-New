//
//  TimeLineLayer.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/22.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class TimeLineLayer: CAShapeLayer {
    
    var rect: CGRect? {
        didSet {
            guard let unwrappedRect = rect else { return }
            path = UIBezierPath(rect: unwrappedRect).cgPath
        }
    }
    
    var key: String?
    
    override func removeFromSuperlayer() {
        super.removeFromSuperlayer()
        key = nil
    }
}
