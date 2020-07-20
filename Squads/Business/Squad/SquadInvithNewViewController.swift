//
//  SquadInvithNewViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxDataSources

class SquadInvithNewViewController: ReactorViewController<SquadInvithNewReactor>, UITableViewDelegate {

    private var layout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private var tableView = UITableView(frame: .zero, style: .grouped)
    private var tableDataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, SquadInvithNewReactor.Member>>!
    
    private var searchBtn = UIButton()
    private let rightBarButtonItem = UIBarButtonItem()
    private var footerView: UIView!
    private var headerView: SquadInvithNewHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
    }
    
    override func setupView() {
        
        headerView = SquadInvithNewHeaderView()
        headerView.contentView = collectionView
        headerView.insertBottom = 30
        headerView.inviteBtn.addTarget(self, action: #selector(inviteBtnDidTapped), for: .touchUpInside)
        headerView.backgroundColor = UIColor(hexString: "#E5E5E5")
        
        footerView = UIView()
        footerView.hero.id = "FooterViewKey"
        footerView.layer.maskCorners(26, rect: CGRect(x: 0, y: 0, width: view.bounds.width, height: 1000), corner: .top)
        footerView.backgroundColor = .white
        view.addSubviews(headerView, footerView)
        
        setupCollectionView()
        setupTableView()
        setupSearchBtn()
        setupNavigationBarRightItem()
    }
    
    private func setupCollectionView() {
        layout.sectionInset = UIEdgeInsets(top: 16, left: 26, bottom: 0, right: 28)
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 60, height: 82)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView.isHidden = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(Reusable.squadInvithNewMemberCell)
        collectionView.backgroundColor = UIColor(hexString: "#E5E5E5")
    }
    
    private func setupNavigationBarRightItem() {
        rightBarButtonItem.title = "Done"
        rightBarButtonItem.style = .plain
        rightBarButtonItem.theme.tintColor = UIColor.secondary
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func setupTableView() {
        tableView.rowHeight = 70
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.hero.id = "TableViewKey"
        tableView.register(Reusable.squadInvithNewContactCell)
        tableView.separatorColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 34)
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0.001, height: 0.001))
        footerView.addSubview(tableView)
    }
    
    private func setupSearchBtn() {
        searchBtn.setImage(UIImage(named: "Member Search"), for: .normal)
        searchBtn.setTitle("Search", for: .normal)
        searchBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        searchBtn.theme.titleColor(from: UIColor.textGray, for: .normal)
        searchBtn.layer.cornerRadius = 14
        searchBtn.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        searchBtn.contentHorizontalAlignment = .left
        searchBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 6)
        searchBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 26, bottom: 0, right: 0)
        searchBtn.hero.id = "SearchFieldKey"
        searchBtn.addTarget(self, action: #selector(searchBtnDidTapped), for: .touchUpInside)
        footerView.addSubview(searchBtn)
    }
    
    override func setupConstraints() {
        
        headerView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            maker.height.equalTo(148)
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                maker.top.equalTo(topLayoutGuide.snp.bottom)
            }
        }
        
        footerView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
            maker.top.equalTo(headerView.snp.bottom).offset(-headerView.insertBottom)
        }
        
        searchBtn.snp.makeConstraints { (maker) in
            maker.leading.equalTo(32)
            maker.top.equalTo(19)
            maker.trailing.equalTo(-34)
            maker.height.equalTo(28)
        }
        
        tableView.snp.makeConstraints { (maker) in
            maker.leading.trailing.bottom.equalToSuperview()
            maker.top.equalTo(searchBtn.snp.bottom).offset(20)
        }
    }
    
    override func bind(reactor: SquadInvithNewReactor) {
        
        let collectionDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, SquadInvithNewReactor.Member>>(configureCell: { data, collectionView, indexPath, model in
            let cell = collectionView.dequeue(Reusable.squadInvithNewMemberCell, for: indexPath)
            cell.isClosable = model.isColsable
            cell.avatarBtn.kf.setImage(with: nil, for: .normal, placeholder: UIImage(named: "Member Placeholder"), options: nil, progressBlock: nil, completionHandler: nil)
            cell.nicknameLab.text = "哈哈哈"
            
            cell.avatarBtn.rx.tap
                .subscribe(onNext: { [unowned self] in
                    let friendReactor = FriendProfileReactor()
                    let vc = FriendProfileViewController(reactor: friendReactor)
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                .disposed(by: cell.disposeBag)
            
            cell.closeBtnDidTapped
                .map{ Reactor.Action.deleteSelectedMember(model) }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            
            return cell
        })
        
        reactor.state
            .compactMap{ $0.members }
            .map{ [SectionModel(model: "", items: $0)] }
            .bind(to: collectionView.rx.items(dataSource: collectionDataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map{ $0.members != nil }
            .debug()
            .filter{ $0 }
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] _ in
                guard self.headerView.contentView.isHidden else { return }
                self.headerView.snp.updateConstraints { (maker) in
                    maker.height.equalTo(244)
                }
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.layoutIfNeeded()
                }) { _ in
                    self.headerView.contentView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        tableDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SquadInvithNewReactor.Member>>(configureCell: { data, tableView, indexPath, model in
            let cell = tableView.dequeue(Reusable.squadInvithNewContactCell)!
            cell.avatarView.kf.setImage(with: URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg"), for: .normal)
            cell.selectionStyle = .none
            cell.nicknameLab.text = "Squad Name"
            cell.contentLab.text = "Alex, Hannah, Mari and 2 others"
            cell.actionBtn.setTitle("Add", for: .normal)
            cell.actionBtn.setTitle("Remove", for: .selected)
            cell.actionBtn.isSelected = model.isAdded
            cell.actionBtn.rx.tap
                .map{
                    if model.isAdded {
                        return Reactor.Action.deleteSelectedMember(model)
                    } else {
                        return Reactor.Action.addSelectedMember(model)
                    }
                }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            return cell
        })
        
        reactor.state
            .compactMap{ $0.repos.map{ SectionModel(model: "", items: $0) } }
            .bind(to: tableView.rx.items(dataSource: tableDataSource))
            .disposed(by: disposeBag)
        
        reactor.state.map{
            if let members = $0.members, members.count > 1 {
                return true
            } else {
                return false
            }
        }
        .bind(to: rightBarButtonItem.rx.isEnabled)
        .disposed(by: disposeBag)
        
        rightBarButtonItem.rx.tap
            .map{ Reactor.Action.request }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.requestResult }
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .success:
                    self.dismiss(animated: true)
                case .failure(let error):
                    self.showToast(message: error.message)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    @objc
    private func searchBtnDidTapped() {
        let searchVC = SquadInvithNewSearchViewController()
        searchVC.hero.isEnabled = true
        searchVC.hero.modalAnimationType = .selectBy(presenting: .fade, dismissing: .fade)
        searchVC.modalPresentationStyle = .fullScreen
        self.present(searchVC, animated: true)
    }
    
    @objc
    private func inviteBtnDidTapped() {
        
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
        switch section {
        case 0:
            lab.text = "FRIENDS"
        case 1:
            lab.text = "CONTACTS"
        default:
            return nil
        }
        tempView.addSubview(lab)
        return tempView
    }
    
}
