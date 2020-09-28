//
//  ApplyListTableViewCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/18.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

class ApplyListViewCell: BaseTableViewCell {
    
    var avatarView = UIButton()
    var nicknameLab = UILabel()
    var contentLab = UILabel()
    var actionBtn = UIButton()
    
    var disposeBag = DisposeBag()
    
    override func setupView() {
        
        avatarView.layer.maskCorners(20, rect: CGRect(x: 0, y: 0, width: 40, height: 40))
        avatarView.clipsToBounds = true
        avatarView.imageView?.contentMode = .scaleAspectFill
        
        nicknameLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        nicknameLab.theme.textColor = UIColor.text
        nicknameLab.numberOfLines = 1
        
        contentLab.font = UIFont.systemFont(ofSize: 12)
        contentLab.theme.textColor = UIColor.textGray
        contentLab.numberOfLines = 1
        
        actionBtn.setBackgroundImage(UIImage(color: UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 1)), for: .normal)
        actionBtn.setBackgroundImage(UIImage(color: UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 1)), for: .selected)
        actionBtn.setTitleColor(.white, for: .normal)
        actionBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        actionBtn.layer.maskCorners(3, rect: CGRect(x: 0, y: 0, width: 37, height: 21))
        actionBtn.clipsToBounds = true
        
        contentView.addSubviews(avatarView, nicknameLab, contentLab, actionBtn)
        avatarView.snp.makeConstraints { (maker) in
            maker.leading.equalTo(34)
            maker.centerY.equalToSuperview()
            maker.size.equalTo(CGSize(width: 40, height: 40))
        }
        actionBtn.snp.makeConstraints { (maker) in
            maker.trailing.equalTo(-34)
            maker.size.equalTo(CGSize(width: 37, height: 21))
            maker.centerY.equalToSuperview()
        }
        nicknameLab.snp.makeConstraints { (maker) in
            maker.leading.equalTo(avatarView.snp.trailing).offset(12)
            maker.top.equalTo(avatarView).offset(3)
            maker.width.equalTo(260)
        }
        contentLab.snp.makeConstraints { (maker) in
            maker.leading.equalTo(nicknameLab)
            maker.top.equalTo(nicknameLab.snp.bottom).offset(2)
            maker.trailing.equalTo(actionBtn.snp.leading).offset(-5)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
