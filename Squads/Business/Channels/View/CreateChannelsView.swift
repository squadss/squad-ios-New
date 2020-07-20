//
//  CreateChannelsView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/20.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

class CreateChannelsView: BaseView {
    
    // 可编辑按钮
    private var canEditView = UIButton()
    // 头像
    private var imageBtn = CornersButton()
    // 标题
    private var tipLab = UILabel()
    // 输入框
    private var textField = UITextField()
    // 错误提示lab
    private var toastLab = UILabel()
    // 创建按钮
    var confirmBtn = UIButton()
    // 关闭pop的按钮
    var closeBtn = UIButton()
    
    private var gradientLayer: CAGradientLayer!
    
    override func setupView() {
        
        imageBtn.setImage(UIImage(named: "Channels Placeholder"), for: .normal)
        imageBtn.layer.cornerRadius = 39
        imageBtn.layer.masksToBounds = true
        
        tipLab.text = "NAME"
        tipLab.theme.textColor = UIColor.textGray
        tipLab.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(hexString: "#F7BDB7").cgColor,
                                UIColor(hexString: "#FDDEC8").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        gradientLayer.locations = [0, 1]
        gradientLayer.cornerRadius = 10
        layer.addSublayer(gradientLayer)
        
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        
        toastLab.textAlignment = .center
        toastLab.theme.textColor = UIColor.textGray
        toastLab.font = UIFont.systemFont(ofSize: 12)
        
        confirmBtn.setTitle("Create", for: .normal)
        confirmBtn.setBackgroundImage(UIImage(color: UIColor(red: 0.754, green: 0.754, blue: 0.754, alpha: 1)), for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        confirmBtn.setTitleColor(.white, for: .normal)
        
        canEditView.contentMode = .center
        canEditView.setImage(UIImage(named: "Edit Group"), for: .normal)
        
        closeBtn.imageView?.contentMode = .center
        closeBtn.setImage(UIImage(named: "Channels Close"), for: .normal)
        
        addSubviews(imageBtn, canEditView, tipLab, textField, toastLab, confirmBtn, closeBtn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageBtn.frame = CGRect(x: (bounds.width - 78)/2, y: 56, width: 78, height: 78)
        canEditView.frame = CGRect(x: imageBtn.frame.maxX - 25, y: imageBtn.frame.maxY - 25, width: 29, height: 29)
        
        tipLab.frame = CGRect(x: 36, y: imageBtn.frame.maxY + 29, width: bounds.width - 2 * 36, height: 14)
        
        gradientLayer.frame = CGRect(x: tipLab.frame.minX, y: tipLab.frame.maxY + 8, width: bounds.width - 2 * tipLab.frame.minX, height: 44)
        textField.frame = CGRect(x: tipLab.frame.minX + 3, y: tipLab.frame.maxY + 8 + 3, width: bounds.width - 2 * tipLab.frame.minX - 6, height: 44 - 6)
        
        toastLab.frame = CGRect(x: textField.frame.minX, y: textField.frame.maxY + 6, width: textField.frame.width, height: 20)
        
        confirmBtn.frame = CGRect(x: (bounds.width - 106)/2, y: bounds.height - 31 - 45, width: 106, height: 31)
        closeBtn.frame = CGRect(x: bounds.width - 60, y: 10, width: 44, height: 44)
    }
}
