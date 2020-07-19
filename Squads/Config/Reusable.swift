//
//  Reusable.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReusableKit

enum Reusable {
    
    static let squadFickerCell = ReusableCell<SquadFickerCell>()
    
    static let squadActivityCell = ReusableCell<SquadActivityCell>()
    
    static let squadChannelsCell = ReusableCell<SquadChannelsCell>()
    
    static let squadPlaceholderCell = ReusableCell<SquadPlaceholderCell>()
    
    static let squadSqrollCell = ReusableCell<SquadSqrollViewCell>()
    
    static let squadSqrollCollectionCell = ReusableCell<SquadSqrollCollectionCell>()
    
    static let squadPreViewCell = ReusableCell<SquadPreViewCell>()
    
    static let squadNotificationsViewCell = ReusableCell<SquadNotificationsViewCell>()
    
    static let activityCalendarCell = ReusableCell<ActivityCalendarCell>()
    static let createEventTextEditedCell = ReusableCell<CreateEventTextEditedCell>()
    static let createEventLabelsCell = ReusableCell<CreateEventLabelsCell>()
    static let createEventCalendarCell = ReusableCell<CreateEventCalendarCell>()
    static let createEventAvailabilityCell = ReusableCell<CreateEventAvailabilityCell>()
    
    //MARK: - My
    static let friendProfileViewCell = ReusableCell<FriendProfileViewCell>()
    
    static let mySquadsViewCell = ReusableCell<MySquadsViewCell>()
    
    static let applyListViewCell = ReusableCell<ApplyListViewCell>()
}
