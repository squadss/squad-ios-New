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
    private var tipLabel = UILabel()
    private var indicatorView = UIActivityIndicatorView(style: .gray)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
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
        
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        indicatorView.frame = CGRect(x: 5, y: 5, width: 20, height: 20)
        indicatorView.hidesWhenStopped = true
        loadingView.addSubview(indicatorView)
        inputField.rightView = loadingView
        inputField.rightViewMode = .always
        inputField.placeholder = "Input Code"
        inputField.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        inputField.borderStyle = .none
        inputField.font = UIFont.systemFont(ofSize: 16)
        inputField.theme.textColor = UIColor.textGray
        inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 44))
        inputField.leftViewMode = .always
        inputField.setInputAccessoryView(target: self, selector: #selector(inputAccessoryDidTapped))
        view.addSubview(inputField)
        
        topDescriptionLab.textAlignment = .center
        topDescriptionLab.text = "Invited to existing Squad? Input Squad code here!"
        topDescriptionLab.font = UIFont.systemFont(ofSize: 16)
        topDescriptionLab.numberOfLines = 0
        topDescriptionLab.theme.textColor = UIColor.textGray
        view.addSubview(topDescriptionLab)
        
        bottomDescriptionLab.textAlignment = .center
        bottomDescriptionLab.text = "If not, create your first Squad!"
        bottomDescriptionLab.font = UIFont.systemFont(ofSize: 16)
        bottomDescriptionLab.theme.textColor = UIColor.textGray
        view.addSubview(bottomDescriptionLab)
        
        tipLabel.textAlignment = .center
        tipLabel.font = UIFont.systemFont(ofSize: 12)
        tipLabel.theme.textColor = UIColor.secondary
        view.addSubview(tipLabel)
    }
    
    override func setupConstraints() {
        
        titleLab.snp.makeConstraints { (maker) in
            let offsetY: CGFloat = UIScreen.main.bounds.height > 667 ? 100 : 70
            maker.leading.trailing.equalToSuperview()
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(offsetY)
            } else {
                maker.top.equalTo(topLayoutGuide.snp.bottom).offset(offsetY)
            }
        }
        
        topDescriptionLab.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.width.equalTo(267)
            maker.top.equalTo(titleLab.snp.bottom).offset(50)
        }
        
        inputField.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview().inset(47)
            maker.height.equalTo(50)
            maker.top.equalTo(topDescriptionLab.snp.bottom).offset(30)
        }
        
        tipLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(inputField.snp.bottom).offset(8)
            maker.leading.trailing.equalToSuperview()
        }
        
        bottomDescriptionLab.snp.makeConstraints { (maker) in
            maker.centerX.width.equalTo(topDescriptionLab)
            maker.bottom.equalTo(confirmBtn.snp.top).offset(-30)
        }
        
        confirmBtn.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalTo(inputField)
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-130)
            } else {
                maker.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-130)
            }
            maker.height.equalTo(50)
        }
    }
    
    override func bind(reactor: WelcomeReactor) {
        
        reactor.state
            .compactMap{ $0.toast }
            .bind(to: tipLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.isLoading }
            .bind(to: indicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        reactor.state
            .map{ $0.squadDetail }
            .distinctUntilChanged({ $0?.id == $1?.id })
            .subscribe(onNext: { [unowned self] detail in
                if let unwrappedDetail = detail {
                    self.tipLabel.text = unwrappedDetail.squadName + " is available!"
                } else {
                    self.tipLabel.text = nil
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.joinSquadId }
            .subscribe(onNext: { id in
                UserDefaults.standard.topSquad = id
                Application.shared.presentInitialScreent()
            })
            .disposed(by: disposeBag)
        
        let inputObservable: Observable<String> = inputField.rx.text.orEmpty.asObservable()
        
        inputObservable
            .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .filter{ $0.count == 5 }
            .map{ Reactor.Action.requestSquadDetail(code: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
          
        inputObservable
            .map { $0.count > 0 ? "Join Squad" : "Create New Squad" }
            .bind(to: confirmBtn.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        let confirmObservable: Observable<Void> = confirmBtn.rx.tap.asObservable()
        
        confirmObservable
            .filter{ [unowned self] in self.inputField.text?.isEmpty == false }
            .compactMap { _ in
                if let accountId = User.currentUser()?.id {
                    return Reactor.Action.joinSquad(accountId: accountId)
                }
                return nil
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        confirmObservable
            .filter{ [unowned self] in self.inputField.text == nil || self.inputField.text?.isEmpty == true }
            .subscribe(onNext: { [unowned self] _ in
                let vc = CreateSquadViewController()
                let nav = BaseNavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            })
            .disposed(by: disposeBag)

    }
    
    @objc
    private func inputAccessoryDidTapped() {
        inputField.resignFirstResponder()
    }
}
