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
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var repos: Array<Model<FlickModel>>
    }
    
    var initialState: State
    
    init() {
        
        let list = [
            FlickModel(pirtureList: [URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!], content: "哈哈哈, 你说呢", dateString: "May 2020", likeNum: "5", commonNum: "6"),
            FlickModel(pirtureList: [URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!], content: "哈哈哈, 你说呢", dateString: "May 2020", likeNum: "5", commonNum: "6"),
            FlickModel(pirtureList: [URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!], content: "哈哈哈, 你说呢", dateString: "May 2020", likeNum: "5", commonNum: "6"),
            FlickModel(pirtureList: [URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!], content: "哈哈哈, 你说呢", dateString: "May 2020", likeNum: "5", commonNum: "6"),
            FlickModel(pirtureList: [URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!], content: "哈哈哈, 你说呢", dateString: "May 2020", likeNum: "5", commonNum: "6"),
            FlickModel(pirtureList: [URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!, URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!], content: "哈哈哈, 你说呢", dateString: "May 2020", likeNum: "5", commonNum: "6"),
            FlickModel(pirtureList: [URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg")!], content: "哈哈哈, 你说呢", dateString: "May 2020", likeNum: "5", commonNum: "6")]
        
        initialState = State(repos: list.map({ (model) in
            return Model(data: model,
                         totalHeight: FlicksListViewCell.calcTotalHeight(pirtureNums: model.pirtureList.count),
                         contentWidth: FlicksListViewCell.calcContentWidth(string: model.content))
        }))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}

