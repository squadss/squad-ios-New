//
//  RegisterPhoneNumberViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/24.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

class RegisterPhoneNumberViewController: RegisterGeneralViewController {

    let normalNotionCode: String = "+1"
    
    private var disposeBag = DisposeBag()
    private var phoneNumberField = UITextField()
    private var confirmBtn = UIButton()
    private var nationCodeBtn = UIButton()
    private var stackView: UIStackView!
    private var backgroundView = LoginBackgroundView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBarBgAlpha = 0.0
        self.navBarTintColor = .clear
    }
    
    override func setupView() {
        
        view.addSubview(backgroundView)
        
        nationCodeBtn.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        nationCodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        nationCodeBtn.setTitleColor(.white, for: .normal)
        nationCodeBtn.setTitle(normalNotionCode, for: .normal)
        nationCodeBtn.addTarget(self, action: #selector(nationCodeBtnDidTapped), for: .touchUpInside)
        
        confirmBtn.backgroundColor = UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 1)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        confirmBtn.setTitle("Send Me a Code", for: .normal)
        confirmBtn.addTarget(self, action: #selector(confirmBtnDidTapped), for: .touchUpInside)
        
        configInputField(phoneNumberField, placeholder: "Phone Number")
        
        let tempView = UIView()
        tempView.addSubviews(nationCodeBtn, phoneNumberField)
        nationCodeBtn.snp.makeConstraints { (maker) in
            maker.leading.top.bottom.equalToSuperview()
            maker.width.equalTo(43)
        }
        phoneNumberField.snp.makeConstraints { (maker) in
            maker.trailing.top.bottom.equalToSuperview()
            maker.leading.equalTo(nationCodeBtn.snp.trailing).offset(11)
        }
        
        stackView = UIStackView(arrangedSubviews: [tempView, confirmBtn])
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
            let count = Int(stackView.arrangedSubviews.count)
            maker.height.equalTo(count * 50 + (count - 1) * 20)
            maker.leading.trailing.equalToSuperview().inset(47)
            maker.top.equalTo(backgroundView.imageView.snp.bottom).offset(60)
        }
    }
    
    @objc
    private func confirmBtnDidTapped() {
        userTDO.phoneNumber = phoneNumberField.text
        let result = checkoutParams(properties: .phoneNumber)
        switch result {
        case .success:
            let vc = VerificationCodeViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .failure(let error):
            self.showToast(message: error.message)
        }
    }
    
    @objc
    private func nationCodeBtnDidTapped() {
        let vc = ZonesViewController()
        vc.didSelectedItemObservable
            .bind(to: nationCodeBtn.rx.title(for: .normal))
            .disposed(by: disposeBag)
        present(vc, animated: true)
    }
}
