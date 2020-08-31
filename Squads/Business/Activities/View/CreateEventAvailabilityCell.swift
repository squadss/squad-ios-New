//
//  CreateEventAvailabilityCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/11.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

class CreateEventAvailabilityCell: BaseTableViewCell {
    
    var disposeBag = DisposeBag()
    var chooseTimeView = SingleChooseTimeView(cellStyle: .dash(level: .level5))
    
    override func setupView() {
        
        chooseTimeView.sectionView.title = "CLICK YOUR TIME"
        chooseTimeView.sectionView.headerTitleStyle.textColor = UIColor.textGray
        chooseTimeView.axisView.scrollToCurrentDate()
        
        contentView.addSubview(chooseTimeView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chooseTimeView.frame = CGRect(x: 40, y: 10, width: bounds.width - 100, height: bounds.height - 20)
    }
    
}
