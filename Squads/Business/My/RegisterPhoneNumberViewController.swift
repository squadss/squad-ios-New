//
//  RegisterPhoneNumberViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/24.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

class RegisterPhoneNumberViewController: BaseViewController, BrickInputFieldStyle, UITextFieldDelegate {

    let normalNotionCode: String = "+1"
    
    // 格式化后的手机号
    private var formatPhone: String? {
        return phoneNumberField.text?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "")
    }
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        phoneNumberField.resignFirstResponder()
    }
    
    override func setupView() {
        
        view.addSubview(backgroundView)
        
        nationCodeBtn.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        nationCodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        nationCodeBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        nationCodeBtn.setTitleColor(.white, for: .normal)
        nationCodeBtn.setTitle(normalNotionCode, for: .normal)
        nationCodeBtn.addTarget(self, action: #selector(nationCodeBtnDidTapped), for: .touchUpInside)
        
        confirmBtn.backgroundColor = UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 1)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        confirmBtn.setTitle("Send Me a Code", for: .normal)
        confirmBtn.addTarget(self, action: #selector(confirmBtnDidTapped), for: .touchUpInside)
        
        phoneNumberField.keyboardType = .numberPad
        phoneNumberField.delegate = self
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
    
    override func addTouchAction() {
        NotificationCenter.default.rx
            .notification(UITextField.textDidChangeNotification)
            .subscribe(onNext: { [unowned self] notification in
                guard let textField = notification.object as? UITextField, let text = textField.text else {
                    return
                }
                
                if textField === self.phoneNumberField {
                    textField.text = textField.text?.insertSpacePhone
                    let newPosition = textField.endOfDocument
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                }
                
                //  13 位包括两个空格
                if textField === self.phoneNumberField && text.count >= 13 {
                    textField.text = text[0..<13]
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    @objc
    private func confirmBtnDidTapped() {
        UserTDO.instance.phoneNumber = formatPhone
        UserTDO.instance.nationCode = nationCodeBtn.title(for: .normal)
        
        let result = UserTDO.instance.checkout(properties: .phoneNumber)
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
        let vc = RegisterNationCodeViewController()
        vc.didSelectedItemObservable
            .bind(to: nationCodeBtn.rx.title(for: .normal))
            .disposed(by: disposeBag)
        present(vc, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789 ")
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
