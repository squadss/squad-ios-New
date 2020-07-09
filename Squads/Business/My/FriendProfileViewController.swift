//
//  FriendProfileViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxDataSources

class FriendProfileViewController: ReactorViewController<FriendProfileReactor> {

    var infoView = EditableAvatarView()
    var menuView = SquadPreMenuView()
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoView.canEdit = true
        infoView.imageURL = URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")
        
        menuView.daysView.numLab.text = "624"
        menuView.daysView.titleLab.text = "SQUADS"
        
        menuView.textsView.numLab.text = "23K"
        menuView.textsView.titleLab.text = "TEXTS"
        
        menuView.flicksView.numLab.text = "32"
        menuView.flicksView.titleLab.text = "FLICKS"
    }

    override func setupView() {
        
        let leftBarItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(leftBarItemDidTapped))
        leftBarItem.theme.tintColor = UIColor.text
        let rightBarItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(rightBarItemDidTapped))
        rightBarItem.theme.tintColor = UIColor.text
        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.rightBarButtonItem = rightBarItem
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 220))
        headerView.theme.backgroundColor = UIColor.background
        
        infoView.frame = CGRect(x: 50, y: 32, width: headerView.frame.width - 100, height: 90)
        menuView.frame = CGRect(x: 50, y: infoView.frame.maxY + 35, width: headerView.frame.width - 100, height: 40)
        headerView.addSubviews(infoView, menuView)
        
        tableView.rowHeight = 85
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 1)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 34, bottom: 0, right: 34)
        tableView.register(Reusable.friendProfileViewCell)
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.safeFull(parent: self)
    }
    
    override func bind(reactor: FriendProfileReactor) {
//        infoView.canEditTap.map{  }
//        infoView.imageTap
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, FriendProfileReactor.Model>>(configureCell: { (data, tableView, indexPath, model) -> UITableViewCell in
            let cell = tableView.dequeue(Reusable.friendProfileViewCell)!
            cell.titleLab.text = model.title
            cell.contentLab.text = model.content
            cell.longObservable
                .subscribe(onNext: { [unowned self] in
                    UIPasteboard.general.string = model.content
                    self.showToast(message: "Copy Success!")
                })
                .disposed(by: cell.disposeBag)
            cell.selectionStyle = .none
            return cell
        })
        
        reactor.state
            .map{ [SectionModel(model: "", items: $0.repos)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
    
    @objc
    private func leftBarItemDidTapped() {
        
    }
    
    @objc
    private func rightBarItemDidTapped() {
        
    }
}
