//
//  SquadInvithNewSearchViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/19.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxDataSources

class SquadInvithNewSearchViewController: BaseViewController, UITableViewDelegate {

    private var tableView = UITableView(frame: .zero, style: .grouped)
    private var tableDataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, SquadInvithNewReactor.Member>>!
    
    private var searchField = UITextField()
    
    private var footerView: UIView!
    
    private var cancelBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchField.resignFirstResponder()
    }
    
    override func setupView() {
        footerView = UIView()
        footerView.hero.id = "FooterViewKey"
        footerView.layer.maskCorners(26, rect: CGRect(x: 0, y: 0, width: view.bounds.width, height: 1000), corner: .top)
        footerView.backgroundColor = .white
        view.addSubviews(footerView)
        
        setupTableView()
        setupSearchField()
        setupCancelBtn()
    }
    
    private func setupTableView() {
        tableView.hero.id = "TableViewKey"
        tableView.rowHeight = 70
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.register(Reusable.applyListViewCell)
        tableView.separatorColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 34)
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0.001, height: 0.001))
        footerView.addSubview(tableView)
    }
    
    private func setupSearchField() {
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 38, height: 28))
        let imageView = UIImageView(image: UIImage(named: "Member Search"))
        imageView.frame = CGRect(x: 20, y: 7.5, width: 13, height: 13)
        leftView.addSubview(imageView)
        
        searchField.hero.id = "SearchFieldKey"
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
        footerView.addSubview(searchField)
    }
    
    private func setupCancelBtn() {
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.theme.titleColor(from: UIColor.secondary, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancelBtn.addTarget(self, action: #selector(cancelBtnDidTapped), for: .touchUpInside)
        footerView.addSubview(cancelBtn)
    }
    
    override func setupConstraints() {
        
        footerView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalTo(bottomLayoutGuide.snp.top)
                maker.top.equalTo(topLayoutGuide.snp.bottom)
            }
        }
        
        cancelBtn.snp.makeConstraints { (maker) in
            maker.trailing.equalTo(-12)
            maker.top.equalTo(14)
            maker.size.equalTo(CGSize(width: 60, height: 38))
        }
        
        searchField.snp.makeConstraints { (maker) in
            maker.leading.equalTo(32)
            maker.top.equalTo(19)
            maker.trailing.equalTo(cancelBtn.snp.leading).offset(-3)
            maker.height.equalTo(28)
        }
        
        tableView.snp.makeConstraints { (maker) in
            maker.leading.trailing.bottom.equalToSuperview()
            maker.top.equalTo(searchField.snp.bottom).offset(20)
        }
    }
    
    override func addTouchAction() {
        tableDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SquadInvithNewReactor.Member>>(configureCell: { data, tableView, indexPath, model in
            let cell = tableView.dequeue(Reusable.applyListViewCell)!
            cell.avatarView.kf.setImage(with: URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg"), for: .normal)
            cell.selectionStyle = .none
            cell.nicknameLab.text = "Squad Name"
            cell.contentLab.text = "Alex, Hannah, Mari and 2 others"
            cell.actionBtn.setTitle("Add", for: .normal)
            return cell
        })
        
//        reactor.state
//            .compactMap{ $0.repos }
//            .bind(to: tableView.rx.items(dataSource: tableDataSource))
//            .disposed(by: disposeBag)
    }
    
    @objc
    private func cancelBtnDidTapped() {
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tempView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40))
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lab.theme.textColor = UIColor.textGray
        lab.frame = CGRect(x: 32, y: 0, width: 100, height: 20)
        lab.text = "hahah"//tableDataSource?[section].model
        tempView.addSubview(lab)
        return tempView
    }
}
