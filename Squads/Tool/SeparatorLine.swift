//
//  SeparatorLine.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

open class SeparatorLine: UIView {
    
    public typealias SeparatorDirection = NSLayoutConstraint.Axis
    
    let direction: SeparatorDirection
    
    public init(direction: SeparatorDirection = .horizontal) {
        self.direction = direction
        super.init(frame: .zero)
        setup()
    }
    
    convenience init(direction: SeparatorDirection = .horizontal, bgColor: UIColor) {
        self.init(direction: direction)
        self.backgroundColor = bgColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    /// The height of the line
    open var value: CGFloat = 0.5 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        if direction == .horizontal {
            return CGSize(width: super.intrinsicContentSize.width, height: value)
        }
        else {
            return CGSize(width: value, height: super.intrinsicContentSize.height)
        }
    }
    
    /// Sets up the default properties
    open func setup() {
        backgroundColor = .lightGray
        translatesAutoresizingMaskIntoConstraints = false
        
        var axis: NSLayoutConstraint.Axis {
            if direction == .horizontal {
                return .vertical
            }
            else {
                return .horizontal
            }
        }
        
        setContentHuggingPriority(.defaultHigh, for: axis)
    }
}
