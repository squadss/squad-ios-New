//
//  AvtivityTimeSettingViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/18.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class AvtivityTimeSettingViewController: BaseViewController, OverlayTransitioningDelegate {

    var transitioningProvider: OverlayTransitioningProvider? = .init(height: UIScreen.main.bounds.height, maskOpacity: 0.5)
    
    private var disposeBag = DisposeBag()
    var contentView = AvtivityTimeSettingView()
    
    override func setupView() {
        contentView.radius = 13
        contentView.clipsToBounds = true
        contentView.theme.backgroundColor = UIColor.background
        view.addSubview(contentView)
        
        contentView.didTapped
            .filter{ $0 == "Cancel" }
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
                
        contentView.didTapped
            .filter{ $0 == "Set Time" }
            .trackAlert(title: "Confirm Time",
                        message: "Are you sure you want to finalize the event time? A notification will be sent to people in your squad.",
                        target: self)
            .subscribe(onNext: { [unowned self] title in
                self.showToast(message: "Set Success!")
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentView.frame = CGRect(x: 20, y: (view.bounds.height - 589)/2, width: view.bounds.width - 40, height: 589)
    }

}
