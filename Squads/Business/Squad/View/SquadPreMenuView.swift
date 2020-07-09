//
//  SquadPreMenuView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SquadPreMenuView: BaseView {
    
    override var frame: CGRect {
        didSet {
            guard frame != .zero else { return }
            stackView.frame = bounds
        }
    }
    
    var daysView = SquadPreMenuItemView()
    var textsView = SquadPreMenuItemView()
    var flicksView = SquadPreMenuItemView()
    private var stackView: UIStackView!
    override func setupView() {
        stackView = UIStackView(arrangedSubviews: [daysView, textsView, flicksView])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        addSubview(stackView)
    }
}

class SquadPreMenuItemView: BaseView {
    
    var titleLab = UILabel()
    var numLab = UILabel()
    
    override func setupView() {
        titleLab.theme.textColor = UIColor.secondary
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLab.textAlignment = .center
        
        numLab.theme.textColor = UIColor.text
        numLab.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        numLab.textAlignment = .center
        
        addSubviews(titleLab, numLab)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLab.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 14)
        numLab.frame = CGRect(x: 0, y: bounds.height - 20, width: bounds.width, height: 20)
    }
}
