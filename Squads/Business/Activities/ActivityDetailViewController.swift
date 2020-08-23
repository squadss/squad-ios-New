//
//  ActivityDetailViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ActivityDetailViewController: ReactorViewController<ActivityDetailReactor> {
    
    private var mapView = ActivityMapView()
    private let scrollView = UIScrollView()
    private var toolbar = ActivityDetailToolbar()
    private var infoView = ActivityDetailInfoView()
    private var chooseTimeView = MultipleChooseTimeView()
    private var membersView = MembersGroupView<ActivityMember>()
    
    override var allowedCustomBackBarItem: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.theme.backgroundColor = UIColor.background
        
        setupScrollView()
        setupNavigationItem()
        setupToolbarView()
        setupInfoView()
        setupChooseTimeView()
        setupMapView()
        setupMemberView()
    }
  
    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.snp.safeFull(parent: self)
    }
    
    private func setupNavigationItem() {
        
        let leftBtn = UIButton()
        leftBtn.setTitle("Back", for: .normal)
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        leftBtn.theme.titleColor(from: UIColor.text, for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        //自定义右导航按钮
        let rightBtn = UIButton()
        rightBtn.setImage(UIImage(named: "Navigation More"), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        
        leftBtn.rx.tap.subscribe(onNext: { [unowned self] in
            self.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        let action: Observable<Int> = rightBtn.rx.tap.flatMap{ [weak self] _ -> Observable<Int> in
           let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
           let titleAction = RxAlertAction(title: "Change Title", type: 0, style: .default)
           let locationAction = RxAlertAction(title: "Change Location", type: 1, style: .default)
           let deleteAction = RxAlertAction(title: "Delete Event", type: 2, style: .default)
           let cancelAction = RxAlertAction(title: "Cancel", type: -1, style: .cancel)
           
           return actionSheet
               .addAction(actions: [titleAction, locationAction, deleteAction, cancelAction])
               .map{ $0 }
               .do(onSubscribed: {
                   self?.present(actionSheet, animated: true, completion: nil)
               })
        }.share()

        action.filter{ $0 == 0 }
           .trackInputAlert(title: "Change Title", placeholder: "Please enter the Event name", default: "Confirm", target: self)
           .map{ Reactor.Action.setDetail(nil, title: $0, location: nil) }
           .bind(to: reactor!.action)
           .disposed(by: disposeBag)

        action.filter{ $0 == 2 }
           .trackAlert(title: "Confirm that you want to delete this event?", target: self)
           .map{ _ in Reactor.Action.deleteEvent }
           .bind(to: reactor!.action)
           .disposed(by: disposeBag)

        action.filter{ $0 == 1 }
           .subscribe(onNext: { [unowned self] type in
               let locationVC = CreateEventLocationViewController()
               locationVC.title = "Location"
               locationVC.itemSelected.map { item in
                   let location = SquadLocation(item: item)
                   return Reactor.Action.setDetail(nil, title: nil, location: location)
               }
               .bind(to: self.reactor!.action)
               .disposed(by: self.disposeBag)
               let nav = UINavigationController(rootViewController: locationVC)
               self.present(nav, animated: true)
           })
           .disposed(by: disposeBag)
    }
    
    private func layoutScrollSubviews() {
        
        var contentHeight: CGFloat = 0
        
        if !toolbar.isHidden {
            contentHeight += toolbar.frame.height
        }
        
        if !infoView.isHidden {
            let offsetY: CGFloat = 14
            infoView.frame.origin.y = contentHeight + offsetY
            contentHeight += infoView.frame.height + offsetY
        }
        
        if !chooseTimeView.isHidden {
            chooseTimeView.frame.origin.y = contentHeight
            contentHeight += chooseTimeView.frame.height
        }
        
        if !mapView.isHidden {
            mapView.frame.origin.y = contentHeight
            contentHeight += mapView.frame.height
        }
        
        if !membersView.isHidden {
            membersView.frame.origin.y = contentHeight
            contentHeight += membersView.frame.height
        }
        
        scrollView.contentSize = CGSize(width: view.bounds.width, height: contentHeight)
    }
    
    override func bind(reactor: ActivityDetailReactor) {
        
        reactor.state
            .compactMap{ $0.exitActivity }
            .subscribe(onNext: { _ in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isLoading }
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.toast }
            .bind(to: rx.toastNormal)
            .disposed(by: disposeBag)
    
        reactor.state
            .compactMap { state -> (SquadActivity, ActivityMember)? in
                guard state.repos != nil && state.currentMemberProfile != nil else { return nil }
                return (state.repos!, state.currentMemberProfile!)
            }
            .distinctUntilChanged({ (arg0, arg1) -> Bool in
                return arg0.0.isEquadTo(arg1.0) && arg0.1.isEquadTo(arg1.1)
            })
            .subscribe(onNext: { [unowned self] (detail, profile) in
                // 设置标题
                self.title = detail.title
                
                self.configToolbarView(detail: detail, currentMember: profile)
                self.configInfoView(detail: detail, currentMember: profile)
                self.configChooseTimeView(detail: detail, currentMember: profile)
                self.configMapView(detail: detail, currentMember: profile)
                self.configMemberView(detail: detail, currentMember: profile)
                
                self.layoutScrollSubviews()
            })
            .disposed(by: disposeBag)
        
        bindToolbarView(reactor: reactor)
        bindInfoView(reactor: reactor)
        bindChooseTimeView(reactor: reactor)
        bindMapView(reactor: reactor)
        bindMemberView(reactor: reactor)
        
        rx.viewDidLoad
            .map { Reactor.Action.requestDetail }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
//        chooseTimeView.drawView.itemView.timePeriodObservable
//            .map{ Reactor.Action.selectTime($0) }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
    }
    
}

//MARK: - Toolbar 相关
extension ActivityDetailViewController {
    
    private func setupToolbarView()  {
        toolbar.isHidden = true
        toolbar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 48)
        toolbar.theme.backgroundColor = UIColor.secondary
        scrollView.addSubview(toolbar)
    }
    
    private func configToolbarView(detail: SquadActivity,currentMember: ActivityMember) {
        toolbar.isHidden = false
        switch detail.activityStatus {
        case .prepare:
            // 是否为创建者, 并且时间已经设置过了
            if currentMember.accountId == detail.accountId && currentMember.isResponded {
                toolbar.dataSource = [
                    .title("Know your squad's availability?"),
                    .button(flag: "setTime",
                           title: "Set Time",
                           showShadow: true)]
            } else {
                // 在创建者没有Set Time之前, 都可以变更时间
                toolbar.dataSource = [.title("Add your availability!")]
            }
        case .setTime:
            toolbar.dataSource = [
                .title("Going?"),
                .button(flag: "confirmGoing",
                       image: UIImage(named: "Activity Confirm Normal"),
                       disableImage: UIImage(named: "Activity Confirm Focus"),
                       isEnabled: currentMember.isGoing == false),
                .button(flag: "cancelGoing",
                       image: UIImage(named: "Activity Reject Normal"),
                       disableImage: UIImage(named: "Activity Reject Focus"),
                       isEnabled: currentMember.isGoing == true)]
        case .running:
            break
        }
    }
    
    private func bindToolbarView(reactor: ActivityDetailReactor) {
        
        let didTapped: Observable<String> = toolbar.didTapped.share()
        
        didTapped
            .compactMap { flag in
                switch flag {
                case "confirmGoing": return Reactor.Action.handlerGoing(isAccept: true)
                case "cancelGoing": return Reactor.Action.handlerGoing(isAccept: false)
                default: return nil
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
            
        didTapped
            .filter{ $0 == "setTime" }
            .subscribe(onNext: { [unowned self] _ in
                let settingViewController = AvtivityTimeSettingViewController()
                self.transitionPresent(settingViewController, animated: true)
                if let activity = reactor.currentState.repos {
                    settingViewController.activityType = activity.activityType
                }
                settingViewController.topSection = reactor.currentState.topMembers
                settingViewController.bottomSection = reactor.currentState.bottomMembers
                settingViewController.didSelectTime
                    .map{ Reactor.Action.setDetail($0, title: nil, location: nil) }
                    .bind(to: reactor.action)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
}

//MARK: - ChooseTime 相关
extension ActivityDetailViewController {
    
    private func setupChooseTimeView() {
        chooseTimeView.isHidden = true
        chooseTimeView.frame = CGRect(x: 15, y: 0, width: view.bounds.width - 55, height: 320)
        scrollView.addSubview(chooseTimeView)
    }
    
    private func configChooseTimeView(detail: SquadActivity, currentMember: ActivityMember) {
        
        guard detail.activityStatus == .prepare else {
            chooseTimeView.isHidden = true
            return
        }
        chooseTimeView.isHidden = false
        
        // 这里必须传个时间数组过来, 并且不能为空, 因为我们是根据myTime中的第一个元素, 来判断当前选择的日期是哪天
        // 如果后面需求变更了, myTime可为空, 则必须在CreateEvent中增加一个日期的字段, 来表示活动选择的日期
        if !currentMember.myTime.isEmpty, let members = reactor?.currentState.topMembers {
            let originList = members.list.flatMap{ $0.myTime }
            chooseTimeView.setDataSource(myTime: currentMember.myTime, originList: originList)
        }
    }
    
    private func bindChooseTimeView(reactor: ActivityDetailReactor) {
        
//        chooseTimeView.displayView.itemView
//            .didEndSelectedTimeObservable
//            .throttle(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
//            .map{ Reactor.Action. }
        
//        reactor.state
//            .compactMap{ $0.selectedTimes }
//            .bind(to: chooseTimeView.displayView.itemView.rx.setDataSource())
//            .disposed(by: disposeBag)
    }
}

//MARK: - Activity Info 相关
extension ActivityDetailViewController {
    
    private func setupInfoView() {
        infoView.isHidden = true
        infoView.frame = CGRect(x: 33, y: 0, width: view.bounds.width - 64, height: 70)
        scrollView.addSubview(infoView)
    }
    
    private func configInfoView(detail: SquadActivity, currentMember: ActivityMember) {
        switch detail.activityStatus {
        case .prepare:
            infoView.titleBtn.theme.backgroundColor = UIColor.secondary
            infoView.titleBtn.theme.titleColor(from: UIColor.background, for: .normal)
            infoView.titleBtn.frame.size.width = 74
            infoView.titleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            infoView.titleBtn.setTitle("TBD", for: .normal)
            infoView.titleBtn.layer.cornerRadius = 13
        case .setTime:
            infoView.titleBtn.theme.backgroundColor = UIColor.background
            infoView.titleBtn.theme.titleColor(from: UIColor.secondary, for: .normal)
            infoView.titleBtn.frame.size.width = 200
            infoView.titleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            infoView.titleBtn.setTitle("Saturday, April 4 at 1 PM", for: .normal)
            infoView.titleBtn.layer.cornerRadius = 0
        case .running:
            break
        }
        infoView.isHidden = false
        infoView.locationBtn.setTitle("Thai Basil", for: .normal)
        infoView.previewBtn.setImage(detail.activityType.image, for: .normal)
    }
    
    private func bindInfoView(reactor: ActivityDetailReactor) {
        
    }
    
}

//MARK: - Map 地图相关
extension ActivityDetailViewController {
    
    private func setupMapView() {
        let width: CGFloat = view.bounds.width - 66
        mapView.frame = CGRect(x: 33, y: 0, width: width, height: 0.57 * width)
        mapView.isHidden = true
        scrollView.addSubview(mapView)
    }
    
    private func configMapView(detail: SquadActivity, currentMember: ActivityMember) {
        guard detail.activityStatus == .setTime else {
            mapView.isHidden = true
            return
        }
        mapView.isHidden = false
    }
    
    private func bindMapView(reactor: ActivityDetailReactor) {
        
    }
}

//MARK: - Members 成员相关
extension ActivityDetailViewController {
    
    private func setupMemberView() {
        membersView.frame = CGRect(x: 33, y: 0, width: view.bounds.width  - 66, height: 135)
        scrollView.addSubview(membersView)
    }
    
    private func configMemberView(detail: SquadActivity, currentMember: ActivityMember) {
//        guard detail.activityStatus == .setTime else {
//            membersView.isHidden = true
//            return
//        }
        membersView.isHidden = false
    }
    
    private func bindMemberView(reactor: ActivityDetailReactor) {
        
        reactor.state
            .compactMap{ $0.topMembers }
            .bind(to: membersView.rx.topSection)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.bottomMembers }
            .bind(to: membersView.rx.bottomSection)
            .disposed(by: disposeBag)
    }
}

extension ActivityMember: MembersItemProtocol {
    var url: URL? {
        return avatar.asURL
    }
}

