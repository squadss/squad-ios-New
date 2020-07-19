//
//  SquadNotificationsViewCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/18.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

class SquadNotificationsViewCell: BaseTableViewCell {
    
    var titleLab = UILabel()
    var switchBtn = UISwitch()
    
    var disposeBag = DisposeBag()
    
    override func setupView() {
        titleLab.theme.textColor = UIColor.text
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLab.numberOfLines = 1
        
        contentView.addSubviews(titleLab, switchBtn)
        
        titleLab.snp.makeConstraints { (maker) in
            maker.leading.equalTo(33)
            maker.centerY.equalToSuperview()
            maker.width.equalTo(200)
        }
        
        switchBtn.snp.makeConstraints { (maker) in
            maker.trailing.equalTo(-33)
            maker.centerY.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
