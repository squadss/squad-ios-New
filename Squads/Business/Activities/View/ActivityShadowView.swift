//
//  ActivityShadowView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/6.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

// 将视图添加到contentView中
class ActivityShadowView: BaseView {
    
    var lineHeight: CGFloat = 0.8
    var lineMarginTop: CGFloat = 0
    var lineMarginHor: CGFloat = 20
    var contentMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 17, bottom: 10, right: 17)
    
    var borderColor: UIColor? {
        didSet {
            if borderColor == nil {
                separatorline.isHidden = false
                borderLayer.isHidden = true
            } else {
                separatorline.isHidden = true
                borderLayer.isHidden = false
                borderLayer.borderColor = borderColor?.cgColor
            }
        }
    }
    
    var contentView = UIView()
    private var borderLayer = CALayer()
    private var separatorline = UIView()
    
    override var frame: CGRect {
        didSet {
            guard oldValue != frame else { return }
            let rect = CGRect(x: 0, y: 0, width: frame.width - contentMargin.left - contentMargin.right, height: frame.height - contentMargin.bottom - contentMargin.top)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            contentView.layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: 4).cgPath
            borderLayer.frame = rect
            CATransaction.commit()
            
            separatorline.frame = CGRect(x: lineMarginHor, y: lineMarginTop, width: frame.width - lineMarginHor * 2, height: lineHeight)
            contentView.frame = CGRect(x: contentMargin.left, y: contentMargin.top, width: frame.width - contentMargin.left - contentMargin.right, height: frame.height - contentMargin.bottom - contentMargin.top)
        }
    }
    
    override func setupView() {
        
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOpacity = 1.0
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = UIColor(hexString: "#FDFDFD")
        
        borderLayer.borderWidth = 3
        borderLayer.cornerRadius = 8
        contentView.layer.addSublayer(borderLayer)
        
        separatorline.backgroundColor = UIColor(hexString: "#FAFAFA")
        addSubviews(contentView, separatorline)
    }
}
