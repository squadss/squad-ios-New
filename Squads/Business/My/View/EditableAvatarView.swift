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
    
    var imageBtnTap: Observable<Void> {
        return imageBtn.rx.tap.asObservable()
    }
    
    private(set) var placeholderImage = UIImage(named: "Avatar Placeholder")
    var placeholderColor: UIColor = .white {
        didSet { placeholderImage = placeholderImage?.drawColor(placeholderColor) }
    }
    
    var imageSize = CGSize(width: 80, height: 80)
    
    var canEdit: Bool = false {
        didSet {
            if canEdit {
                if canEditView?.superview == nil {
                    setupCanEditView()
                }
                canEditView?.isHidden = false
            } else {
                canEditView?.isHidden = true
            }
        }
    }
    
    fileprivate var imageBtn = CornersButton()
    fileprivate var canEditView: UIButton?
    
    override func setupView() {
        imageBtn.adjustsImageWhenHighlighted = false
        imageBtn.clipsToBounds = true
        imageBtn.imageView?.contentMode = .scaleAspectFill
        imageBtn.setImage(placeholderImage, for: .normal)
        addSubviews(imageBtn)
    }
    
    func image(for state: UIControl.State = .normal) -> UIImage? {
        if imageBtn.isSelected == (state == .selected) {
            return imageBtn.image(for: state)
        } else{
            return nil
        }
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageBtn.frame = CGRect(x: (bounds.width - imageSize.width)/2, y: 0, width: imageSize.width, height: imageSize.height)
        canEditView?.frame = CGRect(x: imageBtn.frame.maxX - 32, y: imageBtn.frame.maxY - 29, width: 29, height: 29)
    }
}

extension Reactive where Base == EditableAvatarView {
    
    func setImage(for state: UIControl.State = .normal) -> Binder<URL?> {
        return Binder(self.base, binding: { (view, url) in
            view.imageBtn.kf.setImage(with: url, for: state, placeholder: view.placeholderImage, options: [.keepCurrentImageWhileLoading])
            view.imageBtn.isSelected = state == .selected
        })
    }
    
    func setImage(for state: UIControl.State = .normal) -> Binder<UIImage?> {
        return Binder(self.base, binding: { (view, image) in
            view.imageBtn.isSelected = state == .selected
            view.imageBtn.setImage(image, for: state)
        })
    }
    
    var canEdit: Binder<Bool> {
        return Binder(self.base, binding: { (view, state) in
            view.canEdit = state
        })
    }
}
