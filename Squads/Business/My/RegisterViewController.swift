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
    private var phoneField = UITextField()
    private var confirmBtn = UIButton()
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
        confirmBtn.setTitle("Send Me a Code", for: .normal)
        confirmBtn.addTarget(self, action: #selector(confirmBtnDidTapped), for: .touchUpInside)
        
        configInputField(usernameField, placeholder: "Username")
        configInputField(passwordField, placeholder: "Password")
        configInputField(confirmPasswordField, placeholder: "Confirm Password")
        configInputField(phoneField, placeholder: "Phone Number")
        
        stackView = UIStackView(arrangedSubviews: [usernameField, passwordField, confirmPasswordField, phoneField, confirmBtn])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 20
        backgroundView.addSubview(stackView)
    }
    
    override func setupConstraints() {
        backgroundView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { (maker) in
            maker.height.equalTo(330)
            maker.leading.trailing.equalToSuperview().inset(47)
            maker.top.equalTo(backgroundView.imageView.snp.bottom).offset(60)
        }
    }
    
    @objc
    private func confirmBtnDidTapped() {
        let vc = VerificationCodeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
