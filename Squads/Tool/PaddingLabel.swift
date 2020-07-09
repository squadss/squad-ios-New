//
//  PaddingLabel.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

final class PaddingLabel: UILabel {
    
    var edge: UIEdgeInsets = .zero
    
    override func draw(_ rect: CGRect) {
        super.draw(rect.inset(by: edge))
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += edge.left + edge.right
        size.height += edge.top + edge.bottom
        return size
    }
}
