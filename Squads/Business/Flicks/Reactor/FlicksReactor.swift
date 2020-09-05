//
//  FlicksReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class FlicksReactor: Reactor {
    
    struct Model<T> {
        var data: T
        var totalHeight: CGFloat = 0
        var contentWidth: CGFloat = 0
    }
    
    enum Action {
        case refreshData(keyword: String)
        case loadData(keyword: String)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setToast(String)
        case setRepos(Array<Model<FlickModel>>, isRefresh: Bool)
    }
    
    struct State {
        var repos = Array<Model<FlickModel>>()
        var toast: String?
        var isLoading: Bool?
    }
    
    let squadId: Int
    var initialState = State()
    var provider = OnlineProvider<SquadAPI>()
    
    init(squadId: Int) {
        self.squadId = squadId
    }
    
    struct Paging {
        var size: Int = 10
        var index: Int = 1
        var total: Int = 0
        
        mutating func reset() {
            index = 1
            size = 10
        }
        
        mutating func nextPage() {
            index += 1
            size = 10
        }
    }
    
    private var paging = Paging()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refreshData(let keyword):
            self.paging.reset()
            return self.requestData(keyword: keyword, isRefresh: true)
        case .loadData(let keyword):
            self.paging.nextPage()
            return self.requestData(keyword: keyword, isRefresh: false)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let s):
            state.toast = nil
            state.isLoading = s
        case .setToast(let s):
            state.isLoading = false
            state.toast = s
        case .setRepos(let list, let isRefresh):
            state.isLoading = false
            if isRefresh {
                state.repos = list
            } else {
                state.repos += list
            }
        }
        return state
    }
    
    private func requestData(keyword: String, isRefresh: Bool) -> Observable<Mutation> {
        return provider.request(target: .getPageListWithFlick(squadId: squadId, pageIndex: self.paging.index, pageSize: self.paging.size, keyword: keyword), model: GeneralModel.List<FlickModel>.self, atKeyPath: .data)
        .asObservable()
        .map { [unowned self] result in
            switch result {
            case .success(let pagation):
                
                self.paging.index = pagation.pageIndex
                self.paging.size = pagation.pageSize
                self.paging.total = pagation.total
                
                return .setRepos(pagation.records.map{ (model) in
                    return Model(data: model,
                                 totalHeight: FlicksListViewCell.calcTotalHeight(pirtureNums: model.pirtureList.count),
                                 contentWidth: FlicksListViewCell.calcContentWidth(string: model.content))
                }, isRefresh: isRefresh)
            case .failure(let error):
                return .setToast(error.message)
            }
        }
        .startWith(.setLoading(true))
    }
}

