//
//  MySquadsViewCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class MySquadsViewCell: BaseTableViewCell {
    
    var pritureView = UIImageView()
    var titleLab = UILabel()
    
    var unreadNum: String? {
        didSet {
            unreadLab.text = unreadNum
        }
    }
    
    private var unreadLab = PaddingLabel()
    let unreadSize: CGSize = CGSize(width: 25, height: 20)
    
    override func setupView() {
        
        unreadLab.numberOfLines = 1
        unreadLab.theme.textColor = UIColor.background
        unreadLab.font = UIFont.systemFont(ofSize: 10)
        unreadLab.textAlignment = .center
        unreadLab.theme.backgroundColor = UIColor.secondary
        unreadLab.layer.maskCorners(10, rect: CGRect(origin: .zero, size: unreadSize))
        unreadLab.clipsToBounds = true
        
        titleLab.font = UIFont.systemFont(ofSize: 14)
        titleLab.theme.textColor = UIColor.text
        
        pritureView.layer.maskCorners(20, rect: CGRect(x: 0, y: 0, width: 40, height: 40))
        pritureView.clipsToBounds = true
        
        contentView.addSubviews(pritureView, titleLab, unreadLab)
        contentView.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
    }
    
    func setData(_ data: SquadChannel) {
        pritureView.kf.setImage(with: data.avatar?.asURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        titleLab.text = data.title
        if data.unreadCount > 0 {
            unreadLab.isHidden = false
            unreadLab.text = "\(data.unreadCount)"
        } else {
            unreadLab.isHidden = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pritureView.frame = CGRect(x: 37, y: (bounds.height - 40)/2, width: 40, height: 40)
        titleLab.frame = CGRect(x: pritureView.frame.maxX + 12, y: (bounds.height - 17)/2, width: 200, height: 17)
        unreadLab.frame = CGRect(origin: CGPoint(x: bounds.width - unreadSize.width - 20, y: (bounds.height - unreadSize.height)/2), size: unreadSize)
    }
}
