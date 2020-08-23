//
//  FlicksViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxDataSources
import MJRefresh
import RxSwift
import JXPhotoBrowser

class FlicksViewController: ReactorViewController<FlicksReactor>, UITableViewDelegate {

    var tableView = UITableView(frame: .zero, style: .grouped)
    var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, FlicksReactor.Model<FlickModel>>>!
    
    let header = MJRefreshNormalHeader()
    let footer = MJRefreshBackStateFooter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

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
        
        footer.stateLabel?.isHidden = true
        footer.isAutomaticallyChangeAlpha = true
        footer.mj_h = 30
        tableView.mj_footer = footer
        
        tableView.mj_header = header
        
        let layoutInsets = UIApplication.shared.keyWindow?.layoutInsets ?? .zero
        
        tableView.delegate = self
        tableView.tableHeaderView = searchView
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset.bottom = layoutInsets.bottom
        tableView.register(Reusable.flicksListViewCell)
        view.addSubview(tableView)
    }
    
    override func addTouchAction() {
        header.rx.loading
            .startWith(())
            .map{ Reactor.Action.refreshData(keyword: "") }
            .bind(to: reactor!.action)
            .disposed(by: disposeBag)
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
                    print(pageIndex)
                })
                .disposed(by: cell.disposeBag)
            
            return cell
        })
        
        reactor.state
            .map{ $0.repos.map{ SectionModel(model: "", items: [$0]) } }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    @objc
    private func searchBtnDidTapped() {
        let searchVC = FlicksSearchViewController()
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
