//
//  LoginBackgroundView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/8.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class LoginBackgroundView: BaseView {
    
    // 向上偏移量
    var offsetY: CGFloat = 0
    
    var tap = UITapGestureRecognizer()
    var imageView = UIImageView()
    private var gradientLayer: CAGradientLayer!
    override func setupView() {
        
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(hexString: "#EF7C72").cgColor,
                                UIColor(hexString: "#F5BC9C").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        gradientLayer.locations = [0, 1]
        layer.addSublayer(gradientLayer)
        
        imageView.image = UIImage(named: "SQUADS")
        addSubview(imageView)
        imageView.snp.makeConstraints { (maker) in
            maker.size.equalTo(CGSize(width: 204, height: 45))
            maker.centerX.equalToSuperview()
            maker.top.equalTo(141)
        }
        
        tap.addTarget(self, action: #selector(tapGesure(_:)))
        addGestureRecognizer(tap)
    }
    
    @objc
    private func tapGesure(_ gecognizer: UITapGestureRecognizer) {
        for subview in subviews {
            if subview is UITextField {
                (subview as? UITextField)?.resignFirstResponder()
            } else if subview is UIStackView {
                for itemView in (subview as! UIStackView).arrangedSubviews {
                    (itemView as? UITextField)?.resignFirstResponder()
                }
            }
        }
    }
    
    func addListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeListener() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShowNotification(sender: Notification) {
        let duration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration ?? 0.25) {
            self.transform = CGAffineTransform(translationX: 0, y: -self.offsetY)
        }
    }
    
    @objc
    private func keyboardWillHideNotification(sender: Notification) {
        let duration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration ?? 0.25) {
            self.transform = .identity
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
