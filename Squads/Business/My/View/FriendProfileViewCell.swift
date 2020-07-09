//
//  FriendProfileViewCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FriendProfileViewCell: BaseTableViewCell {
    
    var titleLab = UILabel()
    var contentLab = UILabel()
    
    var disposeBag = DisposeBag()
    var longObservable: Observable<Void> {
        return longGesture.rx.event
            .throttle(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .filter{ $0.state == .began }
            .map{ _ in () }
            .asObservable()
    }
    
    private var longGesture = UILongPressGestureRecognizer()
    
    override func setupView() {
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLab.theme.textColor = UIColor.secondary
        
        contentLab.font = UIFont.systemFont(ofSize: 14)
        contentLab.theme.textColor = UIColor.text
        
        contentView.addGestureRecognizer(longGesture)
        contentView.addSubviews(titleLab, contentLab)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentLab.frame = CGRect(x: 34, y: bounds.height - 17 - 12, width: 260, height: 17)
        titleLab.frame = CGRect(x: 34, y: contentLab.frame.minY - 17 - 14, width: 260, height: 17)
    }
}
