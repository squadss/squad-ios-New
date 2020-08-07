//
//  SquadInvithNewMemberCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/19.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

class SquadInvithNewMemberCell: BaseCollectionViewCell {
    
    private var closeSubject = PublishSubject<Void>()
    var closeBtnDidTapped: Observable<Void> {
        return closeSubject.asObservable()
    }
    
    var isClosable: Bool = false {
        didSet {
            guard isClosable else {
                closeBtn?.isHidden = true
                return
            }
            if closeBtn?.superview == nil {
                closeBtn = UIButton()
                closeBtn?.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
                closeBtn?.setImage(UIImage(named: "Cancel Invite"), for: .normal)
                addSubview(closeBtn!)
            }
            closeBtn?.isHidden = false
        }
    }
    
    private var closeBtn: UIButton?
    
    var disposeBag = DisposeBag()
    var avatarBtn = UIButton()
    var nicknameLab = UILabel()
    
    override func setupView() {
        nicknameLab.textAlignment = .center
        nicknameLab.font = UIFont.systemFont(ofSize: 10)
        nicknameLab.textColor = .black
        
        avatarBtn.imageView?.layer.cornerRadius = 25
        avatarBtn.imageView?.layer.masksToBounds = true
        addSubviews(nicknameLab, avatarBtn)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    @objc
    private func closeBtnAction() {
        closeSubject.onNext(())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarBtn.frame = CGRect(x: 5, y: 10, width: 50, height: 50)
        nicknameLab.frame = CGRect(x: 0, y: bounds.height - 12, width: bounds.width, height: 12)
        closeBtn?.frame = CGRect(x: avatarBtn.frame.maxX - 16, y: 6, width: 20, height: 20)
    }
}
