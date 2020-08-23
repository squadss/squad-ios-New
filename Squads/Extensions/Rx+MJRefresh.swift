//
//  Rx+MJRefresh.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/10.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MJRefresh

/*
 
 let footer = MJRefreshBackStateFooter()
 footer.stateLabel.isHidden = true
 footer.isAutomaticallyChangeAlpha = true
 footer.mj_h = 30
 
 let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
 view.mj_footer = footer
 
 */

extension Reactive where Base: MJRefreshComponent {
    
    var loading: Observable<Void> {
        return Observable<Void>.create({ [weak control = self.base] observer in
            
            if let control = control {
                control.refreshingBlock = {
                    observer.on(.next(()))
                }
            }
            
            return Disposables.create()
        })
    }
}

extension Reactive where Base: MJRefreshFooter {
    
    /// 提示没有更多的数据
    var endRefreshingWithNoMoreData: Binder<Bool> {
        return Binder(base) { refresh, isEnd in
            if isEnd {
                refresh.endRefreshingWithNoMoreData()
            }
            else {
                refresh.endRefreshing()
            }
        }
    }
    
    /// 重置没有更多的数据（消除没有更多数据的状态）
    var resetNoMoreData: Binder<Bool> {
        return Binder(base) { refresh, state in
            if state {
                refresh.resetNoMoreData()
            }
        }
    }
    
}
