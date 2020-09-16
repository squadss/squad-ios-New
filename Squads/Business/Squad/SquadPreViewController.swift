//
//  SquadPreViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import JXPhotoBrowser

class SquadPreViewController: ReactorViewController<SquadPreReactor> {

    private var tableView = UITableView()
    private let picker = AvatarPicker()
    private var infoView = SquadPreInfoView()
    private var menuView = SquadPreMenuView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupView() {
        setupTableView()
        setupNavigationItem()
    }
    
    private func setupTableView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 320))
        headerView.theme.backgroundColor = UIColor.background
        infoView.frame = CGRect(x: 50, y: 32, width: headerView.frame.width - 100, height: 160)
        menuView.frame = CGRect(x: 50, y: infoView.frame.maxY + 45, width: headerView.frame.width - 100, height: 40)
        headerView.addSubviews(infoView, menuView)
        
        let rowHeight: CGFloat = UIScreen.main.bounds.height > 667 ? 55 : 45
        tableView.rowHeight = rowHeight
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(Reusable.squadPreViewCell)
        view.addSubview(tableView)
    }
    
    private func setupNavigationItem() {
        
        let leftBarItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(leftBarItemDidTapped))
        leftBarItem.theme.tintColor = UIColor.text
        navigationItem.leftBarButtonItem = leftBarItem
        
        let rightBarItem = UIBarButtonItem()
        rightBarItem.image = UIImage(named: "Navigation More")
        rightBarItem.style = .plain
        rightBarItem.theme.tintColor = UIColor.text
        navigationItem.rightBarButtonItem = rightBarItem
        
        let action: Observable<Int> = rightBarItem.rx.tap
            .flatMap{ [weak self] _ -> Observable<Int> in
                
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                var actions = Array<RxAlertAction>()
                actions.append(RxAlertAction(title: "Change Squad Title", type: 0, style: .default))
                actions.append(RxAlertAction(title: "Cancel", type: -1, style: .cancel))
                return actionSheet
                    .addAction(actions: actions)
                    .map{ $0 }
                    .do(onSubscribed: {
                       self?.present(actionSheet, animated: true, completion: nil)
                    })
            }
            .share()

            action.filter{ $0 == 0 }
                .trackInputAlert(title: NSLocalizedString("squadDetail.changeTitle", comment: ""), placeholder: NSLocalizedString("squadDetail.changeMessage", comment: ""), default: NSLocalizedString("squadDetail.changeConfirm", comment: ""), target: self)
                .map{ Reactor.Action.setDetail(avatar: nil, squadName: $0) }
                .bind(to: reactor!.action)
                .disposed(by: disposeBag)
    }
    
    override func setupConstraints() {
        tableView.snp.safeFull(parent: self)
    }
    
    override func bind(reactor: SquadPreReactor) {
//        infoView.canEditTap.map{  }
//        infoView.imageTap
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SquadPreReactor.Model>>(configureCell: { (data, tableView, indexPath, model) -> UITableViewCell in
            let cell = tableView.dequeue(Reusable.squadPreViewCell)!
            cell.titleLab.text = model.title
            cell.titleLab.isHighlighted = model.isHight
            cell.selectionStyle = .none
            return cell
        })
        
        reactor.state
            .compactMap{ $0.toast }
            .bind(to: rx.toastNormal)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.isLoading }
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        reactor.state
            .map{ [SectionModel(model: "", items: $0.repos)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.squadDetail }
            .subscribe(onNext: { [unowned self] detail in
//                self.infoView.dateString = detail.gmtCreate
                self.infoView.title = detail.squadName
                self.infoView.canEdit = true
                self.infoView.imageURL = detail.logoPath.asURL
                
                self.menuView.daysView.numLab.text = "0"
                self.menuView.daysView.titleLab.text = "DAYS"
                
                self.menuView.textsView.numLab.text = "0"
                self.menuView.textsView.titleLab.text = "TEXTS"
                
                self.menuView.flicksView.numLab.text = "0"
                self.menuView.flicksView.titleLab.text = "FLICKS"
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                switch indexPath.row {
                case 0: //Members
                    let membersReactor = SquadMembersReactor(squadId: reactor.squadId)
                    let vc = SquadMembersViewController(reactor: membersReactor)
                    vc.title = "Members"
                    self.navigationController?.pushViewController(vc, animated: true)
                case 1: //Notifications
                    let notificationReactor = SquadNotificationsReactor()
                    let vc = SquadNotificationsViewController(reactor: notificationReactor)
                    vc.title = "Notifications"
                    self.navigationController?.pushViewController(vc, animated: true)
                case 2: // Theme
                    let themeReactor = SquadThemeReactor()
                    let vc = SquadThemeViewController(reactor: themeReactor)
                    vc.title = "Theme"
                    self.navigationController?.pushViewController(vc, animated: true)
                case 3: // Invith New
                    let invithNewReactor = SquadInvithNewReactor(squadId: reactor.squadId)
                    let vc = SquadInvithNewViewController(reactor: invithNewReactor)
                    self.navigationController?.pushViewController(vc, animated: true)
                case 4: // Leave Squad
                    let alert = UIAlertController(title: "Make sure to leave Squad?", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                        self.showToast(message: "Leave the success!")
                    }))
                    self.present(alert, animated: true)
                default:
                    fatalError("未配置")
                }
            })
            .disposed(by: disposeBag)
        
        rx.viewDidLoad
            .filter{ reactor.currentState.squadDetail == nil }
            .map{ Reactor.Action.refreshSquadDetail }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        infoView.imageTap.subscribe(onNext: { url in
            let browser = JXPhotoBrowser()
            browser.numberOfItems = { 1 }
            browser.reloadCellAtIndex = { context in
                let cell = context.cell as? JXPhotoBrowserImageCell
                cell?.imageView.kf.setImage(with: url)
            }
            browser.cellClassAtIndex = { _ in JXPhotoBrowserImageCell.self }
            browser.pageIndex = 0
            browser.show()
        })
        .disposed(by: disposeBag)
        
        infoView.canEditTap
            .flatMap { [unowned self] in
                self.picker.image(optionSet: [.camera, .photo], delegate: self)
            }
            .map{
                let data = $0.0.compressImage(toByte: 200000)
                return Reactor.Action.setDetail(avatar: data, squadName: nil)
            }
            .bind(to: reactor.action)
            .disposed(by: rx.disposeBag)
    }
    
    @objc
    private func leftBarItemDidTapped() {
        self.dismiss(animated: true)
    }
}
