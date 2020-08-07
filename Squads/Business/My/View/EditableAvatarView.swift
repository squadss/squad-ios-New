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
    
    private var canEditSubject = PublishSubject<Void>()
    var canEditTap: Observable<Void> {
        return canEditSubject.asObservable()
    }
    
    private var placeholderImage = UIImage(named: "Avatar Placeholder")
    var placeholderColor: UIColor = .white {
        didSet { placeholderImage = placeholderImage?.drawColor(placeholderColor) }
    }
    
    var imageSize = CGSize(width: 80, height: 80)
    
    var imageURL: URL? {
        didSet { imageBtn.kf.setImage(with: imageURL, for: .normal, placeholder: placeholderImage) }
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
    
    var imageBtn = CornersButton()
    private var canEditView: UIButton?
    
    override func setupView() {
        imageBtn.clipsToBounds = true
        addSubviews(imageBtn)
    }
    
    private func setupCanEditView() {
        canEditView = UIButton()
        canEditView?.setImage(UIImage(named: "Edit Group"), for: .normal)
        canEditView?.addTarget(self, action: #selector(canEditBtnDidTapped), for: .touchUpInside)
        imageBtn.setImage(placeholderImage, for: .normal)
        addSubview(canEditView!)
    }
    
    @objc
    private func canEditBtnDidTapped() {
        canEditSubject.onNext(())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageBtn.frame = CGRect(x: (bounds.width - imageSize.width)/2, y: 0, width: imageSize.width, height: imageSize.height)
        canEditView?.frame = CGRect(x: imageBtn.frame.maxX - 32, y: imageBtn.frame.maxY - 29, width: 29, height: 29)
    }
}
