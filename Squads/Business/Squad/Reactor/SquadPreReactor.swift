//
//  SquadPreReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class SquadPreReactor: Reactor {
    
    struct Model {
        let title: String
        var isHight: Bool = false
    }
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        let repos: Array<Model>
    }
    
    var initialState: State
    let squadId: String
    init(squadId: String) {
        self.squadId = squadId
        initialState = State(repos: [Model(title: "MEMBERS"),
                                     Model(title: "NOTIFICATIONS"),
                                     Model(title: "CUSTOMIZE THEME"),
                                     Model(title: "INVITH NEW"),
                                     Model(title: "LEAVE SQUAD", isHight: true)])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}

