//
//  MyProfileViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import JXPhotoBrowser
import ETNavBarTransparent

class MyProfileViewController: ReactorViewController<MyProfileReactor> {

    var itemSelected: Observable<Int> {
        return tableView.rx.itemSelected.map{ [unowned self] in
            return self.dataSource[$0].squadDetail.id
        }.do(onNext: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                self?.dismiss(animated: true)
            }
        })
    }
    
    private var user: User?
    private var tableView = UITableView()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, MyProfileReactor.Model>>!
    
    var headerView = MyProfileHeaderView()
    var footerView = MyProfileFooterView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        user = User.currentUser()
        
        headerView.applyBtn.isHidden = false
        headerView.applyBtn.setTitle("Requests", for: .normal)
        headerView.applyBtn.addTarget(self, action: #selector(applyBtnDidTapped), for: .touchUpInside)
        headerView.contentLab.text = user?.username
        headerView.nicknameLab.text = user?.nickname
        headerView.avatarBtn.kf.setImage(with: user?.avatar.asURL, for: .normal)
    }
    
    override func setupView() {
        tableView.rowHeight = 52
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(Reusable.mySquadsViewCell)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tableView.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        view.addSubview(tableView)
        
        headerView.avatarBtn.addTarget(self, action: #selector(avatarBtnDidTapped(sender:)), for: .touchUpInside)
        view.addSubview(headerView)
        
        view.addSubview(footerView)
    }
    
    override func setupConstraints() {
        
        headerView.snp.makeConstraints { (maker) in
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            } else {
                maker.top.equalTo(topLayoutGuide.snp.bottom).offset(10)
            }
            maker.trailing.leading.equalToSuperview()
            maker.height.equalTo(108)
        }
        
        tableView.snp.makeConstraints { (maker) in
            maker.leading.equalTo(headerView)
            maker.trailing.equalTo(-14)
            maker.top.equalTo(headerView.snp.bottom)
            maker.height.equalTo(245)
        }
        
        footerView.snp.makeConstraints { (maker) in
            maker.top.equalTo(tableView.snp.bottom).offset(-20)
            maker.leading.trailing.equalTo(headerView)
            maker.height.equalTo(250)
        }
    }
    
    override func bind(reactor: MyProfileReactor) {
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, MyProfileReactor.Model>>(configureCell: { (data, tableView, indexPath, model) -> UITableViewCell in
            let cell = tableView.dequeue(Reusable.mySquadsViewCell)!
            cell.pritureView.kf.setImage(with: model.squadDetail.logoPath.asURL)
            cell.titleLab.text = model.squadDetail.squadName
            cell.unreadNum = model.unreadCount
//            cell.titleLab.text = model.title
//            cell.contentLab.text = model.content
//            cell.longObservable
//                .subscribe(onNext: { [unowned self] in
//                    UIPasteboard.general.string = model.content
//                    self.showToast(message: "Copy Success!")
//                })
//                .disposed(by: cell.disposeBag)
            cell.selectionStyle = .none
            return cell
        })
        
        reactor.state
            .map{ [SectionModel(model: "", items: $0.repos)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .map{ Reactor.Action.requestAllSquads }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    @objc
    private func applyBtnDidTapped() {
        let reactor = ApplyListReactor()
        let applyListViewController = ApplyListViewController(reactor: reactor)
        applyListViewController.title = "Requests"
        navigationController?.pushViewController(applyListViewController, animated: true)
    }
    
    @objc
    private func avatarBtnDidTapped(sender: UIButton) {
        let browser = JXPhotoBrowser()
        browser.numberOfItems = { 1 }
        browser.reloadCellAtIndex = { [weak self]context in
            let cell = context.cell as? JXPhotoBrowserImageCell
            cell?.imageView.kf.setImage(with: self?.user?.avatar.asURL)
        }
        browser.cellClassAtIndex = { _ in JXPhotoBrowserImageCell.self }
        browser.pageIndex = 0
        browser.show()
    }
    
    override func addTouchAction() {
        
        footerView.addTapped
            .subscribe(onNext: { [unowned self] in
                let createVC = CreateSquadViewController()
                let nav = BaseNavigationController(rootViewController: createVC)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            })
            .disposed(by: disposeBag)
        
        footerView.itemSelected
            .subscribe(onNext: { [unowned self] flag in
                switch flag {
                case "profile":
                    guard let accountId = self.user?.id else { return }
                    let friendReactor = FriendProfileReactor(accountId: accountId)
                    let friendVC = FriendProfileViewController(reactor: friendReactor)
                    let nav = BaseNavigationController(rootViewController: friendVC)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true)
                case "notifications":
                    let notificationReactor = SquadNotificationsReactor()
                    let vc = SquadNotificationsViewController(reactor: notificationReactor)
                    vc.title = "Notifications"
                    self.navigationController?.pushViewController(vc, animated: true)
                case "inviteFrients":
                    if let squadId = UserDefaults.standard.topSquad {
                        let invithNewReactor = SquadInvithNewReactor(squadId: squadId)
                        let vc = SquadInvithNewViewController(reactor: invithNewReactor)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                case "help":
                    self.showToast(message: "It has not been opened yet, please look forward to it")
                case "logOut":
                    let alert = UIAlertController(title: "Make sure to leave Squad?", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                        self.showToast(message: "Exit the success!")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            User.removeCurrentUser()
                            AuthManager.removeToken()
                            UserDefaults.standard.topSquad = nil
                            Application.shared.presentInitialScreent()
                        }
                    }))
                    self.present(alert, animated: true)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}

