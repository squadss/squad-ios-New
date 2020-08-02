//
//  ReactorViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class ReactorViewController<ViewModel: Reactor>: BaseViewController, View {

    var disposeBag = DisposeBag()
    
    init(reactor: ViewModel) {
        super.init(nibName: nil, bundle: nil)
        defer{ self.reactor = reactor  }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func bind(reactor: ViewModel) {
        //TODO:
    }

}
