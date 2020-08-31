//
//  JoinSquadViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/19.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

class JoinSquadViewController: ReactorViewController<JoinSquadReactor> {

    private var iconBtn = UIButton()
    private var titleLab = UILabel()
    private var cancelBtn = UIButton()
    private var confirmBtn = UIButton()
    private var descriptionLab = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
    }

    override func setupView() {
        
        iconBtn.imageView?.layer.cornerRadius = 71.5
        iconBtn.imageView?.layer.masksToBounds = true
        
        titleLab.textAlignment = .center
        titleLab.theme.textColor = UIColor.text
        titleLab.font = UIFont.systemFont(ofSize: 36, weight: .medium)
        
        descriptionLab.textAlignment = .center
        descriptionLab.theme.textColor = UIColor.textGray
        descriptionLab.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        #if DEBUG
        // 在这里直接输入squadId就可以加入该Squad中, 此功能只有在debug下才有用
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 3
        descriptionLab.addGestureRecognizer(tap)
        descriptionLab.isUserInteractionEnabled = true
        tap.rx.event
            .trackInputAlert(title: "DEBUG", placeholder: "在这里输入SquadId", default: "Confirm", target: self)
            .compactMap{ text in
                guard
                    let accountId = User.currentUser()?.id,
                    let squadId = Int(text) else { return nil }
                return Reactor.Action.joinSquad(accountId: accountId, squadId: squadId)
            }
            .bind(to: reactor!.action)
            .disposed(by: disposeBag)
        #endif
        
        confirmBtn.setTitle("Join", for: .normal)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.layer.cornerRadius = 25
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        confirmBtn.backgroundColor = UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 1)
        
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.theme.titleColor(from: UIColor.textGray, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        view.addSubviews(iconBtn, titleLab, cancelBtn, confirmBtn, descriptionLab)
    }
    
    override func setupConstraints() {
        
        /// 布局Squad预览视图
        
        let squadLayout = UILayoutGuide()
        view.addLayoutGuide(squadLayout)
        
        iconBtn.snp.makeConstraints { (maker) in
            maker.centerX.top.equalTo(squadLayout)
            maker.size.equalTo(CGSize(width: 143, height: 143))
        }
        titleLab.snp.makeConstraints { (maker) in
            maker.height.equalTo(42)
            maker.top.equalTo(iconBtn.snp.bottom).offset(40)
            maker.bottom.leading.trailing.equalTo(squadLayout)
        }
        squadLayout.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview().inset(20)
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(70)
            } else {
               maker.top.equalTo(topLayoutGuide.snp.bottom).offset(70)
           }
        }
        
        /// 布局确认/取消按钮视图
        
        let menuLayout = UILayoutGuide()
        view.addLayoutGuide(menuLayout)
        
        confirmBtn.snp.makeConstraints { (maker) in
            maker.leading.top.trailing.equalTo(menuLayout)
            maker.height.equalTo(50)
        }
        cancelBtn.snp.makeConstraints { (maker) in
            maker.height.equalTo(50)
            maker.leading.trailing.bottom.equalTo(menuLayout)
            maker.top.equalTo(confirmBtn.snp.bottom).offset(2)
        }
        menuLayout.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview().inset(47)
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
            } else {
                maker.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-100)
            }
        }
        
        descriptionLab.snp.makeConstraints { (maker) in
            maker.height.equalTo(20)
            maker.leading.trailing.equalToSuperview().inset(20)
            maker.top.equalTo(squadLayout.snp.bottom).offset(47)
        }
    }
    
    override func bind(reactor: JoinSquadReactor) {
        
        reactor.state
            .compactMap{ $0.isLoading }
            .bind(to: iconBtn.rx.activityIndicator)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.toast }
            .bind(to: rx.toastNormal)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.user?.nickname }
            .map{ "\($0) has invitited you to his squad!" }
            .bind(to: descriptionLab.rx.text)
            .disposed(by: disposeBag)
        
        let detail: Observable<SquadDetail?> = reactor.state.map{ $0.squadDetail }
        
        detail
            .map{ $0?.logoPath.asURL }
            .bind(to: iconBtn.rx.imageURL(withPlaceholder: UIImage(named: "Squad Placeholder")))
            .disposed(by: disposeBag)
        
        detail
            .map{ $0?.squadName }
            .bind(to: titleLab.rx.text)
            .disposed(by: disposeBag)
            
        detail
            .map{ $0?.squadCode != nil }
            .bind(to: confirmBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        let confirmBtnDidTapped: Observable<Reactor.Action?> = confirmBtn.rx.tap.map {
            guard
                let accountId = User.currentUser()?.id,
                let squadId = reactor.currentState.squadDetail?.id else {
                    return nil
            }
            return Reactor.Action.joinSquad(accountId: accountId, squadId: squadId)
        }
        
        confirmBtnDidTapped
            .compactMap{ $0 }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        let joinSuccess: Observable<Void> = reactor.state
            .filter{ $0.joinSuccess == true }
            .map{_ in () }
        
        let loginFailure: Observable<Void> = confirmBtnDidTapped
            .filter{ $0 == nil }
            .trackAlertJustConfirm(title: "You are not logged in yet", target: self)
            .map{ _ in () }
        
        Observable.merge(loginFailure, joinSuccess, cancelBtn.rx.tap.asObservable())
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        Observable.just(Reactor.Action.requestSquadDetail)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
