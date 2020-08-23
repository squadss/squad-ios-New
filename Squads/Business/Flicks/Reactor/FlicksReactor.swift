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
        case setRepos(Array<Model<FlickModel>>)
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
    
    private var pageIndex: Int = 1
    private var pageSize: Int = 10
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refreshData(let keyword):
            self.pageIndex = 1
            self.pageSize = 10
            return self.requestData(keyword: keyword)
        case .loadData(let keyword):
            return self.requestData(keyword: keyword)
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
        case .setRepos(let list):
            state.isLoading = false
            state.repos = list
        }
        return state
    }
    
    private func requestData(keyword: String) -> Observable<Mutation> {
        return provider.request(target: .getPageListWithFlick(pageIndex: pageIndex, pageSize: pageSize, keyword: keyword), model: GeneralModel.List<FlickModel>.self, atKeyPath: .data)
        .asObservable()
        .map { [unowned self] result in
            switch result {
            case .success(let pagation):
                self.pageIndex = pagation.pageIndex
                self.pageSize = pagation.pageSize
                return .setRepos(pagation.records.map{ (model) in
                    return Model(data: model,
                                 totalHeight: FlicksListViewCell.calcTotalHeight(pirtureNums: model.pirtureList.count),
                                 contentWidth: FlicksListViewCell.calcContentWidth(string: model.content))
                })
            case .failure(let error):
                return .setToast(error.message)
            }
        }
        .startWith(.setLoading(true))
    }
}

