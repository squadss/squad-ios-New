//
//  SquadPreViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxDataSources

class SquadPreViewController: ReactorViewController<SquadPreReactor> {

    var infoView = SquadPreInfoView()
    var menuView = SquadPreMenuView()
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func setupView() {
        
        let leftBarItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(leftBarItemDidTapped))
        leftBarItem.theme.tintColor = UIColor.text
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "Navigation More"), style: .plain, target: self, action: #selector(rightBarItemDidTapped))
        rightBarItem.theme.tintColor = UIColor.text
        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.rightBarButtonItem = rightBarItem
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 320))
        headerView.theme.backgroundColor = UIColor.background
        
        infoView.frame = CGRect(x: 50, y: 32, width: headerView.frame.width - 100, height: 160)
        menuView.frame = CGRect(x: 50, y: infoView.frame.maxY + 45, width: headerView.frame.width - 100, height: 40)
        headerView.addSubviews(infoView, menuView)
        
        #if DEBUG
        // 点击三次获取SquadId, 便于进行邀请, 此功能只在DEBUG下生效
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 3
        tap.rx.event
            .subscribe(onNext: { _ in
                if let id = self.reactor?.currentState.squadDetail?.id {
                    UIPasteboard.general.string = "\(id)"
                    self.showToast(message: "复制SquadId成功")
                }
            })
            .disposed(by: disposeBag)
        headerView.addGestureRecognizer(tap)
        #endif
        
        tableView.rowHeight = 55
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(Reusable.squadPreViewCell)
        view.addSubview(tableView)
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
            .map{ [SectionModel(model: "", items: $0.repos)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.squadDetail }
            .subscribe(onNext: { [unowned self] detail in
                self.infoView.dateString = detail.gmtCreate
                self.infoView.title = detail.squadName
                self.infoView.canEdit = true
                self.infoView.imageURL = detail.logoPath.asURL
                
                self.menuView.daysView.numLab.text = "624"
                self.menuView.daysView.titleLab.text = "DAYS"
                
                self.menuView.textsView.numLab.text = "23K"
                self.menuView.textsView.titleLab.text = "TEXTS"
                
                self.menuView.flicksView.numLab.text = "32"
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
    }
    
    @objc
    private func leftBarItemDidTapped() {
        self.dismiss(animated: true)
    }
    
    @objc
    private func rightBarItemDidTapped() {
        
    }
}
