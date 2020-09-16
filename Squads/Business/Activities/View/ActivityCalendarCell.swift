//
//  ActivityCalendarCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/6.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ActivityCalendarCell: BaseTableViewCell {
    
    var pritureView = UIImageView()
    var dateLab = UILabel()
    var titleLab = UILabel()
    var contentLab = UILabel()
    
    // 日历
    var calendayView = ActivityCalendarView()
    
    // Suggested by Daniel
    var ownerLab = UILabel()
    // 成员列表
    var membersView = SquadMembersView()
    
    var containterView = ActivityShadowView()
    
    var disposeBag = DisposeBag()
    private var tapSubject = PublishSubject<Int>()
    var tapObservable: Observable<Int> {
        return tapSubject.asObservable()
    }
    
    // 表示状态的视图  ADD AVAILABILITY
    var statusView: UIButton!
    // 菜单按钮视图
    var menuView: UIStackView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func setupView() {
        
        dateLab.textColor = UIColor(red: 0.925, green: 0.384, blue: 0.337, alpha: 1)
        dateLab.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        
        titleLab.numberOfLines = 1
        titleLab.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLab.theme.textColor = UIColor.text
        
        contentLab.numberOfLines = 1
        contentLab.font = UIFont.systemFont(ofSize: 10)
        contentLab.theme.textColor = UIColor.textGray
        
        ownerLab.numberOfLines = 1
        ownerLab.font = UIFont.systemFont(ofSize: 10)
        ownerLab.theme.textColor = UIColor.textGray
        
        membersView.margin = 3
        membersView.memberWidth = 18
        
        containterView.contentView.addSubviews(membersView, ownerLab, contentLab, titleLab, dateLab, pritureView)
        contentView.addSubviews(calendayView, containterView)
        
        let imageNames = ["Activity Confirm Focus", "Activity Reject Focus"]
        let btnViews: [UIView] = imageNames.enumerated().map{ (arg) in
            let (index, name) = arg
            let btn = UIButton()
            btn.tag = 300 + index
            btn.setImage(UIImage(named: name)?.drawColor(UIColor(hexString: "#DADADA")), for: .normal)
            btn.setImage(UIImage(named: name)?.drawColor(UIColor(hexString: "#EF7C72")), for: .selected)
            btn.addTarget(self, action: #selector(menuBtnDidTapped(sender:)), for: .touchUpInside)
            return btn
        }
        menuView = UIStackView(arrangedSubviews: btnViews)
        menuView.axis = .horizontal
        menuView.distribution = .fillEqually
        menuView.alignment = .fill
        menuView.isHidden = true
        containterView.contentView.addSubview(menuView)
        
        statusView = UIButton()
        statusView.isHidden = true
        statusView.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        statusView.theme.titleColor(from: UIColor.text, for: .normal)
        statusView.contentHorizontalAlignment = .right
        containterView.contentView.addSubview(statusView)
        
        setupConstraint()
    }
    
    private func setupConstraint() {
        
        pritureView.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(dateLab.snp.top).offset(-6)
            maker.size.equalTo(CGSize(width: 30, height: 30))
            maker.leading.equalTo(dateLab)
        }
        
        dateLab.snp.makeConstraints { (maker) in
            maker.leading.equalTo(13)
        }
        
        titleLab.snp.makeConstraints { (maker) in
            maker.leading.equalTo(dateLab)
            maker.top.equalTo(dateLab.snp.bottom).offset(2)
        }
        
        contentLab.snp.makeConstraints { (maker) in
            maker.leading.equalTo(dateLab)
            maker.top.equalTo(titleLab.snp.bottom)
            maker.height.equalTo(12)
            maker.width.equalTo(150)
            maker.bottom.equalToSuperview().offset(-8)
        }
        
        membersView.snp.makeConstraints { (maker) in
            maker.trailing.equalToSuperview().offset(-14)
            maker.bottom.equalTo(contentLab)
        }
        
        ownerLab.snp.makeConstraints { (maker) in
            maker.trailing.equalTo(membersView)
            maker.bottom.equalTo(membersView.snp.top).offset(-5)
        }
    }
    
    @objc
    private func menuBtnDidTapped(sender: UIButton) {
        guard !sender.isSelected else { return }
        tapSubject.onNext(sender.tag - 300)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calendayView.frame = CGRect(x: 0, y: 0, width: 73, height: bounds.height - 2)
        containterView.frame = CGRect(x: calendayView.frame.maxX, y: 0, width: bounds.width - calendayView.frame.maxX, height: bounds.height - 2)
        menuView.frame = CGRect(x: containterView.contentView.frame.width - 90 - 10, y: 8, width: 90, height: 45)
        statusView.frame = CGRect(x: containterView.contentView.frame.width - 200 - 13, y: 14, width: 200, height: 14)
    }
}
