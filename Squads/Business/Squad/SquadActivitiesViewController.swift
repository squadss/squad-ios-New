//
//  SquadActivitiesViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//  活动列表中

import UIKit
import RxDataSources

final class SquadActivitiesViewController: ReactorViewController<SquadActivitiesReactor> {

    private var searchView = UIInputView()
    private var tableView = UITableView(frame: .zero, style: .grouped)
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, SquadActivity>>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
    }
    
    override func setupView() {
        
        view.addSubview(searchView)
        
        let layoutInsets = UIApplication.shared.keyWindow?.layoutInsets ?? .zero
        
        tableView.rowHeight = 112
        tableView.separatorStyle = .none
        tableView.register(Reusable.activityCalendarCell)
        tableView.theme.backgroundColor = UIColor.background
        tableView.contentInset.bottom = layoutInsets.bottom
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
        
        view.addSubview(tableView)
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigationBarCalendar"), style: .plain, target: self, action: #selector(rightBarItemDidTapped))
        rightBarButtonItem.theme.tintColor = UIColor.text
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    override func setupConstraints() {
        searchView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                maker.top.equalTo(topLayoutGuide.snp.bottom)
            }
            maker.height.equalTo(44)
        }
        
        tableView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.top.equalTo(searchView)
        }
    }
    
    override func bind(reactor: SquadActivitiesReactor) {
        
        let user: User? = User.currentUser()
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SquadActivity>>(configureCell: { (data, tableView, indexPath, model) -> UITableViewCell in
            let startTime = model.formatterStartTime()
            let cell = tableView.dequeue(Reusable.activityCalendarCell)!
            cell.titleLab.text = model.title
            cell.pritureView.image = model.activityType.image
            
            if model.activityStatus == .prepare {
                cell.menuView.isHidden = true
                cell.statusView.isHidden = false
                cell.containterView.borderColor = nil
                if let members = model.responsedMembers, !members.isEmpty {
                    if let owner = members.first(where: { $0.accountId == model.accountId }) {
                        cell.ownerLab.text = "Created by " + owner.nickname
                    }
                    if let mine = members.first(where: { $0.accountId == user?.id }) {
                        let title = mine.isResponded ? "Time TBD" : "ADD AVAILABILITY"
                        cell.statusView.setTitle(title, for: .normal)
                    } else {
                        cell.statusView.setTitle("ADD AVAILABILITY", for: .normal)
                    }
                    cell.membersView.setMembers(members: members.map{ $0.avatar.asURL })
                }
                cell.dateLab.text = "TBD"
            } else {
                
                cell.menuView.isHidden = false
                cell.statusView.isHidden = true
                cell.containterView.borderColor = .red
                
                var isGoing: Bool?
                
                if let members = model.goingMembers {
                    if members.contains(where: { $0.id == user?.id }) {
                        isGoing = true
                    }
                    cell.membersView.setMembers(members: members.map{ $0.avatar.asURL })
                }
                
                if let members = model.rejectMembers, isGoing == nil {
                    if members.contains(where: { $0.id == user?.id }) {
                        isGoing = false
                    }
                }
                
                switch isGoing {
                case .some(true):
                    (cell.menuView.arrangedSubviews.first as? UIButton)?.isSelected = true
                    (cell.menuView.arrangedSubviews.last as? UIButton)?.isSelected = false
                case .some(false):
                    (cell.menuView.arrangedSubviews.first as? UIButton)?.isSelected = false
                    (cell.menuView.arrangedSubviews.last as? UIButton)?.isSelected = true
                case .none:
                    (cell.menuView.arrangedSubviews.first as? UIButton)?.isSelected = false
                    (cell.menuView.arrangedSubviews.last as? UIButton)?.isSelected = false
                }
                cell.dateLab.text = startTime?.date ?? "TBD"
            }
            
            if case .virtual = model.activityType {
                cell.contentLab.text = "Virtual"
            } else if let address = model.position?.address {
                cell.contentLab.text = address
            }
            
            cell.calendayView.day = startTime?.day ?? ""
            cell.calendayView.month = startTime?.month ?? ""
            cell.selectionStyle = .none
            
            cell.tapObservable
                .map{ Reactor.Action.handlerGoing(isAccept: $0 == 0, activityId: model.id) }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            
            return cell
        })
        
        reactor.state
            .compactMap { $0.isLoading }
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.toast }
            .bind(to: rx.toastNormal)
            .disposed(by: disposeBag)
        
        reactor.state
            .map{ [SectionModel(model: "", items: $0.repos)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                let model = self.dataSource[indexPath]
                let activityReactor = ActivityDetailReactor(activityId: model.id, squadId: model.squadId, initialActivityStatus: model.activityStatus)
                let activityDetailVC = ActivityDetailViewController(reactor: activityReactor)
                let nav = BaseNavigationController(rootViewController: activityDetailVC)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            })
            .disposed(by: disposeBag)
        
//        tableView.rx.setDelegate(self)
//            .disposed(by: disposeBag)
        
        rx.viewDidLoad
            .map{ Reactor.Action.requestList }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell
            .map{ [unowned self] (_, indexPath) in self.dataSource[indexPath] }
            .distinctUntilChanged({ $0.isEquadTo($1) })
            .map{ Reactor.Action.didDisplayCell($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    @objc
    private func rightBarItemDidTapped() {
        let squadId = reactor!.squadId
        let reactor = CreateEventReactor(squadId: squadId)
        let vc = CreateEventViewController(reactor: reactor)
        vc.title = "Create Event"
        let nav = BaseNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
}
