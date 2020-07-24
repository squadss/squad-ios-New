//
//  FlicksSearchViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/19.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class FlicksSearchViewController: BaseViewController, UITableViewDelegate {

    private var disposeBag = DisposeBag()
    private var tableView = UITableView(frame: .zero, style: .grouped)
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, FlicksReactor.Model<FlickModel>>>!
    
    private var searchField = UITextField()
    private var cancelBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    override func setupView() {
        
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0.01, height: 0.01))
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(Reusable.flicksListViewCell)
        view.addSubview(tableView)
        
        setupCancelBtn()
        setupSearchField()
    }
    
    private func setupCancelBtn() {
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.theme.titleColor(from: UIColor.secondary, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancelBtn.addTarget(self, action: #selector(cancelBtnDidTapped), for: .touchUpInside)
        view.addSubview(cancelBtn)
    }
    
    private func setupSearchField() {
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 38, height: 28))
        let imageView = UIImageView(image: UIImage(named: "Member Search"))
        imageView.frame = CGRect(x: 20, y: 7.5, width: 13, height: 13)
        leftView.addSubview(imageView)
        
        searchField.hero.id = "SearchFlicksKey"
        searchField.layer.cornerRadius = 14
        searchField.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        searchField.leftView = leftView
        searchField.leftViewMode = .always
        searchField.font = UIFont.systemFont(ofSize: 12)
        searchField.theme.textColor = UIColor.textGray
        searchField.returnKeyType = .search
        if #available(iOS 13.0, *) {
            searchField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [
                .foregroundColor: UIColor(red: 0.571, green: 0.571, blue: 0.571, alpha: 1),
                .font: UIFont.systemFont(ofSize: 12),
            ])
        } else {
            searchField.placeholder = "Search"
            searchField.setValue(UIColor(red: 0.571, green: 0.571, blue: 0.571, alpha: 1), forKeyPath: "_placeholderLabel.textColor")
            searchField.setValue(UIFont.systemFont(ofSize: 12), forKeyPath: "_placeholderLabel.font")
        }
        view.addSubview(searchField)
    }
    
    override func setupConstraints() {
        
        cancelBtn.snp.makeConstraints { (maker) in
            maker.trailing.equalTo(-12)
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(14)
            } else {
                maker.top.equalTo(topLayoutGuide.snp.bottom).offset(14)
            }
            maker.size.equalTo(CGSize(width: 60, height: 38))
        }
        
        searchField.snp.makeConstraints { (maker) in
            maker.leading.equalTo(32)
            maker.top.equalTo(cancelBtn)
            maker.trailing.equalTo(cancelBtn.snp.leading).offset(-3)
            maker.height.equalTo(28)
        }
        
        tableView.snp.safeFull(parent: self)
    }
    
    func bind(reactor: FlicksReactor) {
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, FlicksReactor.Model<FlickModel>>>(configureCell: { data, tableView, indexPath, model in
            let cell = tableView.dequeue(Reusable.flicksListViewCell)!
            cell.contentWidth = model.contentWidth
            cell.pirtureList = model.data.pirtureList
            cell.contentLab.text = model.data.content
            cell.dateBtn.setTitle(model.data.dateString, for: .normal)
            cell.likeBtn.setTitle(model.data.likeNum, for: .normal)
            cell.commonBtn.setTitle(model.data.commonNum, for: .normal)
            cell.selectionStyle = .none
            return cell
        })
        
        reactor.state
            .map{ $0.repos.map{ SectionModel(model: "", items: [$0]) } }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    @objc
    private func cancelBtnDidTapped() {
        self.dismiss(animated: true)
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
