//
//  RegisterUserProfileViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/24.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

class RegisterUserProfileViewController: BaseViewController, BrickInputFieldStyle {

    private let picker = AvatarPicker()
    private var disposeBag = DisposeBag()
    private var descriptionLab = UILabel()
    private var avatarView = EditableAvatarView()
    private var nicknameField = UITextField()
    private var confirmBtn = UIButton()
    private var stackView: UIStackView!
    private var backgroundView = LoginBackgroundView()
    private var provider = OnlineProvider<UserAPI>()
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
        nicknameField.resignFirstResponder()
    }
    
    override func setupView() {
        
        view.addSubview(backgroundView)
        
        descriptionLab.text = "Complete your profile!"
        descriptionLab.textColor = .white
        descriptionLab.font = UIFont.systemFont(ofSize: 16)
        descriptionLab.textAlignment = .center
        backgroundView.addSubview(descriptionLab)
        
        avatarView.canEdit = true
        avatarView.imageSize = CGSize(width: 107, height: 107)
        backgroundView.addSubview(avatarView)
        backgroundView.offsetY = 150
        
        configInputField(nicknameField, placeholder: "Name")
        
        confirmBtn.backgroundColor = UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 1)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        confirmBtn.setTitle("Get Started!", for: .normal)
        
        stackView = UIStackView(arrangedSubviews: [nicknameField, confirmBtn])
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

        descriptionLab.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(backgroundView.imageView.snp.bottom).offset(30)
        }
        
        avatarView.snp.makeConstraints { (maker) in
            maker.size.equalTo(CGSize(width: 107, height: 107))
            maker.centerX.equalToSuperview()
            maker.top.equalTo(descriptionLab.snp.bottom).offset(30)
        }
        
        stackView.snp.makeConstraints { (maker) in
            let count = Int(stackView.arrangedSubviews.count)
            maker.height.equalTo(count * 50 + (count - 1) * 20)
            maker.leading.trailing.equalToSuperview().inset(47)
            maker.top.equalTo(avatarView.snp.bottom).offset(34)
        }
    }
    
    override func addTouchAction() {
        
        Observable.merge(avatarView.canEditTap, avatarView.imageBtnTap)
            .flatMap { [unowned self] in
                self.picker.image(optionSet: [.camera, .photo], delegate: self)
            }
            .map{ $0.0 }
            .do(onNext: { image in
                UserTDO.instance.avatar = image.compressImage(toByte: 200000)
            })
            .bind(to: avatarView.rx.setImage(for: .normal))
            .disposed(by: rx.disposeBag)
        
        nicknameField.rx.text.orEmpty
            .do(onNext: { text in
                UserTDO.instance.nickname = text
            })
            .map{ !$0.isEmpty }
            .bind(to: confirmBtn.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        let tapObservable = confirmBtn.rx.tap
    
        tapObservable
            .subscribe(onNext: { [unowned self] in
                self.confirmBtn.isEnabled = false
                self.showLoading(offsetY: 0)
            })
            .disposed(by: disposeBag)
        
        tapObservable
            .flatMap{ [unowned self] _ -> Observable<Result<GeneralModel.Plain, GeneralError>> in
                let result = UserTDO.instance.checkout(properties: [.username, .password, .phoneNumber, .nickname, .avatar])
                switch result {
                case .success(let model):
                    return self.provider.request(target: .signUp(username: model.username!,
                                                                 password: model.password!,
                                                                 inviteCode: "",
                                                                 nationCode: model.nationCode!,
                                                                 phoneNumber: model.phoneNumber!,
                                                                 purePhoneNumber: model.purePhoneNumber!,
                                                                 nickname: model.nickname!,
                                                                 avatar: model.avatar!),
                                                 model: GeneralModel.Plain.self).asObservable()
                case .failure(let error):
                    return Observable.just(.failure(error))
                }
            }
            .subscribe(onNext: { [unowned self] result in
                
                self.hideLoading()
                self.confirmBtn.isEnabled = true
                
                switch result {
                case .success:
                    let toast = NSLocalizedString("system.registerSuccess", comment: "")
                    self.showToast(message: toast)
                    self.navigationController?.popToRootViewController(animated: true)
                case .failure(let error):
                    self.showToast(message: error.message)
                }
            })
            .disposed(by: disposeBag)
    }
}
