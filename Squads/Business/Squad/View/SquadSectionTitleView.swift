//
//  SquadSectionTitleView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

struct SquadSectionTitleLayout {
    var btnWidth: CGFloat = 100
    var btnHeight: CGFloat = 40
    var marginRight: CGFloat = 17
    var marginLeft: CGFloat = 18
}

class SquadSectionTitleView: BaseView {
    
    var titleLab = UILabel()
    var attachBtn: UIButton? {
        didSet {
            if attachBtn?.superview == nil {
                attachBtn.flatMap{ addSubview($0) }
            }
        }
    }
    
    var layout = SquadSectionTitleLayout() {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    override func setupView() {
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLab.theme.textColor = UIColor.text
        addSubview(titleLab)
        theme.backgroundColor = UIColor.background
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLab.frame = CGRect(x: layout.marginLeft, y: (bounds.height - 20)/2, width: 150, height: 20)
        attachBtn?.frame = CGRect(x: bounds.width - layout.btnWidth - layout.marginRight, y: (bounds.height - layout.btnHeight)/2, width: layout.btnWidth, height: layout.btnHeight)
    }
}
