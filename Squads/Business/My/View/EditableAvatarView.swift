//
//  EditableAvatarView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/9.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditableAvatarView: BaseView {
    
    var imageTap: Observable<Void> {
        return imageBtn.rx.tap.asObservable()
    }
    
    var canEditTap: Observable<Void> {
        return canEditSubject.asObservable()
    }
    
    var imageURL: URL? {
        didSet {
            imageBtn.kf.setImage(with: imageURL, for: .normal, placeholder: placeholderImage)
        }
    }
    
    var canEdit: Bool = false {
        didSet {
            if canEdit {
                if canEditView?.superview == nil {
                    setupCanEditView()
                }
            } else {
                canEditView?.removeFromSuperview()
                canEditView = nil
            }
        }
    }
    
    var placeholderColor: UIColor = .white {
        didSet {
            placeholderImage = placeholderImage?.drawColor(placeholderColor)
        }
    }
    
    var imageSize = CGSize(width: 80, height: 80)
    
    override var frame: CGRect {
        didSet {
            imageBtn.frame = CGRect(x: (bounds.width - imageSize.width)/2, y: 0, width: imageSize.width, height: imageSize.height)
            canEditView?.frame = CGRect(x: imageBtn.frame.maxX - 32, y: imageBtn.frame.maxY - 29, width: 29, height: 29)
        }
    }
    
    private var canEditView: UIButton?
    private var imageBtn = CornersButton()
    private var placeholderImage = UIImage(named: "Avatar Placeholder")
    private var canEditSubject = PublishSubject<Void>()
    
    override func setupView() {
        addSubviews(imageBtn)
    }
    
    private func setupCanEditView() {
        canEditView = UIButton()
        canEditView?.setImage(UIImage(named: "Edit Group"), for: .normal)
        canEditView?.addTarget(self, action: #selector(canEditBtnDidTapped), for: .touchUpInside)
        addSubview(canEditView!)
    }
    
    @objc
    private func canEditBtnDidTapped() {
        canEditSubject.onNext(())
    }
    
}
