//
//  SquadNotificationsViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxDataSources

class SquadNotificationsViewController: ReactorViewController<SquadNotificationsReactor> {

    var tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.theme.backgroundColor = UIColor.background
    }
    

    override func setupView() {
        tableView.rowHeight = 50
        tableView.register(Reusable.squadNotificationsViewCell)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0.001, height: 0.001))
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 34)
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.safeFull(parent: self)
    }
    
    override func bind(reactor: SquadNotificationsReactor) {
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, (String, Bool)>>(configureCell: { data, tableView, indexPath, model in
            
            let cell = tableView.dequeue(Reusable.squadNotificationsViewCell)!
            cell.titleLab.text = model.0
            cell.switchBtn.isOn = model.1
            cell.switchBtn.rx.value
                .map{ Reactor.Action.updateSwitch(indexPath: indexPath, isOn: $0) }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            return cell
        })
        
        reactor.state
            .map{ $0.repos.map{ SectionModel(model: "", items: $0) } }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

}
