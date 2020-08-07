//
//  SquadMembersViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxDataSources

class SquadMembersViewController: ReactorViewController<SquadMembersReactor> {

    var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.theme.backgroundColor = UIColor.background
    }
    
    override func setupView() {
        
        //自定义右导航按钮
        let rightBtn = UIButton()
        rightBtn.setTitle("Add", for: .normal)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        rightBtn.setTitleColor(UIColor(red: 0.925, green: 0.384, blue: 0.337, alpha: 1), for: .normal)
        rightBtn.addTarget(self, action: #selector(rightBtnBtnDidTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        
        tableView.rowHeight = 70
        tableView.register(Reusable.applyListViewCell)
        tableView.separatorColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 34)
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.safeFull(parent: self)
    }
    
    @objc
    private func rightBtnBtnDidTapped() {
        let invithNewReactor = SquadInvithNewReactor(squadId: reactor!.squadId)
        let vc = SquadInvithNewViewController(reactor: invithNewReactor)
        let nav = BaseNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }

    override func bind(reactor: SquadMembersReactor) {
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, User>>(configureCell: {data,tableView, indexPath, model in
            
            let cell = tableView.dequeue(Reusable.applyListViewCell)!
            cell.avatarView.kf.setImage(with: model.avatar.asURL, for: .normal)
            cell.selectionStyle = .none
            cell.nicknameLab.text = model.nickname
            cell.contentLab.text = "Alex, Hannah, Mari and 2 others"
            cell.actionBtn.setTitle("Add", for: .normal)
            return cell
        }, canEditRowAtIndexPath: { _,_ in
            return true
        })
        
        reactor.state
            .map{ [SectionModel<String, User>(model: "", items: $0.repos)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .map{ Reactor.Action.refreshList }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
