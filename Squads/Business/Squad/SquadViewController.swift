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
import RxSwift
import RxDataSources
import JXPhotoBrowser

final class SquadViewController: ReactorViewController<SquadReactor>, UITableViewDelegate {

    private var stackView: UIStackView!
    private var separatorLine = SeparatorLine()
    private var tableView = UITableView(frame: .zero, style: .grouped)
    private var sideMenuManager = SideMenuManager()
    
    private var titleBarView: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 44))
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        btn.setTitle("Squad Page", for: .normal)
        return btn
    }()
    
    //NavigationBarTitleView
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, SquadPrimaryKey>>!
    override var allowedCustomBackBarItem: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
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
        
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(Reusable.squadActivityCell)
        tableView.register(Reusable.squadChannelsCell)
        tableView.register(Reusable.squadPlaceholderCell)
        tableView.register(Reusable.squadSqrollCell)
        tableView.theme.backgroundColor = UIColor.background
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.001))
        
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
        
        var setting = SideMenuSettings()
        setting.statusBarEndAlpha = 0
        setting.menuWidth = view.bounds.width * 0.8
        setting.dismissDuration = 0.5
        setting.completionCurve = .linear
        
        let menu = CustomSideMenuNavigationController(rootViewController: rootVC, settings: setting)
        let style = SideMenuPresentationStyle.menuSlideIn
        style.presentingEndAlpha = 0.6
        menu.presentationStyle = style
        sideMenuManager.leftMenuNavigationController = menu
    }
    
    private func setupTitleView() {
        titleBarView.theme.titleColor(from: UIColor.text, for: .normal)
        titleBarView.addTarget(self, action: #selector(titleBtnDidTapped), for: .touchUpInside)
        addToTitleView(titleBarView)
    }
    
    override func addTouchAction() {
        guard let squadId = reactor?.currentState.currentSquadId else { return }
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                if indexPath.section == 1 {
                    let activityReactor = ActivityDetailReactor()
                    let activityDetailVC = ActivityDetailViewController(reactor: activityReactor)
                    self.navigationController?.pushViewController(activityDetailVC, animated: true)
                } else if indexPath.section == 2 {
                    let model = self.dataSource[indexPath] as! SquadChannel
                    let chattingVC = ChattingViewController(action: .load(groupId: model.sessionId, squadId: squadId))
                    self.navigationController?.pushViewController(chattingVC, animated: true)
                }
            })
            .disposed(by: disposeBag)
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
                cell.contentLab.text = "RSF"
                cell.titleLab.text = "Lunch"
                cell.dateLab.text = "TODAY AT 1:30 PM"
                cell.pritureView.kf.setImage(with: URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg"))
                cell.membersView.members = [URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!]
                
                cell.containterView.borderColor = .red
                cell.selectionStyle = .none
                return cell
            case is SquadChannel:
                let cell = tableView.dequeue(Reusable.squadChannelsCell)!
                cell.selectionStyle = .none
                cell.setData(model as! SquadChannel)
                return cell
            case is SquadSqroll:
                let cell = tableView.dequeue(Reusable.squadSqrollCell)!
                let list = (model as! SquadSqroll).list
                cell.dataSubject.onNext(list)
                cell.tapObservable
                    .subscribe(onNext: {
                        let browser = JXPhotoBrowser()
                        browser.numberOfItems = { list.count }
                        browser.reloadCellAtIndex = { context in
                            let cell = context.cell as? JXPhotoBrowserImageCell
                            cell?.imageView.kf.setImage(with: list[context.index].asURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
                        }
                        browser.cellClassAtIndex = { _ in JXPhotoBrowserImageCell.self }
                        browser.pageIndex = list.firstIndex(of: $0) ?? 0
                        browser.show()
                    })
                    .disposed(by: cell.disposeBag)
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
        
        rx.viewWillAppear
            .map{ Reactor.Action.refreshChannels }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable
            .just(Reactor.Action.initialSDK)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    @objc
    private func menuBtnDidTapped(sender: UIButton) {
        let index = sender.tag - 200
        switch index {
        case 0: //Calendar
            let reactor = CreateEventReactor()
            let vc = CreateEventViewController(reactor: reactor)
            vc.title = "Create Event"
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        case 1: // New Memory
            let reactor = CreateFlickReactor()
            let vc = CreateFlickViewController(reactor: reactor)
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            reactor.state
                .filter{ $0.postSuccess == true }
                .subscribe(onNext: { [unowned self] _ in
                    let reactor = FlicksReactor()
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
        //FIXME: - SquadId暂时为空
        let preReactor = SquadPreReactor(squadId: "")
        let preViewController = SquadPreViewController(reactor: preReactor)
        let nav = BaseNavigationController(rootViewController: preViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    @objc
    private func leftBtnDidTapped() {
        present(sideMenuManager.leftMenuNavigationController!, animated: true)
    }
    
    @objc
    private func rightBtnBtnDidTapped() {
        let reactor = FlicksReactor()
        let vc = FlicksViewController(reactor: reactor)
        vc.title = "Flicks"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func activitiesBtnDidTapped() {
        let reactor = SquadActivitiesReactor()
        let vc = SquadActivitiesViewController(reactor: reactor)
        vc.title = "Activities"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func channelBtnDidTapped() {
        //创建一个Channel
        guard let currentSquadId = reactor?.currentState.currentSquadId else { return }
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
            
            let attachBtn = UIButton()
            attachBtn.setTitleColor(UIColor(red: 0.93, green: 0.38, blue: 0.34, alpha: 1.0), for: .normal)
            attachBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            attachBtn.setTitle("See All ", for: .normal)
            attachBtn.addTarget(self, action: #selector(activitiesBtnDidTapped), for: .touchUpInside)
            attachBtn.contentHorizontalAlignment = .right
            
            var layout = SquadSectionTitleLayout()
            layout.btnWidth = 60
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
        case is SquadSqroll:
            return 100.0
        default:
            fatalError("没有配置cell")
        }
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
