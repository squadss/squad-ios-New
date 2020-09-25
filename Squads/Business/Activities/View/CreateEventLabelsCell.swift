//
//  CreateEventLabelsCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/11.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateEventLabelsCell: BaseTableViewCell {
    
    var labels: CreateEventLabels? {
        didSet {
            guard let unwrappedLabels = labels else { return }
            for index in 0..<unwrappedLabels.list.count {
                let model = unwrappedLabels.list[index]
                if index < listView.count {
                    listView[index].isHidden = false
                    listView[index].setTitle(model.title, for: .normal)
                    listView[index].setTitleColor(model.themeColor, for: .normal)
                    listView[index].layer.borderColor = model.themeColor.cgColor
                }
                
                if model == unwrappedLabels.selected {
                    listView[index].isSelected = true
                    listView[index].backgroundColor = model.themeColor
                    listView[index].titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
                } else {
                    listView[index].isSelected = false
                    listView[index].backgroundColor = UIColor.white
                    listView[index].titleLabel?.font = UIFont.systemFont(ofSize: 14)
                }
            }
            
            if listView.count > unwrappedLabels.list.count {
                (0..<listView.count - unwrappedLabels.list.count).forEach { index in
                    listView[listView.count - index - 1].isHidden = true
                }
            }
        }
    }
    
    var disposeBag = DisposeBag()
    private var itemSubject = PublishSubject<EventCategory>()
    var itemTapped: Observable<EventCategory> {
        return itemSubject.asObservable()
    }
    
    private var listView = Array<UIButton>()
    
    override func setupView() {
        (0..<6).forEach { _ in
            let btn = UIButton()
            btn.isHidden = true
            btn.layer.borderWidth = 4
            btn.layer.cornerRadius = 16
            btn.setTitleColor(.white, for: .selected)
            btn.addTarget(self, action: #selector(btnDidTapped(sender:)), for: .touchUpInside)
            contentView.addSubview(btn)
            listView.append(btn)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    @objc
    private func btnDidTapped(sender: UIButton) {
        if sender.isSelected {
            return
        }
        for index in 0..<listView.count {
            let btn = listView[index]
            let isSelected = sender == btn
            sender.isSelected = isSelected
            if isSelected {
                itemSubject.onNext(labels!.list[index])
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let marginRight: CGFloat = 10
        let marginLeft: CGFloat = 33
        let marginTop: CGFloat = 12
        let marginBottom: CGFloat = 12
        let itemWidth: CGFloat = (contentView.bounds.width - marginRight * 2 - marginLeft * 2)/3
        
        for index in 0..<listView.count {
            let view = listView[index]
            let y = floor(CGFloat(index) / 3)
            let x = CGFloat(index % 3)
            view.frame = CGRect(x: x * (marginRight + itemWidth) + marginLeft,
                                y: y * (marginBottom + 32) + marginTop,
                                width: itemWidth,
                                height: 32)
        }
    }
}
