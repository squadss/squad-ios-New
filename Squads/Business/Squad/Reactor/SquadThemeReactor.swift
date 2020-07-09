//
//  SquadThemeReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class SquadThemeReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        let repos: Array<String>
    }
    
    var initialState: State
    
    init() {
        initialState = State(repos: ["MEMBERS", "NOTIFICATIONS", "CUSTOMIZE THEME", "INVITH NEW"])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}

