//
//  SquadReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

protocol SquadPrimaryKey { }

struct SquadSqroll: SquadPrimaryKey {
    var list: Array<String>
}

struct SquadChannel: SquadPrimaryKey {
    let sessionId: String
    var avatar: String?
    var title: String = ""
    var content: String = ""
    var unreadCount: Int = 0
    var dateString: String = ""
}

struct SquadActivity: SquadPrimaryKey {
    
}

struct SquadPlaceholder: SquadPrimaryKey {
    let content: String = "No activities currently planned. Create one!"
}

class SquadReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var repos = Array<Array<SquadPrimaryKey>>(repeating: [], count: 3)
    }
    
    var initialState: State
    
    init() {
        initialState = State()
        
        initialState.repos[0] = [SquadSqroll(list: ["http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg","http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg", "http://image.biaobaiju.com/uploads/20180803/23/1533309822-GCcDphRmqw.jpg"])]
        initialState.repos[1] = [SquadActivity(), SquadActivity()]
        initialState.repos[2] = [SquadChannel(sessionId: "1", avatar: "http://image.biaobaiju.com/uploads/20180803/23/1533309822-GCcDphRmqw.jpg", title: "Main", content: "Danny: Yeah I Know", unreadCount: 1, dateString: "10:10 PM"),
                                 SquadChannel(sessionId: "1", avatar: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg", title: "Main", content: "Danny: Yeah I Know", unreadCount: 1, dateString: "10:10 PM")]
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
