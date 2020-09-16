//
//  SquadChannelsCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class SquadChannelsCell: BaseTableViewCell {
    
    private var pritureView = UIImageView()
    private var titleLab = UILabel()
    private var contentLab = UILabel()
    private var dateLab = UILabel()
    private var unreadLab = PaddingLabel()
    private var line = UIView()
    
    let unreadSize: CGSize = CGSize(width: 20, height: 20)
    let pritureSize: CGSize = CGSize(width: 36, height: 36)
    let marginHorizontal: CGFloat = 15
    
    override func setupView() {
        
        pritureView.contentMode = .scaleAspectFill
        pritureView.layer.maskCorners(3, rect: CGRect(origin: .zero, size: pritureSize))
        pritureView.clipsToBounds = true
        
        titleLab.numberOfLines = 1
        titleLab.theme.textColor = UIColor.text
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        contentLab.numberOfLines = 1
        contentLab.theme.textColor = UIColor.textGray
        contentLab.font = UIFont.systemFont(ofSize: 12)
        
        dateLab.numberOfLines = 1
        dateLab.theme.textColor = UIColor.textGray
        dateLab.textAlignment = .right
        dateLab.font = UIFont.systemFont(ofSize: 10)
        
        unreadLab.numberOfLines = 1
        unreadLab.theme.textColor = UIColor.background
        unreadLab.font = UIFont.systemFont(ofSize: 10)
        unreadLab.textAlignment = .center
        unreadLab.theme.backgroundColor = UIColor.secondary
        unreadLab.layer.cornerRadius = 10
        unreadLab.layer.masksToBounds = true
        
        line.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
        contentView.addSubviews(pritureView, titleLab, contentLab, dateLab, unreadLab, line)
    }
    
    func setData(_ data: SquadChannel) {
        pritureView.kf.setImage(with: data.avatar?.asURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        titleLab.text = data.title
        contentLab.text = data.content
        dateLab.text = data.dateString
        if data.unreadCount > 0 {
            unreadLab.isHidden = false
            unreadLab.text = "\(data.unreadCount)"
        } else {
            unreadLab.isHidden = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let titleMarginLeft: CGFloat = 12
        let unreadMarginTop: CGFloat = 5
        
        pritureView.frame = CGRect(origin: CGPoint(x: marginHorizontal, y: (bounds.height - pritureSize.height)/2), size: pritureSize)
        dateLab.frame = CGRect(x: bounds.width - marginHorizontal - 80, y: pritureView.frame.minY, width: 80, height: 15)
        titleLab.frame = CGRect(x: pritureView.frame.maxX + titleMarginLeft, y: pritureView.frame.minY, width: dateLab.frame.minX - pritureView.frame.maxX - titleMarginLeft, height: 18)
        unreadLab.frame = CGRect(origin: CGPoint(x: bounds.width - marginHorizontal - unreadSize.width, y: dateLab.frame.maxY + unreadMarginTop), size: unreadSize)
        line.frame = CGRect(x: titleLab.frame.minX, y: bounds.height - 0.5, width: bounds.width - titleLab.frame.minX - marginHorizontal, height: 0.5)
        contentLab.frame = CGRect(x: titleLab.frame.minX, y: titleLab.frame.maxY + 2, width: unreadLab.frame.minX - pritureView.frame.maxX - titleMarginLeft - 5, height: 16)
    }
}
