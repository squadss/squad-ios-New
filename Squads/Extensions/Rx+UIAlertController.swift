//
//  Rx+UIAlertController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

/**
 
 tableView.rx.itemDeleted
     .trackAlert(title: "确认要通知？",message: "详细信息", target: self)
     .subscribe(onNext: { [unowned self] indexPath in
         //TODO:
     })
     .disposed(by: disposeBag)
 
 */

// MARK: - UIAlertController
extension UIAlertController {
    
    public func addAction(actions: [RxAlertAction]) -> Observable<Int> {
        return Observable.create { [weak self] observer in
            actions.map { action in
                return UIAlertAction(title: action.title, style: action.style) { _ in
                    observer.onNext(action.type)
                    observer.onCompleted()
                }
                }.forEach { action in
                    self?.addAction(action)
            }
            
            return Disposables.create {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension UIViewController {
    public func alert(title: String?,
                      message: String? = nil,
                      actions: [RxAlertAction],
                      preferredStyle:UIAlertController.Style = .alert,
                      vc:UIViewController) -> Observable<Int> {
        
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        return actionSheet.addAction(actions: actions)
            .do(onSubscribed: {
                vc.present(actionSheet, animated: true, completion: nil)
            })
    }
    
    /// 确认弹框
    public func alertJustConfirm(title: String, cancel cancelTitle: String = "取消", default defaultTitle: String = "确定", target: UIViewController) -> Observable<Bool> {
        let cancelAction = RxAlertAction(title: cancelTitle, type: 0, style: .cancel)
        let confirmAction = RxAlertAction(title: defaultTitle, type: 1, style: .default)
        return alert(title: title, actions: [cancelAction, confirmAction], vc: target).map{ $0 == 1 }
    }
    
}

public struct RxAlertAction {
    
    public let title: String
    public let type: Int
    public let style: UIAlertAction.Style
    
    public init(title: String,
                type: Int,
                style: UIAlertAction.Style) {
        self.title = title
        self.type = type
        self.style = style
    }
}

extension ObservableType {
    
    func trackAlert(title: String?,
                    message: String? = nil,
                    cancel cancelTitle: String = "Cancel",
                    default defaultTitle: String = "Confirm",
                    target: UIViewController) -> Observable<Element> {
       
        return flatMap{ [weak target] element -> Observable<(Int, Element)> in
        
            let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let cancelAction = RxAlertAction(title: cancelTitle, type: 0, style: .cancel)
            let confirmAction = RxAlertAction(title: defaultTitle, type: 1, style: .default)
            
            return actionSheet
                .addAction(actions: [cancelAction, confirmAction])
                .map{ ($0, element) }
                .do(onSubscribed: {
                    target?.present(actionSheet, animated: true, completion: nil)
                })
            }
            .filter{ $0.0 == 1 }
            .map{ $0.1 }
    }
    
    func trackAlertJustConfirm(title: String?,
                    message: String? = nil,
                    default defaultTitle: String = "Confirm",
                    target: UIViewController) -> Observable<Element> {
       
        return flatMap{ [weak target] element -> Observable<(Int, Element)> in
        
            let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let confirmAction = RxAlertAction(title: defaultTitle, type: 1, style: .default)
            
            return actionSheet
                .addAction(actions: [confirmAction])
                .map{ ($0, element) }
                .do(onSubscribed: {
                    target?.present(actionSheet, animated: true, completion: nil)
                })
            }
            .map{ $0.1 }
    }
    
}
