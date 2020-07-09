//
//  VerificationCodeViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/9.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class VerificationCodeViewController: BaseViewController, BrickInputFieldStyle {

    private var sendBtn = UIButton()
    private var codeField = UITextField()
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
        
        sendBtn.setTitle("A code was just sent to your device.", for: .normal)
        sendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        sendBtn.setTitleColor(.white, for: .normal)
        backgroundView.addSubview(sendBtn)
        
        confirmBtn.backgroundColor = UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 1)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        confirmBtn.setTitle("Get Started!", for: .normal)
        
        configInputField(codeField, placeholder: "Enter Code")
        
        stackView = UIStackView(arrangedSubviews: [codeField, confirmBtn])
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
        
        sendBtn.snp.makeConstraints { (maker) in
            maker.height.equalTo(44)
            maker.leading.trailing.equalToSuperview().inset(47)
            maker.top.equalTo(backgroundView.imageView.snp.bottom).offset(75)
        }
        
        stackView.snp.makeConstraints { (maker) in
            maker.height.equalTo(120)
            maker.leading.trailing.equalToSuperview().inset(47)
            maker.top.equalTo(sendBtn.snp.bottom).offset(15)
        }
    }
}
