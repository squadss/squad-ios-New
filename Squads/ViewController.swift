//
//  ViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton()
        btn.backgroundColor = .red
        btn.frame = CGRect(x: 10, y: 10, width: 100, height: 44)
        btn.addTarget(self, action: #selector(btnDidTapped), for: .touchUpInside)
        view.addSubview(btn)
    }
    
    @objc
    func btnDidTapped() {
        present(VC1(), animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}

