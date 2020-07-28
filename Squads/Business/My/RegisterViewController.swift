//
//  RegisterViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/8.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class RegisterViewController: BaseViewController, BrickInputFieldStyle {

    private var usernameField = UITextField()
    private var passwordField = UITextField()
    private var confirmPasswordField = UITextField()
    private var confirmBtn = UIButton()
    private var stackView: UIStackView!
    private var backgroundView = LoginBackgroundView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBarBgAlpha = 0.0
        self.navBarTintColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundView.addListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundView.removeListener()
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        confirmPasswordField.resignFirstResponder()
    }
    
    override func setupView() {
        
        view.addSubview(backgroundView)
        
        confirmBtn.backgroundColor = UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 1)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        confirmBtn.setTitle("Send Me a Code", for: .normal)
        confirmBtn.addTarget(self, action: #selector(confirmBtnDidTapped), for: .touchUpInside)
        
        passwordField.isSecureTextEntry = true
        confirmPasswordField.isSecureTextEntry = true
        configInputField(usernameField, placeholder: "Username")
        configInputField(passwordField, placeholder: "Password")
        configInputField(confirmPasswordField, placeholder: "Confirm Password")
        
        stackView = UIStackView(arrangedSubviews: [usernameField, passwordField, confirmPasswordField, confirmBtn])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 20
        backgroundView.addSubview(stackView)
        backgroundView.offsetY = 130
    }
    
    override func setupConstraints() {
        backgroundView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { (maker) in
            let count = Int(stackView.arrangedSubviews.count)
            maker.height.equalTo(count * 50 + (count - 1) * 20)
            maker.leading.trailing.equalToSuperview().inset(47)
            maker.top.equalTo(backgroundView.imageView.snp.bottom).offset(60)
        }
    }
    
    @objc
    private func confirmBtnDidTapped() {
        UserTDO.instance.username = usernameField.text
        UserTDO.instance.password = passwordField.text
        UserTDO.instance.rePassword = confirmPasswordField.text
        let result = UserTDO.instance.checkout(properties: [.username, .password, .rePassword])
        switch result {
        case .success:
            let vc = RegisterPhoneNumberViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .failure(let error):
            showToast(message: error.message)
        }
    }
    
}
