//
//  LoginViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HGPlaceholders
import RxDataSources
import ETNavBarTransparent

class LoginViewController: ReactorViewController<LoginReactor>, BrickInputFieldStyle, UIGestureRecognizerDelegate {

    private var usernameField = UITextField()
    private var passwordField = UITextField()
    private var confirmBtn = UIButton()
    private var forgetBtn: UIButton!
    private var signUpLab: UILabel!
    private var stackView: UIStackView!
    private var backgroundView = LoginBackgroundView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBarBgAlpha = 0.0
        self.navBarTintColor = .clear
    }
    
    override func setupView() {
        
        
        view.addSubview(backgroundView)
        
        confirmBtn.backgroundColor = UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 1)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        confirmBtn.setTitle("Sign In", for: .normal)
        
        configInputField(usernameField, placeholder: "Username")
        configInputField(passwordField, placeholder: "Password")
        
        stackView = UIStackView(arrangedSubviews: [usernameField, passwordField, confirmBtn])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 20
        backgroundView.addSubview(stackView)
        
        forgetBtn = UIButton()
        forgetBtn.setTitle("Forgot Password?", for: .normal)
        forgetBtn.titleLabel?.font = UIFont(name: "SFProText-Regular", size: 16)
        forgetBtn.setTitleColor(.white, for: .normal)
        backgroundView.addSubview(forgetBtn)
        
        let attr = NSMutableAttributedString()
        attr.append(NSAttributedString(string: "Don't have an account? ", attributes: [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.white
        ]))
        attr.append(NSAttributedString(string: "Sign Up!", attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.white
        ]))
        
        signUpLab = UILabel()
        signUpLab.textAlignment = .center
        signUpLab.attributedText = attr
        backgroundView.addSubview(signUpLab)
        let tap = UITapGestureRecognizer(target: self, action: #selector(signupDidTapped(_:)))
        backgroundView.tap.require(toFail: tap)
        signUpLab.addGestureRecognizer(tap)
        signUpLab.isUserInteractionEnabled = true
    }
    
    override func setupConstraints() {
        backgroundView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { (maker) in
            maker.height.equalTo(190)
            maker.leading.trailing.equalToSuperview().inset(47)
            maker.top.equalTo(backgroundView.imageView.snp.bottom).offset(93)
        }
        
        forgetBtn.snp.makeConstraints { (maker) in
            maker.size.equalTo(CGSize(width: 200, height: 44))
            maker.top.equalTo(stackView.snp.bottom)
            maker.centerX.equalToSuperview()
        }
        
        signUpLab.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview().inset(20)
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
            } else {
                maker.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-100)
            }
        }
    }
    
    override func bind(reactor: LoginReactor) {
        
        confirmBtn.rx.tap
            .map{ [unowned self] in
                let username = self.usernameField.text!
                let password = self.passwordField.text!
                return Reactor.Action.login(username: username, password: password)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(usernameField.rx.text.orEmpty, passwordField.rx.text.orEmpty) { !($0.isEmpty || $1.isEmpty) }
            .bind(to: confirmBtn.rx.isEnabled)
            .disposed(by: disposeBag)
                
        reactor.state
            .compactMap{ $0.loading }
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.toast }
            .bind(to: rx.toastNormal)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.success }
            .delay(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { model in
                model.loginAccountVo.save()
                AuthManager.setToken(.normal(token: model.token))
                Application.shared.presentInitialScreent()
            })
            .disposed(by: disposeBag)
    }
    
    @objc
    private func signupDidTapped(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        let point = sender.location(in: signUpLab)
        let min = view.bounds.width * 0.6
        let max = view.bounds.width * 0.81
        if point.x >= min && point.x <= max {
            //在可点击区间内, 跳转页面
            let registerVC = RegisterViewController()
            navigationController?.pushViewController(registerVC, animated: true)
        }
    }
    
    deinit {
        print("Login Deinit")
    }
}
