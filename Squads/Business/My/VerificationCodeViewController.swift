//
//  VerificationCodeViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/9.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

class VerificationCodeViewController: BaseViewController, BrickInputFieldStyle {

    private var disposeBag = DisposeBag()
    private var provider = OnlineProvider<UserAPI>()
    
    private var sendBtn = UIButton()
    private var codeField = UITextField()
    private var confirmBtn = UIButton()
    private var stackView: UIStackView!
    private var backgroundView = LoginBackgroundView()
    
    private static var lastUnreadDate: Date?
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
        confirmBtn.setTitle("Next", for: .normal)
        
        configInputField(codeField, placeholder: "Enter Code")
        
        stackView = UIStackView(arrangedSubviews: [codeField, confirmBtn])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 20
        backgroundView.addSubview(stackView)
        backgroundView.offsetY = 70
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
    
    override func addTouchAction() {
        
        let totalSeconds: Int = 59
        
        // 启动器事件
        let timer = Observable
            .merge(sendBtn.rx.tap.map{ true }.startWith(false),
                   UIApplication.shared.rx.applicationWillEnterForeground.map{ _ in false })
            .flatMap { isTap -> Observable<Int> in
                
                var duration: Int = 0
                var isBusy: Bool = false
                if let lastDate = VerificationCodeViewController.lastUnreadDate {
                    let distance = abs(Int(lastDate.timeIntervalSinceNow))
                    isBusy = totalSeconds > distance
                }
            
                //按钮点击
                if isTap {
                    duration = totalSeconds
                    VerificationCodeViewController.lastUnreadDate = Date()
                } else if isBusy {
                    if let lastDate = VerificationCodeViewController.lastUnreadDate {
                        let distance = min(abs(Int(lastDate.timeIntervalSinceNow)), totalSeconds)
                        duration = distance == totalSeconds ? totalSeconds : totalSeconds - distance
                    } else {
                        duration = totalSeconds
                    }
                } else {
//                    return Observable.just(totalSeconds)
                    duration = totalSeconds
                }
                
                return Observable<Int>
                    .timer(duration: duration, interval: 1)
                    .takeUntil(UIApplication.shared.rx.applicationDidEnterBackground)
            }
            .share()
        
        timer
            .map{ $0 <= 0 }
            .distinctUntilChanged()
            .bind(to: sendBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        timer
            .filter{ $0 == totalSeconds }
            .flatMap { [unowned self] _ -> Observable<Result<GeneralModel.Plain, GeneralError>> in
                guard
                    let nationCode = UserTDO.instance.nationCode,
                    let phoneNumer = UserTDO.instance.phoneNumber,
                    let purePhoneNumber = UserTDO.instance.purePhoneNumber else {
                        return .just(.failure(.custom("The cell phone number is empty!")))
                }
                return self.provider.request(target: .getverificationcode(nationCode: nationCode,
                                                                          phoneNumber: phoneNumer,
                                                                          purePhoneNumber: purePhoneNumber),
                                             model: GeneralModel.Plain.self).asObservable()
            }
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .success:
                    let toast = NSLocalizedString("system.sendCodeSuccessful", comment: "")
                    self.showToast(message: toast)
                case .failure(let error):
                    self.showToast(message: error.message)
                }
            })
            .disposed(by: disposeBag)
        
//        timer
//            .map{ "重新获取(\($0.formatString))s" }
//            .bind(to: sendBtn.rx.title(for: .disabled))
//            .disposed(by: disposeBag)
        
        let tap = confirmBtn.rx.tap
        
        tap.subscribe(onNext: { [unowned self] in
            self.showLoading(offsetY: 0)
        })
        .disposed(by: disposeBag)
        
        tap.flatMap{ [unowned self] _ -> Observable<Result<GeneralModel.Plain, GeneralError>> in
                
                guard
                    let nationCode = UserTDO.instance.nationCode,
                    let phoneNumer = UserTDO.instance.phoneNumber,
                    let purePhoneNumber = UserTDO.instance.purePhoneNumber else {
                        return .just(.failure(.custom("The cell phone number is empty!")))
                }
                
                let code = self.codeField.text
                UserTDO.instance.verificationcode = code
                let result = UserTDO.instance.checkout(properties: [.verificationcode])
                if case let .failure(error) = result {
                    return .just(.failure(error))
                }
                
                return self.provider.request(target: .verificationcode(nationCode: nationCode,
                                                                       phoneNumber: phoneNumer,
                                                                       purePhoneNumber: purePhoneNumber,
                                                                       code: code!),
                                             model: GeneralModel.Plain.self).asObservable()
            }
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .success:
                    self.hideLoading()
                    let profileVC = RegisterUserProfileViewController()
                    self.navigationController?.pushViewController(profileVC, animated: true)
                case .failure(let error):
                    self.hideLoading()
                    self.showToast(message: error.message)
                }
            })
            .disposed(by: disposeBag)
        
        codeField.rx.text.orEmpty
            .map{ !$0.isEmpty }
            .bind(to: confirmBtn.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

extension Int {
    fileprivate var formatString: String {
        if self > 9 {
            return "\(self)"
        }
        else {
            return "0\(self)"
        }
    }
}
