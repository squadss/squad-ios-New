//
//  MembersGroupView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/16.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol MembersItemProtocol {
    var url: URL? { get }
}

struct MembersSection<T: MembersItemProtocol> {
    var title: String
    var list: Array<T>
}

class MembersGroupView<T: MembersItemProtocol>: BaseView {

    var topSection: MembersSection<T>! {
        didSet {
            topLab.text = topSection.title
            topMemberView.members = topSection.list
        }
    }
    
    var bottomSection: MembersSection<T>! {
        didSet {
            bottomLab.text = bottomSection.title
            bottomMembersView.members = bottomSection.list
        }
    }
    
    private var topLab = UILabel()
    private var topMemberView = SquadMembersView<T>()
    private var bottomLab = UILabel()
    private var bottomMembersView = SquadMembersView<T>()
    
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

extension Reactive where Base: MembersGroupView<ActivityMember> {
    
    var topSection: Binder<MembersSection<ActivityMember>> {
        return Binder(base) { refresh, model in
            refresh.topSection = model
        }
    }
    
    var bottomSection: Binder<MembersSection<ActivityMember>> {
        return Binder(base) { refresh, model in
            refresh.bottomSection = model
        }
    }
    
}
