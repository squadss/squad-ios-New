//
//  LoginViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import HGPlaceholders
import RxDataSources
import ETNavBarTransparent

class LoginViewController: ReactorViewController<LoginReactor>, BrickInputFieldStyle {

//    var provider = OnlineProvider<UserAPI>()
        
//    let layout = UICollectionViewFlowLayout()
//    lazy var collection = CollectionView(frame: CGRect(x: 0, y: 100, width: view.bounds.width, height: view.bounds.height - 100), collectionViewLayout: layout)
    
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
        
//        collection.backgroundColor = .white
//        view.addSubview(collection)
//
//        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, String>>(configureCell: { (data, collectionView, indexPath, model) -> UICollectionViewCell in
//
//            let cell = UICollectionViewCell()
//            return cell
//        })
        
//        Observable<Array<String>>.just(["1"])
//            .map{ [SectionModel(model: "", items: $0)] }
//            .bind(to: collection.rx.items(dataSource: dataSource))
//            .disposed(by: rx.disposeBag)
        
//        collection.rx.actionButtonTapped
//            .subscribe(onNext: {
//                print($0)
//            })
//            .disposed(by: rx.disposeBag)
//
//        provider
//            .request(target: .signUp(username: "123", password: "123", rePassword: "123", inviteCode: "123"),
//                     model: String.self,
//                     atKeyPath: .data)
//            .asObservable()
//            .debug()
//            .compactMap{ $0.error }
//            .bind(to: collection.rx.placeholder)
//            .disposed(by: rx.disposeBag)
    }
    
    override func setupView() {
        
        view.addSubview(backgroundView)
        
        confirmBtn.backgroundColor = UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 1)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        confirmBtn.setTitle("Sign In", for: .normal)
        confirmBtn.addTarget(self, action: #selector(confirmBtnDidTapped), for: .touchUpInside)
        
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
    
    @objc
    private func confirmBtnDidTapped() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
