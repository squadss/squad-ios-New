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
        case loadData(keyword: String, isRefresh: Bool)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setToast(String)
        case setRepos(Array<Model<FlickModel>>, isRefresh: Bool, isExistMoreData: Bool)
    }
    
    struct State {
        var repos = Array<Model<FlickModel>>()
        var toast: String?
        var isLoading: Bool?
        var isExistMoreData: Bool = true
    }
    
    let squadId: Int
    var initialState = State()
    var provider = OnlineProvider<SquadAPI>()
    
    init(squadId: Int) {
        self.squadId = squadId
    }
    
    struct Paging {
        let size: Int = 10
        var index: Int = 1
        var total: Int = 0
        
        mutating func reset() {
            index = 1
        }
        
        mutating func nextPage() {
            index += 1
        }
    }
    
    private var paging = Paging()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData(let keyword, let isRefresh):
            
            if isRefresh { self.paging.reset() }
            
            let api: SquadAPI = .getPageListWithFlick(squadId: squadId,
                                                      pageIndex: self.paging.index,
                                                      pageSize: self.paging.size,
                                                      keyword: keyword)
            return provider
                .request(target: api, model: GeneralModel.List<FlickModel>.self, atKeyPath: .data)
                .asObservable()
                .map { [unowned self] result in
                    switch result {
                    case .success(let pagation):
                        
                        // 服务器的 pagation.pageIndex是我传过去的值, 不能依靠这个计算
                        self.paging.total = pagation.total
                        if pagation.canLoadNext {
                            self.paging.nextPage()
                        }
                        
                        return .setRepos(pagation.records.map{ (model) in
                            let height = FlicksListViewCell.calcTotalHeight(pirtureNums: model.pirtureList.count)
                            let width = FlicksListViewCell.calcContentWidth(string: model.content)
                            return Model(data: model, totalHeight: height, contentWidth: width)
                        }, isRefresh: isRefresh, isExistMoreData: pagation.existMore)
                    case .failure(let error):
                        return .setToast(error.message)
                    }
                }
                .startWith(.setLoading(true))
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
        case .setRepos(let list, let isRefresh, let isExistMoreData):
            state.isLoading = false
            state.isExistMoreData = isExistMoreData
            if isRefresh {
                state.repos = list
            } else {
                state.repos += list
            }
        }
        return state
    }
}

