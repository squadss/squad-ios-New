//
//  UIButton+Loading.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/26.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIButton {
    
    var isLoading: Binder<Bool> {
        return Binder(base) { (view, state) in
            if state {
                view.startButtonActivityIndicatorView()
            } else {
                view.endButtonActivityIndicatorView()
            }
        }
    }
    
}

extension UIButton {
    
    static let tag: Int = 999
    
    func startButtonActivityIndicatorView(indicatorViewSize: CGFloat = 20) {
        
        guard let font = titleLabel?.font, let title = currentTitle, isEnabled else { return }
        
        backgroundColor = backgroundColor?.withAlphaComponent(0.4)
        isEnabled = false
        
        let indicatorView = UIActivityIndicatorView(style: .gray)
        
        let rect = NSString(string: title).boundingRect(with: bounds.size,
                                                                options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                                attributes: [.font: font],
                                                                context: nil)
        
        indicatorView.frame = CGRect(x: (bounds.width - rect.width)/2 - indicatorViewSize - 5,
                                     y: (bounds.height - indicatorViewSize)/2,
                                     width: indicatorViewSize, height: indicatorViewSize)
        indicatorView.tag = UIButton.tag
        indicatorView.hidesWhenStopped = true
        addSubview(indicatorView)
        indicatorView.startAnimating()
    }
    
    func endButtonActivityIndicatorView() {
        guard !isEnabled else { return }
        
        let indicatorView = viewWithTag(UIButton.tag)
        indicatorView?.removeFromSuperview()
        
        isEnabled = true
        backgroundColor = backgroundColor?.withAlphaComponent(0.4 * (5/2))
    }
}
