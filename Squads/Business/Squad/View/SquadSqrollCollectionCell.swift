//
//  SquadSqrollCollectionCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class SquadSqrollCollectionCell: BaseCollectionViewCell {
    
    var pritureView = UIImageView()
    
    override func setupView() {
        pritureView.contentMode = .scaleAspectFill
        pritureView.layer.maskCorners(8, rect: CGRect(origin: .zero, size: CGSize(width: 97, height: 97)))
        pritureView.clipsToBounds = true
        contentView.addSubview(pritureView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pritureView.frame = bounds
    }
}
