//
//  SnapKit+Extension.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import SnapKit

extension ConstraintViewDSL {
    
    func safeFull(parent: UIViewController, edge: UIEdgeInsets = .zero) {
        
        makeConstraints { (maker) in
            maker.leading.equalToSuperview().offset(edge.left)
            maker.trailing.equalToSuperview().inset(edge.right)
            if #available(iOS 11, *) {
                maker.top.equalTo(parent.view.safeAreaLayoutGuide.snp.top).offset(edge.top)
                maker.bottom.equalTo(parent.view.safeAreaLayoutGuide.snp.bottom).inset(edge.bottom)
            } else {
                maker.top.equalTo(parent.topLayoutGuide.snp.bottom).offset(edge.top)
                maker.bottom.equalTo(parent.bottomLayoutGuide.snp.top).inset(edge.bottom)
            }
        }
    }
}
