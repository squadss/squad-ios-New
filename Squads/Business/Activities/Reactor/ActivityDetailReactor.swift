//
//  ActivityDetailReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

enum ActivityStatus: Equatable {
    case create
    case start
    case running
    case completed
}

class ActivityDetailReactor: Reactor {
    
    enum ToolbarAction: String {
        case setTime
        case availabilityConfirm
        case availabilityCancel
        case goingConfirm
        case goingCancel
    }
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var activityStatus: ActivityStatus = .create
    }
    
    var initialState: State
    
    init() {
        initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
