//
//  MembersGroupView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/16.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class MembersGroupView: BaseView {

    var topTitle: String? {
        didSet {
            topLab.text = topTitle
        }
    }
    var topList: Array<URL>? {
        didSet {
            guard let list = topList else { return }
            topMemberView.members = list
        }
    }
    var bottomTitle: String? {
       didSet {
           bottomLab.text = bottomTitle
       }
   }
    var bottomList: Array<URL>?{
        didSet {
            guard let list = bottomList else { return }
            bottomMembersView.members = list
        }
    }
    private var topLab = UILabel()
    private var topMemberView = SquadMembersView()
    private var bottomLab = UILabel()
    private var bottomMembersView = SquadMembersView()
    
    override func setupView() {
        
        topLab.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        topLab.theme.textColor = UIColor.textGray
        
        bottomLab.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        bottomLab.theme.textColor = UIColor.textGray
        
        topMemberView.margin = 6
        topMemberView.memberWidth = 27
        bottomMembersView.margin = 6
        bottomMembersView.memberWidth = 27
        addSubviews(topLab, topMemberView, bottomLab, bottomMembersView)
        
        topLab.snp.makeConstraints { (maker) in
            maker.leading.top.equalToSuperview()
            maker.height.equalTo(14)
        }
        
        topMemberView.snp.makeConstraints { (maker) in
            maker.leading.equalTo(topLab)
            maker.top.equalTo(topLab.snp.bottom).offset(8)
        }
        
        bottomLab.snp.makeConstraints { (maker) in
            maker.leading.equalToSuperview()
            maker.top.equalTo(topMemberView.snp.bottom).offset(16)
            maker.height.equalTo(14)
        }
        
        bottomMembersView.snp.makeConstraints { (maker) in
            maker.leading.equalToSuperview()
            maker.top.equalTo(bottomLab.snp.bottom).offset(8)
        }
    }
}
