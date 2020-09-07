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
import SwiftPullToRefresh
//import MJRefresh

/*
 
 let footer = MJRefreshBackStateFooter()
 footer.stateLabel.isHidden = true
 footer.isAutomaticallyChangeAlpha = true
 footer.mj_h = 30
 
 let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
 view.mj_footer = footer
 
 */

//extension Reactive where Base: MJRefreshComponent {
    
//    var refresh: Observable<Void> {
//        return Observable<Void>.create({ [weak control = self.base] observer in
//
//            if let control = control {
//                control.refreshingBlock = {
//                    observer.on(.next(()))
//                }
//            }
//
//            return Disposables.create()
//        })
//    }
    
//    var loading: Binder<Bool> {
//        return Binder(base) { refresh, state in
//            if state {
//                refresh.beginRefreshing()
//            } else {
//                refresh.endRefreshing()
//            }
//        }
//    }
//}

extension Reactive where Base: UITableView {
    
    var autoFooter: Observable<Void> {
        return Observable.create { [weak component = self.base](observer) -> Disposable in
            component?.spr_setTextAutoFooter {
                observer.onNext(())
            }
            return Disposables.create()
        }
    }
    
}
//
//extension Reactive where Base: MJRefreshFooter {
//    
//    /// 提示没有更多的数据
//    var endRefreshingWithNoMoreData: Binder<Bool> {
//        return Binder(base) { refresh, isEnd in
//            if isEnd {
//                refresh.endRefreshingWithNoMoreData()
//            }
//            else {
//                refresh.endRefreshing()
//            }
//        }
//    }
//    
//    /// 重置没有更多的数据（消除没有更多数据的状态）
//    var resetNoMoreData: Binder<Bool> {
//        return Binder(base) { refresh, state in
//            if state {
//                refresh.resetNoMoreData()
//            }
//        }
//    }
//    
//}
//
//class Target: NSObject, Disposable {
//    private var retainSelf: Target?
//    override init() {
//        super.init()
//        self.retainSelf = self
//    }
//    func dispose() {
//        self.retainSelf = nil
//    }
//}
//
//class MJRefreshTarget<Component: MJRefreshComponent>: Target {
//    
//    weak var component: Component?
//    let refreshingBlack: MJRefreshComponentAction
//    
//    init(_ component: Component, refreshingBlack: @escaping MJRefreshComponentAction) {
//        self.refreshingBlack = refreshingBlack
//        self.component = component
//        super.init()
//        component.setRefreshingTarget(self, refreshingAction: #selector(onRefreshing))
//    }
//    
//    @objc
//    private func onRefreshing() {
//        refreshingBlack()
//    }
//    
//    override func dispose() {
//        super.dispose()
//        self.component?.refreshingBlock = nil
//    }
//}
//
//extension Reactive where Base: MJRefreshComponent {
//    
//    var refresh: ControlProperty<MJRefreshState> {
//        let source: Observable<MJRefreshState> = Observable.create{ [weak component = self.base] observer in
//            MainScheduler.ensureExecutingOnScheduler()
//            guard let component = component else {
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            observer.onNext(component.state)
//            let observer = MJRefreshTarget(component) {
//                observer.onNext(component.state)
//            }
//            return observer
//        }.takeUntil(deallocated)
//        
//        let bindingObserver = Binder<MJRefreshState>(base) { (component, state) in
//            component.state = state
//        }
//        return ControlProperty(values: source, valueSink: bindingObserver)
//    }
//    
//}
