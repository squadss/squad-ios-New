//
//  RegisterNationCodeViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/24.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

class ZonesResultsController: BaseViewController {
    
    weak var searchBar: UISearchBar!
    private var tableView = UITableView()
    private var disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, ZonesViewController.CellItemModelType>>!
    
    var dataListSubject = BehaviorRelay<[SectionModel<String, ZonesViewController.CellItemModelType>]>(value: [])
    
    var didSelectedItemObservable: Observable<String> {
        return tableView.rx.itemSelected.map{ [unowned self] in self.dataSource[$0].content }
    }
    
    override func initData() {
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, ZonesViewController.CellItemModelType>>(configureCell: { (data, tableView, indexPath, model) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCellKey") as! UserInfoCell
            cell.titleLab.text = model.title
            cell.contentLab.isHidden = false
            cell.contentLab.text = model.content
            cell.attachView.removeFromSuperview()
            return cell
        })
        
        searchBar.rx.text.orEmpty
            .filter{ $0.isEmpty == false }
            .map{  text -> [SectionModel<String, ZonesViewController.CellItemModelType>] in
                let list = self.dataListSubject.value
               
                var tempList = [SectionModel<String, ZonesViewController.CellItemModelType>]()
                
                for section in list {
                    
                    let items = section.items.filter({ (model) -> Bool in
                        return model.title.contains(text)
                    })
                    
                    tempList.append(SectionModel(model: "", items: items))
                }
                
               return tempList
                
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

    }
    
    override func setupView() {
        tableView.tableFooterView = UIView()
        tableView.sectionIndexColor = UIColor.black
        tableView.sectionIndexBackgroundColor = .clear
        tableView.rowHeight = 49
        tableView.register(UserInfoCell.self, forCellReuseIdentifier: "UserInfoCellKey")
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.safeFull(parent: self)
    }
}

class ZonesViewController: BaseViewController  {

    typealias CellItemModelType = (title: String, content: String)
    
    private var disposeBag = DisposeBag()
    private var tableView = UITableView()
    private let resultsController = ZonesResultsController()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, CellItemModelType>>!
    
    var didSelectedItemObservable: Observable<String> {
        let listObservable = tableView.rx.itemSelected.map{ [unowned self] in self.dataSource[$0].content }
        return Observable
            .of(listObservable, self.resultsController.didSelectedItemObservable)
            .merge()
            .filter{ $0.isEmpty == false }
            .do(onNext: { [unowned self] _ in
                
                let dismiss: () -> Void = { [unowned self] in
                    self.dismiss(animated: true)
                }
                
                if let parent = self.presentedViewController {
                    parent.dismiss(animated: true, completion: dismiss)
                }
                else {
                    dismiss()
                }
            })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSearchBar()
    }
    
    override func initData() {
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, CellItemModelType>>(configureCell: { (data, tableView, indexPath, model) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCellKey") as! UserInfoCell
            cell.titleLab.text = model.title
            cell.contentLab.isHidden = false
            cell.contentLab.text = model.content
            cell.attachView.removeFromSuperview()
            return cell
        }, titleForHeaderInSection: { data, num in
            return data[num].model
        }, sectionIndexTitles: { data in
            var sections = data.sectionModels.map{ $0.model }
            sections.insert(UITableView.indexSearch, at: 0)
            return sections
        }, sectionForSectionIndexTitle: {_, title, index in
            if title == UITableView.indexSearch { return NSNotFound }
            return UILocalizedIndexedCollation.current().section(forSectionIndexTitle: index) - 1
        })
        
        guard let path = Bundle.main.path(forResource: "AreaCode", ofType: "plist") else { return }
        let data = NSMutableArray(contentsOfFile: path)
        guard let list = data as? Array<Dictionary<String, Array<Dictionary<String, String>>>> else { return }
        
        let dataSourceObservable = Observable.just(list)
            .map{ list  -> [SectionModel<String, CellItemModelType>] in
                return list.map { (dict: Dictionary<String, Array<Dictionary<String, String>>>) -> SectionModel<String, CellItemModelType> in
                    let model = dict.keys.first!
                    let values = dict[model, default: []]
                    
                    return SectionModel(model: model, items: values.map({ (dict) -> CellItemModelType in
                        return (dict["Name", default: ""], "+" + dict["Number", default: ""])
                    }))
                }
            }
            .share()
            
       dataSourceObservable
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        dataSourceObservable
            .subscribe(onNext: { [unowned self] list in
                self.resultsController.dataListSubject.accept(list)
            })
            .disposed(by: disposeBag)
    }
   
    override func setupView() {
        
        tableView.tableFooterView = UIView()
        tableView.sectionIndexColor = UIColor.black
        tableView.sectionIndexBackgroundColor = .clear
        tableView.register(UserInfoCell.self, forCellReuseIdentifier: "UserInfoCellKey")
        tableView.rowHeight = 49
        view.addSubview(tableView)
        
        let leftBarButtonItem = UIBarButtonItem()
        leftBarButtonItem.title = "Cancel"
        leftBarButtonItem.tintColor = .black
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    override func setupConstraints() {
        tableView.snp.safeFull(parent: self)
    }
    
    private func setupSearchBar() {
        
        let searchVC = UISearchController(searchResultsController: resultsController)
        
        //占位
        searchVC.searchBar.placeholder = "Search"
        searchVC.searchBar.searchBarStyle = .minimal
        
        //拿到搜索文本框
        if #available(iOS 13, *) {
            let searchField = searchVC.searchBar.searchTextField
            searchField.font = UIFont.systemFont(ofSize: 15)
        } else {
            let searchField = searchVC.searchBar.value(forKey: "_searchField") as? UITextField
            searchField?.font = UIFont.systemFont(ofSize: 15)
            searchVC.searchBar.sizeToFit()
        }
        
        resultsController.searchBar = searchVC.searchBar
        
        self.definesPresentationContext = true
        
        //将searchbar添加到视图中
        if #available(iOS 11, *) {
            navigationItem.searchController = searchVC
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        else {
            let tempView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
            tempView.addSubview(searchVC.searchBar)
            tableView.tableHeaderView = tempView
        }
        
    }
    
    override func addTouchAction() {
        navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}
