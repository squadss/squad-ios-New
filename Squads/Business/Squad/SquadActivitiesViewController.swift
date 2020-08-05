//
//  SquadActivitiesViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//  活动列表中

import UIKit
import RxDataSources

final class SquadActivitiesViewController: ReactorViewController<SquadActivitiesReactor>, UITableViewDelegate {

    private var searchView = UIInputView()
    private var tableView = UITableView(frame: .zero, style: .grouped)
    
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, String>>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
    }
    
    override func setupView() {
        
        view.addSubview(searchView)
        
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(Reusable.activityCalendarCell)
        tableView.theme.backgroundColor = UIColor.background
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
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
            maker.top.equalTo(searchView)
        }
    }
    
    override func bind(reactor: SquadActivitiesReactor) {
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>(configureCell: { (data, tableView, indexPath, model) -> UITableViewCell in
            
            let cell = tableView.dequeue(Reusable.activityCalendarCell)!
            cell.contentLab.text = "RSF"
            cell.titleLab.text = "Lunch"
            cell.dateLab.text = "TODAY AT 1:30 PM"
            cell.pritureView.kf.setImage(with: URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg"))
            cell.membersView.members = [URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!]
            cell.ownerLab.text = "Suggested by Daniel"
            cell.containterView.borderColor = .red
            cell.calendayView.day = "8"
            cell.calendayView.month = "Apr"
            cell.selectionStyle = .none
            cell.setData("")
            return cell
        })
        
        reactor.state
            .map{ [SectionModel(model: "", items: $0.repos)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    @objc
    private func rightBarItemDidTapped() {
        let reactor = CreateEventReactor()
        let vc = CreateEventViewController(reactor: reactor)
        vc.title = "Create Event"
        let nav = BaseNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = dataSource[indexPath]
        return 110
    }
}
