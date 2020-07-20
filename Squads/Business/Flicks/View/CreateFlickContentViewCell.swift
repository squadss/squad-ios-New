//
//  CreateFlickContentViewCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/20.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

class CreateFlickContentViewCell: BaseCollectionViewCell {
    
    var isClosable: Bool = true {
        didSet {
            guard isClosable != oldValue else { return }
            closeBtn.isHidden = !isClosable
        }
    }
    
    private var closeSubject = PublishSubject<Void>()
    var closeBtnDidTapped: Observable<Void> {
        return closeSubject.asObservable()
    }
    
    var pirtureView = UIButton()
    private var closeBtn = UIButton()
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func setupView() {
        
        closeBtn = UIButton()
        closeBtn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        closeBtn.setImage(UIImage(named: "Cancel Invite"), for: .normal)
        
        pirtureView.imageView?.contentMode = .scaleAspectFill
        pirtureView.layer.cornerRadius = 8
        pirtureView.layer.masksToBounds = true
        
        contentView.addSubviews(pirtureView, closeBtn)
    }
    
    @objc
    private func closeBtnAction() {
        closeSubject.onNext(())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pirtureView.frame = CGRect(x: 0, y: 15, width: bounds.width - 15, height: (bounds.width - 10) * 1.12)
        closeBtn.frame = CGRect(x: bounds.width - 40, y: 0, width: 40, height: 40)
    }
}
