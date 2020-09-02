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
    
    var activityType: EventCategory!
    
    private var didSelectItemSubject = PublishSubject<Array<TimePeriod>>()
    var didSelectTime: Observable<Array<TimePeriod>> {
        return didSelectItemSubject.asObservable()
    }
    
    private var disposeBag = DisposeBag()
    private var contentView = AvtivityTimeSettingView()
    private var confirmView = AvtivityConfirmScheduledView()
    
    override func setupView() {
        contentView.radius = 13
        contentView.isHidden = false
        contentView.clipsToBounds = true
        contentView.theme.backgroundColor = UIColor.background
        view.addSubview(contentView)
        
        confirmView.radius = 13
        confirmView.isHidden = true
        confirmView.clipsToBounds = true
        confirmView.theme.backgroundColor = UIColor.background
        view.addSubview(confirmView)
    }
    
    override func addTouchAction() {
        contentView.didTapped.subscribe(onNext: { [unowned self] flag in
            switch flag {
            case "Cancel":
                // 返回上级页面
                self.dismiss(animated: true)
            case "Set Time":
                if let timePeriod = self.contentView.chooseTimeView.currentSelectedTimes, !timePeriod.isEmpty {
                    // 打开确认弹窗
                    self.contentView.isHidden = true
                    self.confirmView.isHidden = false
                    self.confirmView.alpha = 0
                    self.confirmView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                        self.confirmView.alpha = 1
                        self.confirmView.transform = .identity
                    })
                    self.confirmView.config(activityType: self.activityType, timeperiod: timePeriod)
                } else {
                    self.contentView.showToast(message: NSLocalizedString("squadSettingTime.neverChosenTip", comment: ""))
                    return
                }
            default:
                break
            }
        })
        .disposed(by: disposeBag)
        
        confirmView.didTapped.subscribe(onNext: { [unowned self] flag in
            switch flag {
            case "Back":
                // 返回内容视图
                self.contentView.isHidden = false
                self.confirmView.isHidden = true
            case "Confirm":
                // 数组不能为空
                if let timePeriod = self.contentView.chooseTimeView.currentSelectedTimes, !timePeriod.isEmpty {
                    self.didSelectItemSubject.onNext([timePeriod])
                    self.dismiss(animated: true)
                }
            default:
                break
            }
        })
        .disposed(by: disposeBag)
        
//        confirmView.didTapped
//            .filter{ $0 == "Cancel" }
//            .subscribe(onNext: { [unowned self] _ in
//                self.dismiss(animated: true)
//                self.didSelectItemSubject.onNext(nil)
//            })
//            .disposed(by: disposeBag)
//
//        confirmView.didTapped
//            .filter{ $0 == "Set Time" }
//            .trackAlert(title: "Confirm Time",
//                        message: "Are you sure you want to finalize the event time? A notification will be sent to people in your squad.",
//                        target: self)
//            .subscribe(onNext: { [unowned self] title in
//                self.dismiss(animated: true)
//                self.didSelectItemSubject.onNext([])
//            })
//            .disposed(by: disposeBag)
    }
    
    func topSection(section: MembersSection<ActivityMember>) {
        contentView.membersView.setTopSection(section: section)
        let list = section.list.flatMap{ $0.myTime }
        contentView.chooseTimeView.setDataSource(originList: list)
    }
    
    func bottomSection(section: MembersSection<User>) {
        contentView.membersView.setBottomSection(section: section)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentView.frame = CGRect(x: 20, y: (view.bounds.height - 589)/2, width: view.bounds.width - 40, height: 589)
        confirmView.frame = CGRect(x: 20, y: (view.bounds.height - 379)/2, width: view.bounds.width - 40, height: 379)
    }

}
