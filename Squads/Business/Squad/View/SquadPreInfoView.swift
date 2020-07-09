//
//  SquadPreInfoView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SquadPreInfoView: BaseView {
    
    var imageTap: Observable<Void> {
        return imageBtn.rx.tap.asObservable()
    }
    
    var canEditTap: Observable<Void> {
        return canEditSubject.asObservable()
    }
    
    var imageURL: URL? {
        didSet {
            imageBtn.kf.setImage(with: imageURL, for: .normal)
        }
    }
    
    var title: String? {
        didSet {
            titleLab.text = title
        }
    }
    
    var dateString: String? {
        didSet {
            dateLab.text = dateString
        }
    }
    
    private var imageBtn = UIButton()
    private var titleLab = UILabel()
    private var dateLab = UILabel()
    private var canEditSubject = PublishSubject<Void>()
    
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
    
    private var canEditView: UIButton?
    
    override func setupView() {
        
        imageBtn.layer.maskCorners(105.0/2, rect: CGRect(x: 0, y: 0, width: 105, height: 105))
        imageBtn.clipsToBounds = true
        
        titleLab.textAlignment = .center
        titleLab.theme.textColor = UIColor.text
        titleLab.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        dateLab.textAlignment = .center
        dateLab.theme.textColor = UIColor.text
        dateLab.font = UIFont.systemFont(ofSize: 12)
        
        addSubviews(imageBtn, titleLab, dateLab)
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
        imageBtn.frame = CGRect(x: (bounds.width - 105)/2, y: 0, width: 105, height: 105)
        titleLab.frame = CGRect(x: (bounds.width - 200)/2, y: imageBtn.frame.maxY + 15, width: 200, height: 24)
        dateLab.frame = CGRect(x: (bounds.width - 200)/2, y: titleLab.frame.maxY + 8, width: 200, height: 14)
        canEditView?.frame = CGRect(x: imageBtn.frame.maxX - 32, y: imageBtn.frame.maxY - 29, width: 29, height: 29)
    }
}
