//
//  UserInfoCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/24.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

final class UserInfoCell: BaseTableViewCell {
    
    var disposeBag = DisposeBag()
    
    var titleLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textColor = .black
        return lab
    }()
    
    var attachView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_enter_arrow")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    var contentLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 16)
        lab.textColor = UIColor(hexString: "#808080")
        lab.isHidden = true
        return lab
    }()
    
    var avatarView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()
    
    var switchView: UISwitch = {
        let view = UISwitch()
        view.theme.onTintColor = UIColor.secondary
        view.isHidden = true
        return view
    }()
    
    override func setupView() {
        [titleLab, attachView, contentLab, avatarView, switchView].forEach{ contentView.addSubview($0) }
        
        titleLab.snp.makeConstraints { (maker) in
            maker.leading.equalTo(15)
            maker.centerY.equalToSuperview()
        }
        
        attachView.snp.makeConstraints { (maker) in
            maker.trailing.equalTo(-15)
            maker.size.equalTo(CGSize(width: 6, height: 11))
            maker.centerY.equalToSuperview()
        }
        
        contentLab.snp.makeConstraints { (maker) in
            maker.trailing.equalTo(-15).priority(.low)
            maker.trailing.equalTo(attachView.snp.leading).offset(-10).priority(.high)
            maker.centerY.equalToSuperview()
        }
        
        avatarView.snp.makeConstraints { (maker) in
            maker.trailing.equalTo(-15).priority(.low)
            maker.trailing.equalTo(attachView.snp.leading).offset(-10).priority(.high)
            maker.centerY.equalToSuperview()
            maker.size.equalTo(CGSize(width: 36, height: 36))
        }
        
        switchView.snp.makeConstraints { (maker) in
            maker.trailing.equalTo(-15)
            maker.centerY.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
