//
//  Rx+HGPlaceholders.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/4.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HGPlaceholders

/**
 //  点击重试按钮
 collection.rx.actionButtonTapped
     .subscribe(onNext: {
         print($0)
     })
     .disposed(by: rx.disposeBag)
 
 // 网络请求绑定视图的占位图
 provider
     .request(target: .login, model: String.self, atKeyPath: .data)
     .asObservable()
     .debug()
     .compactMap{ $0.error }
     .bind(to: collection.rx.placeholder)
     .disposed(by: rx.disposeBag)
 
 */

enum EmptySet {
    // 内容空白
    case empty
    // 发送错误
    case error
    //  没有连接网络
    case noConnection
}

protocol ReactivePlaceholder: class {
    func showErrorPlaceholder()
    func showNoConnectionPlaceholder()
    func showDefault()
}

extension CollectionView: ReactivePlaceholder { }
extension TableView: ReactivePlaceholder {}

extension Reactive where Base: ReactivePlaceholder {
    var placeholder: Binder<GeneralError> {
        return Binder<GeneralError>(self.base){ view, error in
            switch error {
            case .newwork, .unknown, .mapping:
                view.showErrorPlaceholder()
            case .noConnection:
                view.showNoConnectionPlaceholder()
            case .custom, .loginStatusDidExpired:
                view.showDefault()
            }
        }
    }
}

class RxTableViewPlaceholderDelegateProxy: DelegateProxy<TableView, PlaceholderDelegate>, DelegateProxyType, PlaceholderDelegate {
    
    var tapObservable = PublishSubject<EmptySet>()
    
    init(view: TableView) {
        super.init(parentObject: view, delegateProxy: RxTableViewPlaceholderDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register(make: { RxTableViewPlaceholderDelegateProxy(view: $0) })
    }
    
    func view(_ view: Any, actionButtonTappedFor placeholder: HGPlaceholders.Placeholder) {
        switch placeholder.key {
        case .errorKey:
            tapObservable.onNext(.error)
        case .loadingKey:
            tapObservable.onNext(.empty)
        case .noConnectionKey:
            tapObservable.onNext(.noConnection)
        case .noResultsKey:
            tapObservable.onNext(.empty)
        default:
            tapObservable.onNext(.error)
        }
    }
    
    deinit {
        tapObservable.onCompleted()
    }
    
    static func currentDelegate(for object: TableView) -> PlaceholderDelegate? {
        return object.placeholderDelegate
    }
    
    static func setCurrentDelegate(_ delegate: PlaceholderDelegate?, to object: TableView) {
        object.placeholderDelegate = delegate
    }
}

class RxCollectionViewPlaceholderDelegateProxy: DelegateProxy<CollectionView, PlaceholderDelegate>, DelegateProxyType, PlaceholderDelegate {
    
    var tapObservable = PublishSubject<EmptySet>()
    
    init(view: CollectionView) {
        super.init(parentObject: view, delegateProxy: RxCollectionViewPlaceholderDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register(make: { RxCollectionViewPlaceholderDelegateProxy(view: $0) })
    }
    
    func view(_ view: Any, actionButtonTappedFor placeholder: HGPlaceholders.Placeholder) {
        switch placeholder.key {
        case .errorKey:
            tapObservable.onNext(.error)
        case .loadingKey:
            tapObservable.onNext(.empty)
        case .noConnectionKey:
            tapObservable.onNext(.noConnection)
        case .noResultsKey:
            tapObservable.onNext(.empty)
        default:
            tapObservable.onNext(.error)
        }
    }
    
    deinit {
        tapObservable.onCompleted()
    }
    
    static func currentDelegate(for object: CollectionView) -> PlaceholderDelegate? {
        return object.placeholderDelegate
    }
    
    static func setCurrentDelegate(_ delegate: PlaceholderDelegate?, to object: CollectionView) {
        object.placeholderDelegate = delegate
    }
}

extension Reactive where Base: TableView {
    var actionButtonTapped: Observable<EmptySet> {
        return RxTableViewPlaceholderDelegateProxy.proxy(for: base).tapObservable.asObservable()
    }
}

extension Reactive where Base: CollectionView {
    var actionButtonTapped: Observable<EmptySet> {
        return RxCollectionViewPlaceholderDelegateProxy.proxy(for: base).tapObservable.asObservable()
    }
}
