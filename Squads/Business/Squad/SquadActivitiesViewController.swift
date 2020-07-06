//
//  SquadActivitiesViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class SquadActivitiesViewController: ReactorViewController<SquadActivitiesReactor> {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
    }
    
    override func setupView() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigationBarCalendar"), style: .plain, target: self, action: #selector(rightBarItemDidTapped))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
        
    @objc
    private func rightBarItemDidTapped() {
        let reactor = SquadCalendarReactor()
        let vc = SquadCalendarViewController(reactor: reactor)
        let nav = BaseNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}
