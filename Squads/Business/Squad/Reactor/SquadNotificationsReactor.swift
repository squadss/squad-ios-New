//
//  SquadNotificationsReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class SquadNotificationsReactor: Reactor {
    
    enum Action {
        case updateSwitch(indexPath: IndexPath, isOn: Bool)
    }
    
    enum Mutation {
        
    }
    
    struct State {
        let repos: Array<[(String, Bool)]>
    }
    
    var initialState: State
    
    init() {
        initialState = State(repos: [[("Do Not Disturb", true)], [("Flicks", true), ("Activities", true), ("Channels", true)]])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        //TODO: 
        return .never()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}

