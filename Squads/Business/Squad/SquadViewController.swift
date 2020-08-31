//
//  SquadViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import SideMenu
import SnapKit
import RxCocoa
import RxSwift
import RxDataSources
import JXPhotoBrowser

enum RefreshChannelsAction {
    case update(list: Array<V2TIMConversation>)
    case insert(list: Array<V2TIMConversation>)
}

enum RefreshsPageAction {
    case network
    case cache
}

final class SquadViewController: ReactorViewController<SquadReactor>, UITableViewDelegate {

    private var stackView: UIStackView!
    private var separatorLine = SeparatorLine()
    private var tableView = UITableView(frame: .zero, style: .grouped)
    
    private var titleBarView: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 44))
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return btn
    }()
    
    private var onConversationChangedRelay = PublishRelay<RefreshChannelsAction>()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, SquadPrimaryKey>>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
        V2TIMManager.sharedInstance()?.setConversationListener(self)
    }
    
    override func setupView() {
        
        //自定义导航栏按钮
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "navigation_back"), for: .normal)
        leftBtn.setImage(UIImage(named: ""), for: .selected)
        leftBtn.addTarget(self, action: #selector(leftBtnDidTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        //自定义右导航按钮
        let rightBtn = UIButton()
        rightBtn.setImage(UIImage(named: "navigation_album_normal"), for: .normal)
        rightBtn.addTarget(self, action: #selector(rightBtnBtnDidTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        
        //自定义底部menu
        let menuList: Array<UIImage?> = [
            UIImage(named: "Calendar Icon"),
            UIImage(named: "New Memory Icon")
//            ,
//            UIImage(named: "Game Icon"),
//            UIImage(named: "Phone Icon"),
        ]
        let menuViews: Array<UIView> = menuList.enumerated().map{ (index, image) in
            let btn = UIButton()
            btn.tag = index + 200
            btn.setImage(image, for: .normal)
            btn.addTarget(self, action: #selector(menuBtnDidTapped(sender:)), for: .touchUpInside)
            return btn
        }
        stackView = UIStackView(arrangedSubviews: menuViews)
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.backgroundColor = .white
        view.addSubview(stackView)
        
        view.addSubview(separatorLine)
        
        tableView.separatorStyle = .none
        tableView.register(Reusable.squadActivityCell)
        tableView.register(Reusable.squadChannelsCell)
        tableView.register(Reusable.squadPlaceholderCell)
        tableView.register(Reusable.squadSqrollCell)
        tableView.theme.backgroundColor = UIColor.background
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.001))
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        view.addSubview(tableView)
        
        setupSideMenu()
        setupTitleView()
    }
    
    private func setupSideMenu() {
        
        let profileReactor = MyProfileReactor()
        let rootVC = MyProfileViewController(reactor: profileReactor)
        rootVC.itemSelected
            .map{ Reactor.Action.requestSquad(id: $0) }
            .bind(to: reactor!.action)
            .disposed(by: disposeBag)
        
        onConversationChangedRelay
            .map{ MyProfileReactor.Action.refreshChannels($0) }
            .bind(to: profileReactor.action)
            .disposed(by: disposeBag)
        
        var setting = SideMenuSettings()
        setting.statusBarEndAlpha = 0
        setting.menuWidth = view.bounds.width * 0.8
        setting.dismissDuration = 0.5
        setting.completionCurve = .linear
        
        let menu = CustomSideMenuNavigationController(rootViewController: rootVC, settings: setting)
        let style = SideMenuPresentationStyle.menuSlideIn
        style.presentingEndAlpha = 0.6
        menu.presentationStyle = style
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
    }
    
    private func setupTitleView() {
        titleBarView.theme.titleColor(from: UIColor.text, for: .normal)
        titleBarView.addTarget(self, action: #selector(titleBtnDidTapped), for: .touchUpInside)
        addToTitleView(titleBarView)
    }
    
    override func setupConstraints() {
        
        tableView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                maker.top.equalTo(topLayoutGuide.snp.bottom)
            }
        }
        
        separatorLine.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(tableView.snp.bottom)
        }
        
        stackView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
            maker.top.equalTo(separatorLine.snp.bottom)
            maker.height.equalTo(50)
        }
    }
    
    override func bind(reactor: SquadReactor) {
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SquadPrimaryKey>>(configureCell: { (data, tableView, indexPath, model) -> UITableViewCell in
            switch model {
            case is SquadPlaceholder:
                let cell = tableView.dequeue(Reusable.squadPlaceholderCell)!
                cell.content = (model as! SquadPlaceholder).content
                cell.selectionStyle = .none
                return cell
            case is SquadActivity:
                let cell = tableView.dequeue(Reusable.squadActivityCell)!
                let model = model as! SquadActivity
                cell.titleLab.text = model.title
                cell.pritureView.image = model.activityType.image
                cell.dateLab.text = model.startDate
                
                if case .virtual = model.activityType {
                    cell.contentLab.text = "Virtual"
                } else if let address = model.position?.address {
                    cell.contentLab.text = address
                }
                
                if model.activityStatus == .prepare {
                    cell.containterView.borderColor = nil
                    if let members = model.responsedMembers, !members.isEmpty {
                        cell.membersView.setMembers(members: members.map{ $0.avatar.asURL })
                    }
                } else {
                    cell.containterView.borderColor = .red
                    if let members = model.goingMembers, !members.isEmpty {
                        cell.membersView.setMembers(members: members.map{ $0.avatar.asURL })
                    }
                }
                
                cell.selectionStyle = .none
                return cell
            case is SquadChannel:
                let cell = tableView.dequeue(Reusable.squadChannelsCell)!
                cell.selectionStyle = .none
                cell.setData(model as! SquadChannel)
                return cell
            case is Array<URL>:
                let cell = tableView.dequeue(Reusable.squadSqrollCell)!
                let list = (model as! Array<URL>)
                cell.dataSource = list
                cell.tapObservable
                    .subscribe(onNext: {
                        let browser = JXPhotoBrowser()
                        browser.numberOfItems = { list.count }
                        browser.reloadCellAtIndex = { context in
                            let cell = context.cell as? JXPhotoBrowserImageCell
                            cell?.imageView.kf.setImage(with: list[context.index], placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
                        }
                        browser.cellClassAtIndex = { _ in JXPhotoBrowserImageCell.self }
                        browser.pageIndex = list.firstIndex(of: $0) ?? 0
                        browser.show()
                    })
                    .disposed(by: cell.disposeBag)
                cell.backgroundColor = .white
                cell.selectionStyle = .none
                return cell
            default:
                fatalError("没有配置cell")
            }
        })
        
        reactor.state
            .filter{ $0.loginStateDidExpired }
            .trackAlertJustConfirm(title: "Authentication has expired!", default: "To log in", target: self)
            .subscribe(onNext: { _ in
                User.removeCurrentUser()
                AuthManager.removeToken()
                UserDefaults.standard.topSquad = nil
                Application.shared.presentInitialScreent()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map{ $0.repos.map{ SectionModel(model: "", items: $0)} }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.isLoading }
            .bind(to: titleBarView.rx.activityIndicator)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.currentSquadDetail?.squadName }
            .bind(to: titleBarView.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        onConversationChangedRelay
            .map{ Reactor.Action.refreshChannels($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                let squadId = reactor.currentSquadId
                switch indexPath.section {
                case 1:
                    if let model = self.dataSource[indexPath] as? SquadActivity {
                        let activityReactor = ActivityDetailReactor(activityId: model.id, squadId: squadId, initialActivityStatus: model.activityStatus)
                        let activityDetailVC = ActivityDetailViewController(reactor: activityReactor)
                        let nav = BaseNavigationController(rootViewController: activityDetailVC)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true)
                    } else {
                        let reactor = CreateEventReactor(squadId: squadId)
                        let vc = CreateEventViewController(reactor: reactor)
                        vc.title = "Create Event"
                        let nav = BaseNavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true)
                    }
                case 2:
                    if let model = self.dataSource[indexPath] as? SquadChannel {
                        let chattingVC = ChattingViewController(action: .load(groupId: model.sessionId, groupName: model.title, squadId: squadId))
                        self.navigationController?.pushViewController(chattingVC, animated: true)
                    }
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell
            .filter{ $1.section == 1 }
            .compactMap{ [unowned self] in self.dataSource[$1] as? SquadActivity }
            .distinctUntilChanged({ $0.isEquadTo($1) })
            .map{ Reactor.Action.didDisplayCell($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        //FIXME: - 后期会更改这种方式
        rx.viewWillAppear
            .map{ Reactor.Action.refreshPage(.network) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    @objc
    private func menuBtnDidTapped(sender: UIButton) {
        let index = sender.tag - 200
        switch index {
        case 0: //Calendar
            let squadId = reactor!.currentSquadId
            let reactor = CreateEventReactor(squadId: squadId)
            let vc = CreateEventViewController(reactor: reactor)
            vc.title = "Create Event"
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        case 1: // New Memory
            let squadId = reactor!.currentSquadId
            let reactor = CreateFlickReactor(squadId: squadId)
            let vc = CreateFlickViewController(reactor: reactor)
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            reactor.state
                .filter{ $0.postSuccess == true }
                .subscribe(onNext: { [unowned self] _ in
                    let reactor = FlicksReactor(squadId: squadId)
                    let vc = FlicksViewController(reactor: reactor)
                    vc.title = "Flicks"
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                .disposed(by: disposeBag)
        case 2: // Game
            let reactor = SquadGameReactor()
            let vc = SquadGameViewController(reactor: reactor)
            navigationController?.pushViewController(vc, animated: true)
        case 3: // Phone
            let reactor = SquadPhoneReactor()
            let vc = SquadPhoneViewController(reactor: reactor)
            navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }

    @objc
    private func titleBtnDidTapped() {
        guard let squadDetail = reactor?.currentState.currentSquadDetail else { return }
        let preReactor = SquadPreReactor(squadDetail: squadDetail)
        let preViewController = SquadPreViewController(reactor: preReactor)
        let nav = BaseNavigationController(rootViewController: preViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    @objc
    private func leftBtnDidTapped() {
        let vc = SideMenuManager.default.leftMenuNavigationController
        vc.flatMap { present($0, animated: true) }
    }
    
    @objc
    private func rightBtnBtnDidTapped() {
        let squadId = reactor!.currentSquadId
        let reactor = FlicksReactor(squadId: squadId)
        let vc = FlicksViewController(reactor: reactor)
        vc.title = "Flicks"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func activitiesBtnDidTapped() {
        guard let currentSquadId = reactor?.currentSquadId else { return }
        let reactor = SquadActivitiesReactor(squadId: currentSquadId)
        let vc = SquadActivitiesViewController(reactor: reactor)
        vc.title = "Activities"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func channelBtnDidTapped() {
        //创建一个Channel
        guard let currentSquadId = reactor?.currentSquadId else { return }
        let chattingVC = ChattingViewController(action: .create(squadId: currentSquadId))
        self.navigationController?.pushViewController(chattingVC, animated: false)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0: //Sqroll
            let rect = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 36)
            let titleView = SquadSectionTitleView(frame: rect)
            titleView.titleLab.text = "Sqroll"
            return titleView
        case 1: //Activities
            let color = UIColor(red: 0.93, green: 0.38, blue: 0.34, alpha: 1.0)
            let attachBtn = UIButton()
            attachBtn.setTitleColor(color, for: .normal)
            attachBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            attachBtn.setTitle("See All ", for: .normal)
            attachBtn.addTarget(self, action: #selector(activitiesBtnDidTapped), for: .touchUpInside)
            attachBtn.contentHorizontalAlignment = .right
            
            if reactor?.currentState.currentSquadDetail?.hasMoreActivities == true {
                let size = CGSize(width: 2, height: 2)
                let offset = CGPoint(x: 1, y: 0)
                let image = UIImage(color: color, size: size, offset: offset, radius: 1)
                attachBtn.setImage(image, for: .normal)
            }
            
            var layout = SquadSectionTitleLayout()
            layout.btnWidth = 70
            layout.marginRight = 14
            
            let rect = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 36)
            let titleView = SquadSectionTitleView(frame: rect)
            titleView.titleLab.text = "Activities"
            titleView.attachBtn = attachBtn
            titleView.layout = layout
            return titleView
        case 2: //Channels
            
            let attachBtn = UIButton()
            attachBtn.setImage(UIImage(named: "Union Icon"), for: .normal)
            attachBtn.addTarget(self, action: #selector(channelBtnDidTapped), for: .touchUpInside)
            
            var layout = SquadSectionTitleLayout()
            layout.btnWidth = 38
            layout.marginRight = 2
            
            let rect = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 36)
            let titleView = SquadSectionTitleView(frame: rect)
            titleView.titleLab.text = "Channels"
            titleView.attachBtn = attachBtn
            titleView.layout = layout
            return titleView
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = dataSource[indexPath]
        switch model {
        case is SquadPlaceholder:
            return 60.0
        case is SquadActivity:
            return 81.0
        case is SquadChannel:
            return 70.0
        case is Array<URL>:
            return 100.0
        default:
            fatalError("没有配置cell")
        }
    }
    
}

extension SquadViewController: V2TIMConversationListener {
    
    //有新的会话（比如收到一个新同事发来的单聊消息、或者被拉入了一个新的群组中），可以根据会话的 lastMessage -> timestamp 重新对会话列表做排序。
    func onNewConversation(_ conversationList: [V2TIMConversation]!) {
        onConversationChangedRelay.accept(.insert(list: conversationList))
    }
    
    // 某些会话的关键信息发生变化（未读计数发生变化、最后一条消息被更新等等），可以根据会话的 lastMessage -> timestamp 重新对会话列表做排序。
    func onConversationChanged(_ conversationList: [V2TIMConversation]!) {
        onConversationChangedRelay.accept(.update(list: conversationList))
    }
}

fileprivate class CustomSideMenuNavigationController: SideMenuNavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false
        navigationBar.setBackgroundImage(UIImage(color: UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)), for: .default)
        
        if #available(iOS 11, *) {
            navigationBar.shadowImage = UIImage()
        }
        else {
            //此方法会导致在push到下个页面时，状态栏会闪一下，因此需要给状态栏加个白色背景
            navigationBar.clipsToBounds = true
            
            let window = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow
            let statusBar = window?.value(forKey: "statusBar") as? UIView
            statusBar?.backgroundColor = .white
        }
    }
    
}
