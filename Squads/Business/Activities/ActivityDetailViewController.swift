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
    
    private var toolbar: ActivityDetailToolbar?
    private var infoView: ActivityDetailInfoView?
    private var chooseTimeView: MultipleChooseTimeView?
    private var mapView: UIView?
    private var membersView: MembersGroupView?
    private var chattingView: ChattingCardView?
    private let scrollView = UIScrollView()
    
    override var allowedCustomBackBarItem: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.snp.safeFull(parent: self)
        view.theme.backgroundColor = UIColor.background
        
        let leftBtn = UIButton()
        leftBtn.setTitle("Back", for: .normal)
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        leftBtn.theme.titleColor(from: UIColor.text, for: .normal)
        leftBtn.addTarget(self, action: #selector(leftBtnDidTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        //自定义右导航按钮
        let rightBtn = UIButton()
        rightBtn.setImage(UIImage(named: "Navigation More"), for: .normal)
        rightBtn.addTarget(self, action: #selector(rightBtnBtnDidTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    
    @objc
    private func leftBtnDidTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func rightBtnBtnDidTapped() {
        
    }

    override func setupView() {
        layoutUI()
    }
    
    private func setupToolbar(reactor: ActivityDetailReactor) {
        guard toolbar == nil else { return }
        toolbar = ActivityDetailToolbar()
        toolbar?.theme.backgroundColor = UIColor.secondary
        toolbar?.didTapped.subscribe(onNext: { [unowned self] flag in
            switch ActivityDetailReactor.ToolbarAction(rawValue: flag) {
            case .setTime:
                let settingViewController = AvtivityTimeSettingViewController()
                self.transitionPresent(settingViewController, animated: true)
                
                settingViewController.contentView.respondedMembers = [URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!]

                settingViewController.contentView.waitingMembers = [URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!]
        //
        //        timeSettingView.didTapped
        //            .subscribe(onNext: {
        //                print($0)
        //            }).disposed(by: disposeBag)
                
            case .availabilityConfirm:
                break
            case .availabilityCancel:
                break
            case .goingConfirm:
                break
            case .goingCancel:
                break
            case .none:
                break
            }
        })
        .disposed(by: disposeBag)
    }
    
    private func setupInfoView(reactor: ActivityDetailReactor) {
        guard infoView == nil else { return }
        infoView = ActivityDetailInfoView()
        infoView?.titleBtn.theme.backgroundColor = UIColor.secondary
        infoView?.titleBtn.theme.titleColor(from: UIColor.background, for: .normal)
        infoView?.titleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        infoView?.titleBtn.layer.cornerRadius = 13
        infoView?.titleBtn.setTitle("Saturday, April 4 at 1 PM", for: .normal)
        
//        infoView?.titleBtn.theme.titleColor(from: UIColor.secondary, for: .normal)
//        infoView?.titleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//        infoView?.titleBtn.setTitle("TBD", for: .normal)
        
        infoView?.locationBtn.setTitle("Thai Basil", for: .normal)
        infoView?.previewBtn.kf.setImage(with: URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg"), for: .normal)
    }
    
    private func setupChooseTimeView(reactor: ActivityDetailReactor) {
        guard chooseTimeView == nil else { return }
        
        chooseTimeView = MultipleChooseTimeView()
        
        let leftView = TimeLineDrawTapView()
        chooseTimeView?.leftView.set(leftView)
        chooseTimeView?.leftView.title = "SQUAD AVAILABILIT"
        
        let rightView = TimeLineDrawPageView()
        chooseTimeView?.rightView.set(rightView)
        chooseTimeView?.rightView.title = "CLICK YOUR TIME"
    }
    
    private func setupMapView(reactor: ActivityDetailReactor) {
        guard mapView == nil else { return }
        mapView = UIView()
    }
    
    private func setupMemberView(reactor: ActivityDetailReactor) {
        guard membersView == nil else { return }
        membersView = MembersGroupView()
    }
    
    private func setupChattingView(reactor: ActivityDetailReactor) {
        guard chattingView == nil else { return }
        chattingView = ChattingCardView.hero()
        chattingView?.headerView.switchBtn.rx.tap.subscribe(onNext: { [unowned self] in
            let reactor = ChattingPreviewReactor()
            let chattingVC = ChattingPreviewViewController(reactor: reactor)
            let nav = BaseNavigationController(rootViewController: chattingVC)
            nav.hero.isEnabled = true
            nav.hero.modalAnimationType = .selectBy(presenting: .fade, dismissing: .fade)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        })
        .disposed(by: disposeBag)
    }
    
    private func layoutUI() {
        
        var contentHeight: CGFloat = 0
        scrollView.subviews.forEach{ $0.removeFromSuperview() }
        
        if let unwrappedToolbar = toolbar {
            toolbar?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 48)
            scrollView.addSubview(unwrappedToolbar)
            contentHeight += unwrappedToolbar.frame.height
        }
        
        if let unwrappedInfoView = infoView {
            let offsetY: CGFloat = 14
            infoView?.frame = CGRect(x: 33, y: contentHeight + offsetY, width: view.bounds.width - 64, height: 70)
            scrollView.addSubview(unwrappedInfoView)
            contentHeight += unwrappedInfoView.frame.height + offsetY
        }
        
        if let unwrappedView = chooseTimeView {
            chooseTimeView?.frame = CGRect(x: 25, y: contentHeight, width: view.bounds.width - 55, height: 320)
            scrollView.addSubview(unwrappedView)
            contentHeight += unwrappedView.frame.height
        }
        
        if let unwrappedView = mapView {
            mapView?.frame = CGRect(x: 33, y: contentHeight, width: view.bounds.width - 66, height: 300)
            scrollView.addSubview(unwrappedView)
            contentHeight += unwrappedView.frame.height
        }
        
        if let unwrappedView = membersView {
            membersView?.frame = CGRect(x: 33, y: contentHeight, width: view.bounds.width  - 66, height: 135)
            scrollView.addSubview(unwrappedView)
            contentHeight += unwrappedView.frame.height
        }
        
        if let unwrappedView = chattingView {
            chattingView?.frame = CGRect(x: 0, y: contentHeight, width: view.bounds.width, height: 230)
            scrollView.addSubviews(unwrappedView)
            contentHeight += unwrappedView.frame.height
        }
        
        scrollView.contentSize = CGSize(width: view.bounds.width, height: contentHeight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 根据activityState 来确定显示哪一种
            toolbar?.dataSource = [.title("Know your squad's availability?"), .button(flag: "setTime", title: "Set Time", image: nil, showShadow: true)]
//                toolbar.dataSource = [.title("Mark your availability!"),
//                                      .button(flag: "confirmAvailability", title: nil, image: UIImage(named: "Activities Yes")),
//                                      .button(flag: "cancelAvailability", title: nil, image: UIImage(named: "Activities No"))]
//                toolbar.dataSource = [.title("Going?"),
//                                      .button(flag: "confirmGoing", title: nil, image: UIImage(named: "Activities Yes")),
//                                      .button(flag: "cancelGoing", title: nil, image: UIImage(named: "Activities No"))]
        
        // 加载消息
        chattingView?.loadFirstMessages()
        
        // 显示成员信息
        membersView?.topTitle = "RESPONDED"
        membersView?.topList = [URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!]
        membersView?.bottomTitle = "WAITING"
        membersView?.bottomList = [URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!]
        
//        chooseTimeView?.rightView.axisXDates = []
//
//        chooseTimeView?.leftView.axisXDates = []
    }
    
    override func bind(reactor: ActivityDetailReactor) {
        
        reactor.state
            .map{ $0.activityStatus }
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] state in
                switch state {
                case .create:
                    self.setupToolbar(reactor: reactor)
                    self.setupInfoView(reactor: reactor)
                    self.setupChooseTimeView(reactor: reactor)
                    self.setupMemberView(reactor: reactor)
                    self.setupChattingView(reactor: reactor)
                default: break
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc
    private func btnDidTapped() {
        
    }
    
}

extension RxSwift.Reactive where Base: UIViewController {
    public var viewDidLoad: Observable<Void> {
        return methodInvoked(#selector(UIViewController.viewDidLoad))
            .map { _ in return }
    }
    
    public var viewWillAppear: Observable<Void> {
        return methodInvoked(#selector(UIViewController.viewWillAppear))
            .map { _ in return }
    }
}

extension RxSwift.Reactive where Base: UIApplication {
    
    public var delegate: DelegateProxy<UIApplication, UIApplicationDelegate> {
        return RxApplicationDelegateProxy.proxy(for: base)
    }
    
    public var applicationWillEnterForeground: Observable<Void> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationWillEnterForeground(_:))).map{ _ in () }
    }
    
    public var applicationDidEnterBackground: Observable<Void> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationDidEnterBackground(_:)))
            .map { _ in () }
    }
}

open class RxApplicationDelegateProxy: DelegateProxy<UIApplication, UIApplicationDelegate>, DelegateProxyType, UIApplicationDelegate {
    
    // Typed parent object.
    public weak private(set) var application: UIApplication?
    
    init(application: ParentObject) {
        self.application = application
        super.init(parentObject: application, delegateProxy: RxApplicationDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxApplicationDelegateProxy(application: $0) }
    }
    
    public static func currentDelegate(for object: UIApplication) -> UIApplicationDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: UIApplicationDelegate?, to object: UIApplication) {
        object.delegate = delegate
    }
    
    override open func setForwardToDelegate(_ forwardToDelegate: UIApplicationDelegate?, retainDelegate: Bool) {
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: true)
    }
    
}
