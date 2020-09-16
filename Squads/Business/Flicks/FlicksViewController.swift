//
//  FlicksViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxDataSources
import SwiftPullToRefresh
import RxSwift
import JXPhotoBrowser

class FlicksViewController: ReactorViewController<FlicksReactor>, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, FlicksReactor.Model<FlickModel>>>!

    override func setupView() {
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "New Flick"), style: .plain, target: self, action: #selector(rightBarItemDidTapped))
        rightBarButtonItem.theme.tintColor = UIColor.text
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let searchBtn = UIButton()
        searchBtn.setImage(UIImage(named: "Member Search"), for: .normal)
        searchBtn.setTitle("Search", for: .normal)
        searchBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        searchBtn.theme.titleColor(from: UIColor.textGray, for: .normal)
        searchBtn.layer.cornerRadius = 8
        searchBtn.backgroundColor = .white
        searchBtn.contentHorizontalAlignment = .left
        searchBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        searchBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -6)
        searchBtn.addTarget(self, action: #selector(searchBtnDidTapped), for: .touchUpInside)
        searchBtn.frame = CGRect(x: 18, y: 7, width: view.bounds.width - 36, height: 25)
        
        let searchView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40))
        searchView.hero.id = "SearchFlicksKey"
        searchView.backgroundColor = UIColor(red: 0.917, green: 0.917, blue: 0.917, alpha: 1)
        searchView.addSubview(searchBtn)
        
//        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 60))
//        let titleLab = UILabel()
//        titleLab.font = UIFont.systemFont(ofSize: 12)
//        titleLab.text = "No more Flicks!"
//        titleLab.textAlignment = .center
//        titleLab.theme.textColor = UIColor.textGray
//        titleLab.frame = CGRect(x: 0, y: 10, width: view.bounds.width, height: 20)
//        footerView.addSubview(titleLab)
        
        tableView.tableHeaderView = searchView
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0.001, height: 10))
        tableView.separatorStyle = .none
        tableView.register(Reusable.flicksListViewCell)
        view.addSubview(tableView)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints { (maker) in
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                maker.top.equalTo(topLayoutGuide.snp.bottom)
            }
            maker.leading.trailing.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }
    
    override func bind(reactor: FlicksReactor) {
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, FlicksReactor.Model<FlickModel>>>(configureCell: { data, tableView, indexPath, model in
            let cell = tableView.dequeue(Reusable.flicksListViewCell)!
            let list = model.data.pirtureList
            cell.contentWidth = model.contentWidth
            cell.pirtureList = list
            cell.contentLab.text = model.data.content
            cell.dateBtn.setTitle(model.data.dateString, for: .normal)
            cell.likeBtn.setTitle(model.data.likeNum, for: .normal)
            cell.commonBtn.setTitle(model.data.commonNum, for: .normal)
            cell.selectionStyle = .none
            
            cell.pirtureDidTapped
                .subscribe(onNext: { pageIndex in
                    let browser = JXPhotoBrowser()
                    browser.numberOfItems = { list.count }
                    browser.reloadCellAtIndex = { context in
                        let cell = context.cell as? JXPhotoBrowserImageCell
                        cell?.imageView.kf.setImage(with: list[context.index], placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
                    }
                    browser.cellClassAtIndex = { _ in JXPhotoBrowserImageCell.self }
                    browser.pageIndex = pageIndex
                    browser.show()
                })
                .disposed(by: cell.disposeBag)
            
            return cell
        })
        
        reactor.state
            .map{ $0.repos.map{ SectionModel(model: "", items: [$0]) } }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
//        reactor.state
//            .compactMap{ $0.isLoading }
//            .bind(to: tableView.rx.loading)
//            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.toast }
            .bind(to: rx.toastNormal)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isExistMoreData }
            .subscribe(onNext: { [unowned self] state in
                if state {
                    self.tableView.spr_endRefreshing()
                } else {
                    self.tableView.spr_endRefreshingWithNoMoreData()
                }
            })
            .disposed(by: disposeBag)
        
        rx.viewDidLoad
            .map{ _ in Reactor.Action.loadData(keyword: "", isRefresh: true) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.autoFooter
            .map{ _ in Reactor.Action.loadData(keyword: "", isRefresh: false) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    @objc
    private func searchBtnDidTapped() {
        guard let squadId = reactor?.squadId else { return }
        let searchVC = FlicksSearchViewController(squadId: squadId)
        searchVC.hero.isEnabled = true
        searchVC.hero.modalAnimationType = .selectBy(presenting: .fade, dismissing: .fade)
        searchVC.modalPresentationStyle = .fullScreen
        self.present(searchVC, animated: true)
    }
    
    @objc
    private func rightBarItemDidTapped() {
        let flickReactor = CreateFlickReactor(squadId: reactor!.squadId)
        let vc = CreateFlickViewController(reactor: flickReactor)
        let nav = BaseNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
        flickReactor.state
            .filter{ $0.postSuccess == true }
            .map{ _ in Reactor.Action.loadData(keyword: "", isRefresh: true) }
            .bind(to: reactor!.action)
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath].totalHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 19.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
