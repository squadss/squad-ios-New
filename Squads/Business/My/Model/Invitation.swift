//
//  Invitation.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation

struct Invitation : Codable {
    
    enum Status: Int, Codable {
        case doing = 1      //邀请中
        case failure = 3    //已拒绝
        case accepted = 2   //已接受
    }
    
    let id: Int
    
    // 邀请者
    var inviterAccountId: Int
    var inviterNickname: String
    var inviterHeadimgurl: String?
    
    // 被邀请者
    var inviteeAccountId: Int
    var inviteeNickname: String
    var inviteeHeadimgurl: String?
    
    // squad信息
    var inviteSquadId: Int
    var inviteSquadLogoPath: String?
    var inviteStatus: Status
    var inviteSquadName: String
}
