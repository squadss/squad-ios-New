//
//  FlicksViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class FlicksViewController: ReactorViewController<FlicksReactor> {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    override func setupView() {
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "New Flick"), style: .plain, target: self, action: #selector(rightBarItemDidTapped))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc
    private func rightBarItemDidTapped() {
        let reactor = SquadNewMemoryReactor()
        let vc = SquadNewMemoryViewController(reactor: reactor)
        let nav = BaseNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}
