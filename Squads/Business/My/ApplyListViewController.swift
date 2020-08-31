//
//  ApplyListViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/18.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxDataSources
//import HGPlaceholders

class ApplyListViewController: ReactorViewController<ApplyListReactor>, UITableViewDelegate {
    
    var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.theme.backgroundColor = UIColor.background
    }
    
    override func setupView() {
        
//        var defaultProvider: PlaceholdersProvider {
//            let style = PlaceholderStyle()
//
//            let loading = Placeholder(data: .loading, style: style, key: .loadingKey)
//            let error = Placeholder(data: .error, style: style, key: .errorKey)
//
//            var noResultsStyle = PlaceholderData()
//            noResultsStyle.title = "You have no requests at this time"
//
//            let noResults = Placeholder(data: noResultsStyle, style: style, key: .noResultsKey)
//            let noConnection = Placeholder(data: .noConnection, style: style, key: .noConnectionKey)
//
//            let placeholdersProvider = PlaceholdersProvider(loading: loading, error: error, noResults: noResults, noConnection: noConnection)
//            return placeholdersProvider
//        }
        
        tableView.rowHeight = 70
        tableView.register(Reusable.applyListViewCell)
        tableView.separatorColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 34)
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
//        tableView.delegate = self
//        tableView.placeholdersProvider = defaultProvider
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.safeFull(parent: self)
    }
    

    override func bind(reactor: ApplyListReactor) {
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Invitation>>(configureCell: {data,tableView, indexPath, model in
            
            let cell = tableView.dequeue(Reusable.applyListViewCell)!
            cell.avatarView.kf.setImage(with: model.inviteSquadLogoPath?.asURL, for: .normal)
            cell.selectionStyle = .none
            cell.nicknameLab.text = model.inviterNickname
            cell.contentLab.text = "Invited by " + model.inviterNickname
            
            switch model.inviteStatus {
            case .accepted:     //已接受
                cell.actionBtn.setTitle("Accept", for: .normal)
                cell.actionBtn.isEnabled = false
            case .doing:    //邀请中
                cell.actionBtn.setTitle("Add", for: .normal)
                cell.actionBtn.isEnabled = true
            case .failure:  //已拒绝
                cell.actionBtn.isEnabled = false
                cell.actionBtn.setTitle("Refused", for: .disabled)
            }
            
            cell.actionBtn.rx.tap
                .map{ Reactor.Action.joinSquad(model.inviteSquadId) }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            return cell
        }, canEditRowAtIndexPath: { _,_ in
            return true
        })
        
        reactor.state
            .map{ [SectionModel<String, Invitation>(model: "", items: $0.repos)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.toast }
            .bind(to: rx.toastNormal)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.isLoading }
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
        
        rx.viewDidLoad
            .map{ Reactor.Action.requestAllRecord }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
//        tableView.rx.actionButtonTapped
//            .subscribe(onNext: {
//                print($0)
//            })
//            .disposed(by: rx.disposeBag)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
}
