//
//  ChattingReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class ChattingReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    let needCreateSession: Bool
    var initialState: State
    
    
    /// 构造方法
    /// - Parameter needCreateSession: 是否需要创建会话
    init(needCreateSession: Bool = false) {
        initialState = State()
        self.needCreateSession = needCreateSession
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
