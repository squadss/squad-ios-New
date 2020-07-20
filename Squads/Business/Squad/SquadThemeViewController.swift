//
//  SquadThemeViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class SquadThemeViewController: ReactorViewController<SquadThemeReactor> {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
    }
}
