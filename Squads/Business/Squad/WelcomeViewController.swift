//
//  WelcomeViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/30.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

class WelcomeViewController: ReactorViewController<WelcomeReactor> {

    private var titleLab = UILabel()
    private var topDescriptionLab = UILabel()
    private var bottomDescriptionLab = UILabel()
    private var inputField = UITextField()
    private var confirmBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
        
        //自定义导航栏按钮
        let leftBtn = UIButton()
        leftBtn.setTitle("Cancel", for: .normal)
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        leftBtn.theme.titleColor(from: UIColor.text, for: .normal)
        leftBtn.addTarget(self, action: #selector(leftBtnDidTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
    }

    override func setupView() {
        
        titleLab.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        titleLab.font = UIFont(name: "AvenirNext-Regular", size: 40)
        titleLab.text = "WELCOME"
        titleLab.textAlignment = .center
        view.addSubview(titleLab)
        
        confirmBtn.setTitle("Create New Squad", for: .normal)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        confirmBtn.setBackgroundImage(UIImage(color: UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 1)), for: .normal)
        view.addSubview(confirmBtn)
        
        inputField.placeholder = "Input Code"
        inputField.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        inputField.borderStyle = .none
        view.addSubview(inputField)
        
        topDescriptionLab.textAlignment = .center
        topDescriptionLab.text = "Invited to existing Squad? Input Squad code here!"
        topDescriptionLab.font = UIFont.systemFont(ofSize: 16)
        topDescriptionLab.theme.textColor = UIColor.textGray
        view.addSubview(topDescriptionLab)
        
        bottomDescriptionLab.textAlignment = .center
        bottomDescriptionLab.text = "If not, create your first Squad!"
        bottomDescriptionLab.font = UIFont.systemFont(ofSize: 16)
        bottomDescriptionLab.theme.textColor = UIColor.textGray
        view.addSubview(bottomDescriptionLab)
    }
    
    override func setupConstraints() {
        titleLab.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(100)
            } else {
                maker.top.equalTo(topLayoutGuide.snp.bottom).offset(100)
            }
        }
        
        topDescriptionLab.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.width.equalTo(300)
            maker.top.equalTo(titleLab.snp.bottom).offset(50)
        }
        
        inputField.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview().inset(47)
            maker.height.equalTo(50)
            maker.top.equalTo(topDescriptionLab.snp.bottom)
        }
        
        bottomDescriptionLab.snp.makeConstraints { (maker) in
            maker.centerX.width.equalTo(topDescriptionLab)
            maker.top.equalTo(inputField.snp.bottom).offset(50)
        }
        
        confirmBtn.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalTo(inputField)
            maker.top.equalTo(bottomDescriptionLab.snp.bottom).offset(30)
            maker.height.equalTo(50)
        }
    }
    
    override func bind(reactor: WelcomeReactor) {
        
        reactor.state
            .compactMap{ $0.toast }
            .bind(to: rx.toastNormal)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.isLoading }
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.squadDetail }
            .subscribe(onNext: { [unowned self] in
                self.showToast(message: $0.logoPath)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.joinSuccess }
            .subscribe(onNext: { [unowned self] _ in
                //TODO: 是否需要将加入的squad设为默认的, 后面需要讨论
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .map{ Reactor.Action.requestSquadDetail }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        let confirmBtnDidTapped: Observable<Reactor.Action?> = confirmBtn.rx.tap.map {
            if let accountId = User.currentUser()?.id {
                return Reactor.Action.joinSquad(accountId: accountId)
            }
            return nil
        }
        
        confirmBtnDidTapped
            .compactMap{ $0 }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        confirmBtnDidTapped
            .filter{ $0 == nil }
            .trackAlertJustConfirm(title: "You are not logged in yet", target: self)
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    @objc
    private func leftBtnDidTapped() {
        dismiss(animated: true)
    }
}
