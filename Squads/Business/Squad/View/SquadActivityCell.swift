//
//  SquadActivityCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class SquadActivityCell: BaseTableViewCell {
    
    var memberMarginRight: CGFloat = 16
    var memberMarginBottom: CGFloat = 4
    
    var pritureView = UIImageView()
    var dateLab = UILabel()
    var titleLab = UILabel()
    var contentLab = UILabel()
    var membersView = SquadMembersView()
    
    var containterView = ActivityShadowView()
    
    var descriptionLab = UILabel()
    
    private var isAniming: Bool = false
    
    override func setupView() {
        
        pritureView.contentMode = .scaleAspectFit
        
        dateLab.textColor = UIColor(red: 0.925, green: 0.384, blue: 0.337, alpha: 1)
        dateLab.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        
        titleLab.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLab.theme.textColor = UIColor.text
        
        contentLab.font = UIFont.systemFont(ofSize: 12)
        contentLab.theme.textColor = UIColor.textGray
        
        descriptionLab.isHidden = true
        descriptionLab.textAlignment = .center
        descriptionLab.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        descriptionLab.theme.textColor = UIColor.secondary
        
        membersView.margin = 3
        membersView.memberWidth = 16
        
        containterView.contentView.addSubviews(membersView, contentLab, titleLab, dateLab, pritureView, descriptionLab)
        contentView.addSubviews(containterView)
        
        pritureView.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.size.equalTo(CGSize(width: 30, height: 30))
            maker.leading.equalToSuperview().offset(15)
        }
        
        dateLab.snp.makeConstraints { (maker) in
            maker.leading.equalTo(pritureView.snp.trailing).offset(15)
            maker.top.equalTo(10)
        }
        
        titleLab.snp.makeConstraints { (maker) in
            maker.leading.equalTo(dateLab)
            maker.top.equalTo(dateLab.snp.bottom).offset(5)
        }
        
        contentLab.snp.makeConstraints { (maker) in
            maker.leading.equalTo(dateLab)
            maker.top.equalTo(titleLab.snp.bottom).offset(5)
            maker.height.equalTo(15)
        }
        
        membersView.snp.makeConstraints { (maker) in
            maker.trailing.equalToSuperview().offset(-17)
            maker.bottom.equalToSuperview().offset(-12)
        }
        
        descriptionLab.snp.makeConstraints { (maker) in
            maker.top.equalTo(14)
            maker.width.equalTo(150)
            maker.trailing.equalToSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        startAnimation()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        endAnimation()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        endAnimation()
    }
    
    private func startAnimation() {
        if isAniming {
            return
        }
        isAniming = true
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = NSNumber(value: 1.0)
        animation.toValue = NSNumber(value: 0.98)
        animation.duration = 0.25
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        containterView.contentView.layer.add(animation, forKey: "zoom-start")
    }
    
    private func endAnimation() {
        if !isAniming {
            return
        }
        isAniming = false
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = NSNumber(value: 0.98)
        animation.toValue = NSNumber(value: 1.0)
        animation.duration = 0.25
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        containterView.contentView.layer.add(animation, forKey: "zoom-end")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containterView.frame = bounds
    }
}
