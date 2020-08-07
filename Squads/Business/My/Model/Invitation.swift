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
        case doing = 1  //邀请中
        case failure = 3    //已拒绝
        case accepted = 2 //已接受
    }
    
    let id: Int
    var inviterAccountId: Int
    var inviterNickname: String
    var inviterHeadimgurl: String?
    
    var inviteeAccountId: Int
    var inviteeNickname: String
    var inviteeHeadimgurl: String?
    
    var inviteSquadId: Int
    var inviteSquadLogoPath: String?
    var inviteStatus: Status
}
