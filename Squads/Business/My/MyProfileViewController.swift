//
//  MyProfileViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxDataSources
import ETNavBarTransparent

class MyProfileViewController: ReactorViewController<MyProfileReactor> {

    var tableView = UITableView()
    var headerView = MyProfileHeaderView()
    var footerView = MyProfileFooterView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.red
        view.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        
        
//        let btn = UIButton()
//        btn.frame = CGRect(x: 10, y: 100, width: 100, height: 44)
//        btn.backgroundColor = .white
//        btn.addTarget(self, action: #selector(didTapped), for: .touchUpInside)
//        view.addSubview(btn)
    }
    
    override func initData() {
        
        headerView.applyLab.isHidden = false
        headerView.applyLab.text = "2 Requests"
        headerView.contentLab.text = "@username"
        headerView.nicknameLab.text = "Name"
        headerView.avatarView.kf.setImage(with: URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg"))
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
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>(configureCell: { (data, tableView, indexPath, model) -> UITableViewCell in
            let cell = tableView.dequeue(Reusable.mySquadsViewCell)!
            cell.pritureView.kf.setImage(with: URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg"))
            cell.titleLab.text = "Camp life"
            cell.unreadNum = "12"
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
    }
    
    @objc
    private func didTapped() {
        let preReactor = SquadPreReactor()
        let preViewController = SquadPreViewController(reactor: preReactor)
        let nav = BaseNavigationController(rootViewController: preViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    override func addTouchAction() {
        footerView.itemSelected
            .subscribe(onNext: { [unowned self] flag in
                switch flag {
                case "profile":
                    let preReactor = SquadPreReactor()
                    let preViewController = SquadPreViewController(reactor: preReactor)
                    self.navigationController?.pushViewController(preViewController, animated: true)
                case "notifications":
                    break
                case "inviteFrients":
                    break
                case "help":
                    break
                case "logOut":
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}
