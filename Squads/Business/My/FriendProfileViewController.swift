//
//  FriendProfileViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class FriendProfileViewController: ReactorViewController<FriendProfileReactor> {

    private let picker = AvatarPicker()
    var infoView = EditableAvatarView()
    var menuView = SquadPreMenuView()
    var tableView = UITableView()
    
    private let editButton = UIButton()
    private let toggleEnableRelay = PublishRelay<Void>()
    private let updateUserInfoRelay = PublishRelay<FriendProfileReactor.UserParams>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuView.daysView.numLab.text = "0"
        menuView.daysView.titleLab.text = "SQUADS"
        
        menuView.textsView.numLab.text = "0"
        menuView.textsView.titleLab.text = "TEXTS"
        
        menuView.flicksView.numLab.text = "0"
        menuView.flicksView.titleLab.text = "FLICKS"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeListener()
    }
    
    override func setupView() {
        
        let leftBarItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(leftBarItemDidTapped))
        leftBarItem.theme.tintColor = UIColor.text
        navigationItem.leftBarButtonItem = leftBarItem
        
        editButton.frame = CGRect(x: 0, y: 0, width: 45, height: 44)
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitle("Save", for: .selected)
        editButton.contentHorizontalAlignment = .right
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        editButton.theme.titleColor(from: UIColor.text, for: .normal)
        editButton.addTarget(self, action: #selector(rightBarItemDidTapped(sender:)), for: .touchUpInside)
        let rightBarItem = UIBarButtonItem(customView: editButton)
        navigationItem.rightBarButtonItem = rightBarItem
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 220))
        headerView.theme.backgroundColor = UIColor.background
        
        infoView.frame = CGRect(x: 50, y: 32, width: headerView.frame.width - 100, height: 90)
        menuView.frame = CGRect(x: 50, y: infoView.frame.maxY + 35, width: headerView.frame.width - 100, height: 40)
        headerView.addSubviews(infoView, menuView)
        
        tableView.rowHeight = 85
        tableView.keyboardDismissMode = .onDrag
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 1)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 34, bottom: 0, right: 34)
        tableView.register(Reusable.friendProfileViewCell)
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.safeFull(parent: self)
    }
    
    override func bind(reactor: FriendProfileReactor) {
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, FriendProfileReactor.Model>>(configureCell: { (data, tableView, indexPath, model) -> UITableViewCell in
            let cell = tableView.dequeue(Reusable.friendProfileViewCell)!
            cell.isShowTextField = model.isShowTextField
            cell.titleLab.text = model.title
            cell.content = model.content
            cell.canEdit = model.isEnabled
            cell.longObservable
                .subscribe(onNext: { [unowned self] in
                    UIPasteboard.general.string = model.content
                    self.showToast(message: "Copy Success!")
                })
                .disposed(by: cell.disposeBag)
            cell.selectionStyle = .none
            return cell
        })
        
        reactor.state
            .map{ [SectionModel(model: "", items: $0.repos)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.avatar }
            .bind(to: infoView.rx.setImage())
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.isOwner }
            .subscribe(onNext: { [unowned self] state in
                self.infoView.canEdit = state
                if state {
                    self.editButton.setTitle("Edit", for: .normal)
                    self.editButton.isHidden = false
                } else {
                    self.editButton.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        rx.viewDidLoad
            .map{_ in Reactor.Action.requestUserInfo }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.merge(infoView.canEditTap, infoView.imageBtnTap)
            .flatMap { [unowned self] in
                self.picker.image(optionSet: [.camera, .photo], delegate: self)
            }
            .map{ $0.0 }
            .bind(to: infoView.rx.setImage(for: .selected))
            .disposed(by: disposeBag)
        
        updateUserInfoRelay
            .map{ Reactor.Action.updateUserInfo($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        toggleEnableRelay
            .map{ _ in Reactor.Action.toggleEnable }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    @objc
    private func leftBarItemDidTapped() {
        let params = self.getParams()
        // 如果值没有改变, 仅仅切换可编辑模式
        if params.isEquad(to: reactor?.currentState.repos) {
            dismiss(animated: true)
        } else {
            let alert = UIAlertController(title: "Whether to give up saving", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
                self.dismiss(animated: true)
            }))
            present(alert, animated: true)
        }
    }
    
    @objc
    private func rightBarItemDidTapped(sender: UIButton) {
        
        //隐藏键盘
        view.endEditing(true)
        if sender.isSelected {
            if self.checkoutParams() {
                let params = self.getParams()
                // 如果值没有改变, 仅仅切换可编辑模式
                if params.isEquad(to: reactor?.currentState.repos) {
                    toggleEnableRelay.accept(())
                } else {
                    updateUserInfoRelay.accept(params)
                }
            } else {
                showToast(message: "The content you fill in cannot be empty")
            }
        } else {
            toggleEnableRelay.accept(())
        }
        sender.isSelected.toggle()
    }
    
    private func checkoutParams() -> Bool {
        let visibleCells = self.tableView.visibleCells as? Array<FriendProfileViewCell>
        let params = visibleCells?.map{ ($0.titleLab.text, $0.content) }
        //判断任意一个字段为空, 就返回false
        if params?.filter({ $1 == nil || $1?.isEmpty == true }).isEmpty == true {
            return true
        } else {
            return false
        }
    }
    
    private func getParams() -> FriendProfileReactor.UserParams {
        let visibleCells = self.tableView.visibleCells as? Array<FriendProfileViewCell>
        // 我们根据按钮是否被选中, 来判断头像是否被改变, 进而判断是否需要重新上传头像
        let avatar = infoView.image(for: .selected)?.compressImage(toByte: 200000)
        return FriendProfileReactor.UserParams(params: visibleCells?.map{ ($0.titleLab.text!, $0.content) }, avatar: avatar)
    }
}

extension FriendProfileViewController {
    
    func addListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeListener() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShowNotification(sender: Notification) {
        guard
            let keyboardEndFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = sender.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardEndFrame.height, right: 0)
        }, completion: nil)
    }
    
    @objc
    private func keyboardWillHideNotification(sender: Notification) {
        let duration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration ?? 0.25) {
            self.tableView.contentInset = .zero
        }
    }
}
