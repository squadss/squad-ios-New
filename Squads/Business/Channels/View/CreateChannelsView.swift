//
//  CreateChannelsView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/20.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import ISEmojiView

class CreateChannelsView: BaseView {
    
    // 创建按钮
    var confirmBtn = UIButton()
    // 关闭pop的按钮
    var closeBtn = UIButton()
    // 头像
    var imageTextView = ImageTextView()
//    var imagePlacehoaderView = UIImageView(image: UIImage(named: "Normal Channel"))
    // 输入框
    var textField = UITextField()
    // 标题
    private var tipLab = UILabel()
    // 错误提示lab
    private var toastLab = UILabel()
    // 可编辑按钮
    private var canEditView = UIButton()
    
    private var gradientLayer: CAGradientLayer!
    private var disposeBag = DisposeBag()
    
    override func setupView() {
        
        setupImageTextView()
        setupBackgroundLayer()
        setupInoutField()
        setupCommonView()
        
        addSubviews(imageTextView, canEditView, tipLab, textField, toastLab, confirmBtn, closeBtn)
        
        Observable
            .combineLatest(textField.rx.text.orEmpty, imageTextView.rx.text.orEmpty) {
                return !($0.isEmpty || $1.isEmpty)
            }
            .bind(to: confirmBtn.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    private func setupImageTextView() {
        imageTextView.layer.cornerRadius = 39
        imageTextView.layer.masksToBounds = true
        imageTextView.font = UIFont.systemFont(ofSize: 60)
        imageTextView.tintColor = UIColor.clear
        imageTextView.text = "😎"
        imageTextView.textContainerInset = UIEdgeInsets(top: 3, left: 2, bottom: 0, right: 0)
        imageTextView.setInputAccessoryView(target: self, selector: #selector(imageCompletedBtnDidTapped))
        
        let setting = KeyboardSettings(bottomType: .categories)
        setting.countOfRecentsEmojis = 0
        let emojiView = EmojiView(keyboardSettings: setting)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
        imageTextView.inputView = emojiView
    }
    
    private func setupBackgroundLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(hexString: "#F7BDB7").cgColor,
                                UIColor(hexString: "#FDDEC8").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        gradientLayer.locations = [0, 1]
        gradientLayer.cornerRadius = 10
        layer.addSublayer(gradientLayer)
    }
    
    private func setupInoutField() {
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 10))
        textField.leftViewMode = .always
        textField.setInputAccessoryView(target: self, selector: #selector(textCompletedBtnDidTapped))
    }
    
    private func setupCommonView() {
        tipLab.text = "NAME"
        tipLab.theme.textColor = UIColor.textGray
        tipLab.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        toastLab.textAlignment = .center
        toastLab.theme.textColor = UIColor.textGray
        toastLab.font = UIFont.systemFont(ofSize: 12)
        
        confirmBtn.setTitle("Create", for: .normal)
        confirmBtn.setBackgroundImage(UIImage(color: UIColor(red: 0.754, green: 0.754, blue: 0.754, alpha: 1)), for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        confirmBtn.setTitleColor(.white, for: .normal)
        
        canEditView.contentMode = .center
        canEditView.setImage(UIImage(named: "Edit Group"), for: .normal)
        canEditView.addTarget(self, action: #selector(canEditBtnDidTapped), for: .touchUpInside)
        
        closeBtn.imageView?.contentMode = .center
        closeBtn.setImage(UIImage(named: "Channels Close"), for: .normal)
    }
    
    @objc
    private func canEditBtnDidTapped() {
        imageTextView.becomeFirstResponder()
    }
    
    @objc
    private func imageCompletedBtnDidTapped() {
        imageTextView.resignFirstResponder()
    }
    
    @objc
    private func textCompletedBtnDidTapped() {
        textField.resignFirstResponder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageTextView.frame = CGRect(x: (bounds.width - 78)/2, y: 56, width: 78, height: 78)
//        imagePlacehoaderView.frame = imageTextView.frame
        canEditView.frame = CGRect(x: imageTextView.frame.maxX - 25, y: imageTextView.frame.maxY - 25, width: 29, height: 29)
        
        tipLab.frame = CGRect(x: 36, y: imageTextView.frame.maxY + 29, width: bounds.width - 2 * 36, height: 14)
        
        gradientLayer.frame = CGRect(x: tipLab.frame.minX, y: tipLab.frame.maxY + 8, width: bounds.width - 2 * tipLab.frame.minX, height: 44)
        textField.frame = CGRect(x: tipLab.frame.minX + 3, y: tipLab.frame.maxY + 8 + 3, width: bounds.width - 2 * tipLab.frame.minX - 6, height: 44 - 6)
        
        toastLab.frame = CGRect(x: textField.frame.minX, y: textField.frame.maxY + 6, width: textField.frame.width, height: 20)
        
        confirmBtn.frame = CGRect(x: (bounds.width - 106)/2, y: bounds.height - 31 - 45, width: 106, height: 31)
        closeBtn.frame = CGRect(x: bounds.width - 60, y: 10, width: 44, height: 44)
    }
}

extension CreateChannelsView: EmojiViewDelegate {
    
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        imageTextView.deleteBackward()
        imageTextView.text = emoji
//        imagePlacehoaderView.isHidden = true
    }
    
    func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
        imageTextView.inputView = nil
        imageTextView.keyboardType = .default
        imageTextView.reloadInputViews()
    }
    
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        imageTextView.deleteBackward()
        imageTextView.text = "😎"
//        imagePlacehoaderView.isHidden = false
    }
    
    func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        imageTextView.resignFirstResponder()
    }
}

class ImageTextView: UITextView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let menuControler = UIMenuController.shared
        if menuControler != nil {
            menuControler.isMenuVisible = false
        }
        return false
    }
}
