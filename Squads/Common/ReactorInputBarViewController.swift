//
//  ReactorInputBarViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/25.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import InputBarAccessoryView

class ReactorInputBarViewController<ViewModel: Reactor>: InputBarViewController, View {

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
        setupView()
        setupConstraints()
        addTouchAction()
    }
    
    func setupView() { }
    
    func setupConstraints() {}
    
    func addTouchAction() { }
    
    func bind(reactor: ViewModel) {
        //TODO:
    }

}
