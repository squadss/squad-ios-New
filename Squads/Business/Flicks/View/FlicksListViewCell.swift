//
//  FlicksListViewCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/19.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FlicksListViewCell: BaseTableViewCell {
    
    var contentWidth: CGFloat = 0
    
    var pirtureList: Array<URL>! {
        didSet {
            for i in 0..<listView.count {
                let imageView = listView[i]
                if i < pirtureList.count {
                    let url = pirtureList[i]
                    imageView.kf.setImage(with: url, for: .normal)
                    imageView.isHidden = false
                } else {
                    imageView.isHidden = true
                }
            }
            setNeedsLayout()
        }
    }
    
    var disposeBag = DisposeBag()
    private var pirtureDidTappedSubject = PublishSubject<Int>()
    var pirtureDidTapped: Observable<Int> {
        return pirtureDidTappedSubject.asObservable()
    }
    
    var contentLab = UILabel()
    var dateBtn = UIButton()
    
    var likeBtn = UIButton()
    var commonBtn = UIButton()
    
    static let font = UIFont.systemFont(ofSize: 14, weight: .bold)
    static let insert = UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18)
    static let margin: CGFloat = 6
    static let itemWidth: CGFloat = (UIScreen.main.bounds.width - 2 * margin - insert.left - insert.right)/3
    
    private var stackView: UIStackView!
    private var listView = Array<UIButton>()
    
    override func setupView() {
        
        for i in 0..<9 {
            let imageView = UIButton()
            imageView.isHidden = true
            imageView.imageView?.layer.cornerRadius = 8
            imageView.imageView?.layer.masksToBounds = true
            imageView.imageView?.contentMode = .scaleAspectFill
            imageView.tag = i + 200
            imageView.addTarget(self, action: #selector(pritureBtnDidTapped(sender:)), for: .touchUpInside)
            contentView.addSubview(imageView)
            listView.append(imageView)
        }
        
        likeBtn.setImage(UIImage(named: "Flicks Like"), for: .normal)
        likeBtn.theme.titleColor(from: UIColor.text, for: .normal)
        likeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        likeBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -5)
        
        commonBtn.setImage(UIImage(named: "Flicks Common"), for: .normal)
        commonBtn.theme.titleColor(from: UIColor.text, for: .normal)
        commonBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        commonBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -5)
        
        stackView = UIStackView(arrangedSubviews: [likeBtn, commonBtn])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 5
        //FIXME: - 这一版没有加喜欢/评论的功能, 暂时隐藏
        stackView.isHidden = true
        
        contentLab.font = FlicksListViewCell.font
        contentLab.theme.textColor = UIColor.text
        contentLab.numberOfLines = 1
        
        dateBtn.isEnabled = false
        dateBtn.setImage(UIImage(named: "Flicks Dot"), for: .normal)
        dateBtn.theme.titleColor(from: UIColor.textGray, for: .normal)
        dateBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        dateBtn.contentHorizontalAlignment = .left
        dateBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        
        contentView.addSubviews(contentLab, dateBtn, stackView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let insert = FlicksListViewCell.insert
        let margin = FlicksListViewCell.margin
        let itemWidth = FlicksListViewCell.itemWidth
        
        for i in 0..<listView.count {
            if listView[i].isHidden { break }
            let x = CGFloat(i % 3) * (itemWidth + margin) + insert.left
            let y = floor(CGFloat(i/3)) * (itemWidth + margin) + insert.top
            let rect = CGRect(x: x, y: y, width: itemWidth, height: itemWidth)
            listView[i].frame = rect
        }
        //FIXME: - 这一版没有加喜欢/评论的功能, 暂时隐藏
//        stackView.frame = CGRect(x: bounds.width - insert.right - 100, y: bounds.height - 38, width: 100, height: 36)
//        contentLab.frame = CGRect(x: insert.left, y: bounds.height - 30, width: contentWidth, height: 17)
//        dateBtn.frame = CGRect(x: contentLab.frame.maxX + 5, y: contentLab.frame.minY, width: stackView.frame.minX - contentLab.frame.maxX - 5, height: 17)
        
        contentLab.frame = CGRect(x: insert.left, y: bounds.height - 30, width: contentWidth, height: 17)
        dateBtn.frame = CGRect(x: contentLab.frame.maxX + 5, y: contentLab.frame.minY, width: bounds.width - contentLab.frame.maxX - insert.right - 5, height: 17)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    @objc
    private func pritureBtnDidTapped(sender: UIButton) {
        pirtureDidTappedSubject.onNext(sender.tag - 200)
    }
    
    static func calcTotalHeight(pirtureNums: Int) -> CGFloat {
        return 41 + floor(CGFloat(max(0, pirtureNums - 1)/3)) * (itemWidth + margin) + insert.top + itemWidth
    }
    
    static func calcContentWidth(string: String) -> CGFloat {
        return string.width(considering: 20, and: font)
    }
}
