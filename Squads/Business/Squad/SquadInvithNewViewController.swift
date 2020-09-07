//
//  SquadInvithNewViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import Contacts
import MessageUI

class SquadInvithNewViewController: ReactorViewController<SquadInvithNewReactor>, UITableViewDelegate, MFMessageComposeViewControllerDelegate, UIGestureRecognizerDelegate {

    // 控制是否隐藏导航左侧按钮
    var isHideBackButtonItem: Bool = false
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 从创建squad页面跳转过来时, 需要将导航栏返回按钮隐藏
        if isHideBackButtonItem {
            // 隐藏导航栏返回按钮
            navigationItem.hidesBackButton = true
            // 禁止右滑返回上一页面的手势
            if navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) == true {
                self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            }
        }
    }
    
    override func setupView() {
        headerView = SquadInvithNewHeaderView()
        headerView.contentView = collectionView
        headerView.insertBottom = 30
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
    
    override func addTouchAction() {
        headerView.inviteBtn.rx.tap
            .map{ Reactor.Action.createLink }
            .bind(to: reactor!.action)
            .disposed(by: disposeBag)
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
        
        let collectionDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, SquadInvithNewReactor.Member>>(configureCell: { [unowned self] data, collectionView, indexPath, model in
            let cell = collectionView.dequeue(Reusable.squadInvithNewMemberCell, for: indexPath)
            cell.isClosable = model.isColsable
            cell.avatarBtn.kf.setImage(with: model.user.avatar.asURL, for: .normal, placeholder: UIImage(named: "Member Placeholder"), options: nil, progressBlock: nil, completionHandler: nil)
            cell.nicknameLab.text = model.user.nickname
            
            cell.avatarBtn.rx.tap
                .subscribe(onNext: { [unowned self] in
                    let friendReactor = FriendProfileReactor(accountId: model.user.id)
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
            .compactMap{ $0.toast }
            .bind(to: rx.toastNormal)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.isLoading }
            .bind(to: rx.loading)
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
        
        reactor.state
            .compactMap{ $0.linkText }
            .subscribe(onNext: { [unowned self] text in
                if MFMessageComposeViewController.canSendText() {
                    let messageVC = MFMessageComposeViewController()
                    messageVC.messageComposeDelegate = self
                    messageVC.body = text
                    messageVC.modalPresentationStyle = .fullScreen
                    self.present(messageVC, animated: true)
                } else {
                    let alert = UIAlertController(title: "Warning", message: "This feature is not supported on current devices", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        tableDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SquadInvithNewReactor.Member>>(configureCell: { data, tableView, indexPath, model in
            let cell = tableView.dequeue(Reusable.squadInvithNewContactCell)!
            cell.avatarView.kf.setImage(with: model.user.avatar.asURL, for: .normal)
            cell.selectionStyle = .none
            cell.nicknameLab.text = model.user.nickname
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
        
        reactor.state
            .map { state in
                if state.isEmptyRepos {
                    return "Skip"
                } else if state.members == nil || state.members?.isEmpty == true {
                    return "Skip"
                }
                return "Confirm"
            }
            .bind(to: rightBarButtonItem.rx.title)
            .disposed(by: disposeBag)
        
        rightBarButtonItem.rx.tap
            .filter{ reactor.currentState.members?.isEmpty == false }
            .map{ Reactor.Action.makeInvitation }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.merge(
            reactor.state
                .filter { $0.inviteSuccess == true }
                .map{ _ in () }
                .delay(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance),
            rightBarButtonItem.rx.tap
                .filter {
                    let state = reactor.currentState
                    if state.isEmptyRepos {
                        return true
                    } else if state.members == nil || state.members?.isEmpty == true {
                        return true
                    }
                    return false
                }
                .map{ _ in () }
            )
            .subscribe(onNext: { [unowned self] _ in
                var rootViewController = UIApplication.shared.keyWindow?.rootViewController
                rootViewController = (rootViewController as? UINavigationController)?.viewControllers.first
                if rootViewController is LoginViewController || rootViewController is WelcomeViewController {
                    Application.shared.presentInitialScreent()
                } else {
                    self.dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
//        requestVisibleContacts()
//            .takeUntil(rx.viewDidLoad)
//            .subscribeOn(MainScheduler.instance)
//            .map { [unowned self] status in
//                var list = Array<String>()
//                if status { list = self.getContactsPhone() }
//                return Reactor.Action.visibleContacts(phoneList: list, isDenied: !status)
//            }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
        
        rx.viewDidLoad
            .map{ Reactor.Action.getAllFriends }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    // 请求访问通讯录 true: 已拥有权限
    private func requestVisibleContacts() -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in
            let status = CNContactStore.authorizationStatus(for: .contacts)
            switch status {
            case .notDetermined:
                let store = CNContactStore()
                store.requestAccess(for: .contacts) { (grantes, error) in
                    observer.onNext(error == nil)
                    observer.onCompleted()
                }
            case .restricted, .denied:
                observer.onNext(false)
                observer.onCompleted()
            case .authorized:
                observer.onNext(true)
                observer.onCompleted()
            @unknown default:
                observer.onNext(false)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    /// 获取通讯录中所有联系人的手机号
    private func getContactsPhone() -> Array<String> {
        var contactList = Array<String>()
        let contactStore = CNContactStore()
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey].map{ NSString(string: $0) }
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        try? contactStore.enumerateContacts(with: fetchRequest, usingBlock: { (contact, cPointer) in
            let phoneNumbers = contact.phoneNumbers
            for labelValue in phoneNumbers {
                let phoneNumber = labelValue.value.stringValue
                var phone = phoneNumber.replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                phone = String(phone.suffix(11))
                if phone.count == 11 && phone.hasPrefix("1") {
                    contactList.append(phone)
                    break
                }
            }
        })
        return contactList
    }
    
    @objc
    private func searchBtnDidTapped() {
        let searchVC = SquadInvithNewSearchViewController()
        searchVC.hero.isEnabled = true
        searchVC.hero.modalAnimationType = .selectBy(presenting: .fade, dismissing: .fade)
        searchVC.modalPresentationStyle = .fullScreen
        self.present(searchVC, animated: true)
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
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
