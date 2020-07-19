//
//  AvtivityTimeSettingView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/16.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AvtivityTimeSettingView: CornersView {

    // 已经响应的成员列表
    var respondedMembers: Array<URL>? {
        set { membersView.topList = newValue }
        get { membersView.topList }
    }
    
    // 等待响应的成员列表
    var waitingMembers: Array<URL>? {
        set { membersView.bottomList = newValue }
        get { membersView.bottomList }
    }
    
    // 时间刻度数据源
    var dataSource: SlidableTimeSectionModel? {
        didSet {
            guard let unwrappedDataSource = dataSource else { return }
            timeView.contentView.dataSource = [unwrappedDataSource]
        }
    }
    
    // 点击底部菜单的回调, 取消/确认
    var didTapped: Observable<String?> {
        let list: Array<Observable<String?>> = menuList.map{ btn in
            btn.rx.tap.map{
                btn.title(for: .normal)
            }}
        return Observable.from(list).merge()
    }
    
    private var timeView = SingleChooseTimeView()
    private var membersView = MembersGroupView()
    private let hLine = CALayer()
    private let vLine = UIView()
    private var stackView: UIStackView!
    private var menuList = [UIButton(), UIButton()]
    
    override func setupView() {
        
        membersView.topTitle = "RESPONDED"
        membersView.bottomTitle = "WAITING"
        
        vLine.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        hLine.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        
        menuList.first?.setTitle("Cancel", for: .normal)
        menuList.first?.setBackgroundImage(UIImage(color: .white), for: .normal)
        menuList.first?.setBackgroundImage(UIImage(color: UIColor(hexString: "#F1F1F1")), for: .highlighted)
        menuList.first?.setTitleColor(UIColor(red: 0, green: 0.478, blue: 1, alpha: 1), for: .normal)
        menuList.first?.setTitleColor(UIColor(red: 0.615, green: 0.791, blue: 0.983, alpha: 1), for: .disabled)
        menuList.first?.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        menuList.last?.setTitle("Set Time", for: .normal)
        menuList.last?.setBackgroundImage(UIImage(color: .white), for: .normal)
        menuList.last?.setBackgroundImage(UIImage(color: UIColor(hexString: "#F1F1F1")), for: .highlighted)
        menuList.last?.setTitleColor(UIColor(red: 0, green: 0.478, blue: 1, alpha: 1), for: .normal)
        menuList.last?.setTitleColor(UIColor(red: 0.615, green: 0.791, blue: 0.983, alpha: 1), for: .disabled)
        menuList.last?.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        stackView = UIStackView(arrangedSubviews: menuList)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        layer.addSublayer(hLine)
        addSubviews(timeView, membersView, stackView, vLine)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timeView.frame = CGRect(x: 10, y: 30, width: bounds.width - 56, height: 320)
        membersView.frame = CGRect(x: 14, y: timeView.frame.maxY, width: 300, height: 150)
        stackView.frame = CGRect(x: 0, y: bounds.height - 56, width: bounds.width, height: 56)
        hLine.frame = CGRect(x: 0, y: stackView.frame.minY - 0.5, width: bounds.width, height: 0.5)
        vLine.frame = CGRect(x: bounds.midX, y: hLine.frame.minY, width: 0.5, height: 56)
    }
}
