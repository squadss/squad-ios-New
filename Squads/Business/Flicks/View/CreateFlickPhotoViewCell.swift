//
//  CreateFlickPhotoViewCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/20.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import Photos

class CreateFlickPhotoViewCell: BaseCollectionViewCell {
    
    var pirtureView = UIImageView()
    
    override func setupView() {
        pirtureView.layer.cornerRadius = 8
        pirtureView.layer.masksToBounds = true
        contentView.addSubview(pirtureView)
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.white
        selectedBackgroundView = selectedView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pirtureView.frame = bounds
    }
}
