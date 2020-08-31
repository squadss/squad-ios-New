//
//  FriendProfileViewCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FriendProfileViewCell: BaseTableViewCell {
    
    var titleLab = UILabel()
    private var contentField = UITextField()
    private var stackView: UIStackView!
    
    var disposeBag = DisposeBag()
    var longObservable: Observable<Void> {
        return longGesture.rx.event
            .throttle(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .filter{ $0.state == .began }
            .map{ _ in () }
            .asObservable()
    }
    
    var isShowTextField: Bool!
    
    var canEdit: Bool {
        set {
            
            if isShowTextField {
                stackView.isHidden = true
                contentField.isHidden = false
                
                contentField.isEnabled = newValue
                contentField.rightViewMode = newValue ? .always : .never
                
            } else {
                if newValue {
                    stackView.isHidden = false
                    contentField.isHidden = true
                } else {
                    stackView.isHidden = true
                    contentField.isHidden = false
                }
            }
        }
        get {
            if isShowTextField {
                return contentField.rightViewMode == .always
            } else {
                return !stackView.isHidden
            }
        }
    }
    
    var content: String? {
        set {
            if isShowTextField {
                contentField.text = newValue
            } else {
                let gender = newValue.flatMap { Gender(rawValue: $0) }?.title
                contentField.text = gender
                stackView.arrangedSubviews
                    .compactMap{ $0 as? UIButton }
                    .first{ $0.title(for: .normal) == gender }?
                    .isEnabled = false
            }
        }
        get {
            if isShowTextField {
                return contentField.text
            } else {
                return stackView.arrangedSubviews
                    .compactMap{ $0 as? UIButton }
                    .first{ $0.isEnabled == false }?
                    .title(for: .normal)
            }
        }
    }
    
    private var longGesture = UILongPressGestureRecognizer()
    
    override func setupView() {
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLab.theme.textColor = UIColor.secondary
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: 43))
        let iconView = UIImageView(image: UIImage(named: "User Profile Editer"))
        iconView.frame = CGRect(x: 5, y: 15.5, width: 12, height: 12)
        iconView.contentMode = .scaleAspectFit
        leftView.addSubview(iconView)
        
        contentField.font = UIFont.systemFont(ofSize: 14)
        contentField.theme.textColor = UIColor.text
        contentField.rightView = leftView
        contentField.isHidden = true
        contentField.setInputAccessoryView(target: self, selector: #selector(inputAccessoryDidTapped))
        contentView.addGestureRecognizer(longGesture)
        contentView.addSubviews(titleLab, contentField)
        
        let buttons: [UIView] = Gender.allCases.map { (item) in
            let button = UIButton()
            button.setTitle(item.title, for: .normal)
            button.setTitleColor(UIColor(hexString: "#333333"), for: .normal)
            button.setTitleColor(.white, for: .disabled)
            button.addTarget(self, action: #selector(btnDidTapped(sender:)), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.layer.borderColor = UIColor(hexString: "#dddddd").cgColor
            button.layer.borderWidth = 0.5
            button.setBackgroundImage(UIImage(color: .clear), for: .normal)
            button.setBackgroundImage(UIImage(color: UIColor(hexString: "#333333")), for: .disabled)
            return button
        }
        stackView = UIStackView(arrangedSubviews: buttons)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .fill
        stackView.isHidden = true
        contentView.addSubview(stackView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    @objc
    private func btnDidTapped(sender: UIButton) {
        guard sender.isEnabled else { return }
        stackView.arrangedSubviews.forEach{ ($0 as? UIButton)?.isEnabled = true }
        sender.isEnabled = false
    }
    
    @objc
    private func inputAccessoryDidTapped() {
        contentField.resignFirstResponder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentField.frame = CGRect(x: 34, y: bounds.height - 43, width: bounds.width - 68, height: 43)
        stackView.frame = CGRect(x: 34, y: bounds.height - 35, width: 200, height: 25)
        titleLab.frame = CGRect(x: 34, y: contentField.frame.minY - 17, width: 260, height: 17)
    }
}
