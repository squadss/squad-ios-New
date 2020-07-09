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
    
    private var tapSubject = PublishSubject<Int>()
    var tapObservable: Observable<Int> {
        return tapSubject.asObservable()
    }
    
    // 表示状态的视图  ADD AVAILABILITY
    private var statusView: UIButton?
    // 菜单按钮视图
    private var menuView: UIStackView?
    
    override func setupView() {
        
        dateLab.textColor = UIColor(red: 0.925, green: 0.384, blue: 0.337, alpha: 1)
        dateLab.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        
        titleLab.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLab.theme.textColor = UIColor.text
        
        contentLab.font = UIFont.systemFont(ofSize: 12)
        contentLab.theme.textColor = UIColor.textGray
        
        ownerLab.font = UIFont.systemFont(ofSize: 9)
        ownerLab.theme.textColor = UIColor.textGray
        
        containterView.contentView.addSubviews(membersView, ownerLab, contentLab, titleLab, dateLab, pritureView)
        contentView.addSubviews(calendayView, containterView)
        
        pritureView.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(dateLab.snp.top).offset(-9)
            maker.size.equalTo(CGSize(width: 25, height: 25))
            maker.leading.equalTo(dateLab)
        }
        
        dateLab.snp.makeConstraints { (maker) in
            maker.leading.equalTo(13)
        }
        
        titleLab.snp.makeConstraints { (maker) in
            maker.leading.equalTo(dateLab)
            maker.top.equalTo(dateLab.snp.bottom)
        }
        
        contentLab.snp.makeConstraints { (maker) in
            maker.leading.equalTo(dateLab)
            maker.top.equalTo(titleLab.snp.bottom)
            maker.bottom.equalToSuperview().offset(-10)
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
    
    func setData(_ data: String) {
//        lazySetupMenuView()
        lazySetupStatusView()
    }
    
    // 构建操作面板视图
    private func lazySetupMenuView() {
        guard menuView?.superview == nil else { return }
        let imageNames = ["Activities Yes", "Activities No", "Activities Maybe"]
        let btnViews: [UIView] = imageNames.enumerated().map{ (arg) in
            let (index, name) = arg
            let btn = UIButton()
            btn.tag = 300 + index
            btn.setImage(UIImage(named: name), for: .normal)
            btn.addTarget(self, action: #selector(menuBtnDidTapped(sender:)), for: .touchUpInside)
            return btn
        }
        menuView = UIStackView(arrangedSubviews: btnViews)
        menuView?.axis = .horizontal
        menuView?.distribution = .fillEqually
        menuView?.alignment = .fill
        containterView.contentView.addSubview(menuView!)
    }
    
    // 构建状态视图
    private func lazySetupStatusView() {
        guard statusView?.superview == nil else { return }
        statusView = UIButton()
        statusView?.setTitle("ADD AVAILABILITY", for: .normal)
        statusView?.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        statusView?.setTitleColor(UIColor(red: 0.93, green: 0.38, blue: 0.34, alpha: 1.0), for: .normal)
        statusView?.contentHorizontalAlignment = .right
        containterView.contentView.addSubview(statusView!)
    }
    
    @objc
    private func menuBtnDidTapped(sender: UIButton) {
        tapSubject.onNext(sender.tag - 300)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calendayView.frame = CGRect(x: 0, y: 0, width: 73, height: bounds.height)
        containterView.frame = CGRect(x: calendayView.frame.maxX, y: 0, width: bounds.width - calendayView.frame.maxX, height: bounds.height)
        menuView?.frame = CGRect(x: containterView.contentView.frame.width - 90 - 10, y: 3, width: 90, height: 40)
        statusView?.frame = CGRect(x: containterView.contentView.frame.width - 200 - 13, y: 14, width: 200, height: 14)
    }
}
