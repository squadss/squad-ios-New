//
//  SquadMembersView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/6.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class SquadMembersView: BaseView {
    
    var memberWidth: CGFloat = 16
    var maxIndex: Int = 10
    var margin: CGFloat {
        set { stackView.spacing = newValue }
        get { stackView.spacing }
    }
    
    private var stackView = UIStackView()
    private var listView = Array<UIImageView>()
    
    private(set) var width: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: memberWidth)
    }
    
    override func setupView() {
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        addSubview(stackView)
    }
    
    func setMembers(members: Array<URL?>) {
        // 布局子视图
        setupMemberListView(from: members)
        // 计算自身宽度
        let count = CGFloat(members.count)
        width = count * memberWidth + stackView.spacing * max(count - 1, 0)
        // 布局子视图
        stackView.snp.remakeConstraints { (maker) in
            maker.width.equalTo(width)
            maker.height.equalTo(memberWidth)
            maker.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    // 根据数据源创建成员列表视图
    private func setupMemberListView(from list: Array<URL?>) {
        
        let count = stackView.arrangedSubviews.count
        list.enumerated().forEach{ (index, url) in
            var imageView: UIImageView?
            if index < count {
                imageView = stackView.arrangedSubviews[index] as? UIImageView
            } else {
                imageView = getMemberView(index: index)
                if let _imageView = imageView {
                    stackView.addArrangedSubview(_imageView)
                }
            }
            imageView?.kf.setImage(with: url)
        }
        
        if list.count < count {
            (0..<count - list.count).forEach{ index in
                let view = listView[list.count + index]
                stackView.removeArrangedSubview(view)
            }
        }
    }
    
    // 根据索引获取一个imageView, 会把已经创建的视图存到数组listView中, 避免重复创建
    private func getMemberView(index: Int) -> UIImageView? {
        
        guard index >= 0 && index < maxIndex else {
            return nil
        }
        
        if listView.count > index {
            return listView[index]
        } else {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = memberWidth/2
            imageView.layer.masksToBounds = true
            imageView.clipsToBounds = true
            listView.append(imageView)
            return imageView
        }
    }
}
