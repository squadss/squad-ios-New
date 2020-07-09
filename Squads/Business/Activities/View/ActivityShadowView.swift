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
    var contentMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 17, bottom: 10, right: 17)
    var lineMarginHor: CGFloat = 20
    
    var borderColor: UIColor? {
        didSet {
            
            guard borderColor != nil else {
                separatorline.isHidden = false
                return
            }
            
            if borderLayer?.superlayer == nil {
                borderLayer = CALayer()
                borderLayer?.borderWidth = 3
                borderLayer?.cornerRadius = 8
                contentView.layer.addSublayer(borderLayer!)
            }
            separatorline.isHidden = true
            borderLayer?.borderColor = borderColor?.cgColor
        }
    }
    
    var contentView = UIView()
    private var borderLayer: CALayer?
    private var separatorline = UIView()
    
    override var frame: CGRect {
        didSet {
            guard oldValue != frame else { return }
            let rect = CGRect(x: 0, y: 0, width: frame.width - contentMargin.left - contentMargin.right, height: frame.height - contentMargin.bottom - contentMargin.top)
            contentView.layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: 4).cgPath
            borderLayer?.frame = rect
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
        
        separatorline.backgroundColor = UIColor(hexString: "#FAFAFA")
        addSubviews(contentView, separatorline)
    }
}
