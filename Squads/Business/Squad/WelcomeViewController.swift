//
//  WelcomeViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/30.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class WelcomeViewController: BaseViewController {

    private var titleLab = UILabel()
    private var topDescriptionLab = UILabel()
    private var bottomDescriptionLab = UILabel()
    private var inputField = UITextField()
    private var confirmBtn = UIButton()
    
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
        
        inputField.placeholder = "Input Code"
        inputField.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        inputField.borderStyle = .none
        view.addSubview(inputField)
        
        topDescriptionLab.textAlignment = .center
        topDescriptionLab.text = "Invited to existing Squad? Input Squad code here!"
        topDescriptionLab.font = UIFont.systemFont(ofSize: 16)
        topDescriptionLab.theme.textColor = UIColor.textGray
        view.addSubview(topDescriptionLab)
        
        bottomDescriptionLab.textAlignment = .center
        bottomDescriptionLab.text = "If not, create your first Squad!"
        bottomDescriptionLab.font = UIFont.systemFont(ofSize: 16)
        bottomDescriptionLab.theme.textColor = UIColor.textGray
        view.addSubview(bottomDescriptionLab)
    }
    
    override func setupConstraints() {
        titleLab.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(100)
            } else {
                maker.top.equalTo(topLayoutGuide.snp.bottom).offset(100)
            }
        }
        
        topDescriptionLab.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.width.equalTo(300)
            maker.top.equalTo(titleLab.snp.bottom).offset(50)
        }
        
        inputField.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview().inset(47)
            maker.height.equalTo(50)
            maker.top.equalTo(topDescriptionLab.snp.bottom)
        }
        
        bottomDescriptionLab.snp.makeConstraints { (maker) in
            maker.centerX.width.equalTo(topDescriptionLab)
            maker.top.equalTo(inputField.snp.bottom).offset(50)
        }
        
        confirmBtn.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalTo(inputField)
            maker.top.equalTo(bottomDescriptionLab.snp.bottom).offset(30)
            maker.height.equalTo(50)
        }
    }
}