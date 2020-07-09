//
//  FriendProfileReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class FriendProfileReactor: Reactor {
    
    struct Model {
        var title: String
        var content: String
    }
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var repos = Array<Model>()
    }
    
    var initialState: State
    
    init() {
        initialState = State()
        
        initialState.repos.append(Model(title: "NAME", content: "John Smith"))
        initialState.repos.append(Model(title: "USER", content: "@johnsmith"))
        initialState.repos.append(Model(title: "PHONE", content: "888 888 8888"))
        initialState.repos.append(Model(title: "BIRTHDAY", content: "John 9,1999"))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
