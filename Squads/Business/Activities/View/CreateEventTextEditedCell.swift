//
//  CreateEventTextEditedCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/11.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateEventTextEditedCell: BaseTableViewCell, UITextFieldDelegate {
    
    var dataSource: CreateEventTextEditor? {
        didSet {
            guard let unwrappedDataSource = dataSource else {
                return
            }
            switch unwrappedDataSource {
            case let .title(text):
                tap.isEnabled = false
                textField.isEnabled = true
                
                textField.text = text
                textField.rightViewMode = .never
                (textField.rightView as? UIImageView)?.image = nil
            case let .location(value, imagenamed):
                
                tap.isEnabled = true
                textField.isEnabled = false
                
                textField.text = value?.address
                if let attachImageNamed = imagenamed{
                    textField.rightViewMode = .always
                    (textField.rightView as? UIImageView)?.image = UIImage(named: attachImageNamed)
                }
            }
            if #available(iOS 13.0, *) {
                textField.attributedPlaceholder = NSAttributedString(string: unwrappedDataSource.placeholder ?? "", attributes: [
                    .foregroundColor: UIColor(red: 0.729, green: 0.729, blue: 0.729, alpha: 1),
                    .font: UIFont.systemFont(ofSize: 14)
                ])
            } else {
                textField.placeholder = unwrappedDataSource.placeholder
                textField.setValue(UIColor(red: 0.729, green: 0.729, blue: 0.729, alpha: 1), forKeyPath: "_placeholderLabel.textColor")
                textField.setValue(UIFont.systemFont(ofSize: 14), forKeyPath: "_placeholderLabel.font")
            }
        }
    }
    
    var disposeBag = DisposeBag()
    private var inputSubject = PublishSubject<CreateEventTextEditor>()
    var inputCompleted: Observable<CreateEventTextEditor> {
        return inputSubject.asObservable()
    }
    
    private var textField = UITextField()
    private var separatorLine = UIView()
    private var tap: UITapGestureRecognizer!
    
    override func setupView() {
        
        separatorLine.backgroundColor = UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 1)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit
        textField.rightView = imageView
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.delegate = self
        textField.isEnabled = false
        contentView.addSubviews(textField, separatorLine)
        addInputAccessoryView()
        
        tap = UITapGestureRecognizer(target: self, action: #selector(didTapped))
        tap.isEnabled = false
        contentView.addGestureRecognizer(tap)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    private func addInputAccessoryView() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        let spaceBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let completedB = UIButton(type: .system)
        completedB.setTitle("done", for: .normal)
        completedB.setTitleColor(.black, for: .normal)
        completedB.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        completedB.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        completedB.addTarget(self, action: #selector(completedBtnDidTapped), for: .touchUpInside)
        
        let completedBtn = UIBarButtonItem(customView: completedB)
        completedBtn.tintColor = .blue
        toolbar.items = [spaceBtn, completedBtn]
        textField.returnKeyType = .done
        textField.inputAccessoryView = toolbar
    }
    
    @objc
    private func completedBtnDidTapped() {
        textField.resignFirstResponder()
    }
    
    @objc
    private func didTapped() {
        if let _dataSource = dataSource {
            inputSubject.onNext(_dataSource)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textField.frame = CGRect(x: 33, y: 0, width: bounds.width - 66, height: 46)
        separatorLine.frame = CGRect(x: 33, y: textField.frame.maxY + 4, width: bounds.width - 66, height: 1)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let text = textField.text, !text.isEmpty {
            inputSubject.onNext(CreateEventTextEditor.title(text: text))
        }
    }
}
