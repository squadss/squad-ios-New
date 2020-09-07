//
//  AvtivityConfirmScheduledView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/16.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift

class AvtivityConfirmScheduledView: CornersView {
    
    // 点击底部菜单的回调, 取消/确认
    var didTapped: Observable<String?> {
        let list: Array<Observable<String?>> = menuList.map{ btn in
            btn.rx.tap.map{
                btn.title(for: .normal)
            }}
        return Observable.from(list).merge()
    }
    
    private let hLine = CALayer()
    private let vLine = UIView()
    private var stackView: UIStackView!
    private var menuList = [UIButton(), UIButton()]
    
    private var iconView = UIImageView()
    private var descriptionLab = UILabel()
    
    override func setupView() {
        
        menuList.first?.setTitle("Back", for: .normal)
        menuList.first?.setBackgroundImage(UIImage(color: .white), for: .normal)
        menuList.first?.setBackgroundImage(UIImage(color: UIColor(hexString: "#F1F1F1")), for: .highlighted)
        menuList.first?.setTitleColor(UIColor(red: 0, green: 0.478, blue: 1, alpha: 1), for: .normal)
        menuList.first?.setTitleColor(UIColor(red: 0.615, green: 0.791, blue: 0.983, alpha: 1), for: .disabled)
        menuList.first?.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        menuList.last?.setTitle("Confirm", for: .normal)
        menuList.last?.setBackgroundImage(UIImage(color: .white), for: .normal)
        menuList.last?.setBackgroundImage(UIImage(color: UIColor(hexString: "#F1F1F1")), for: .highlighted)
        menuList.last?.setTitleColor(UIColor(red: 0, green: 0.478, blue: 1, alpha: 1), for: .normal)
        menuList.last?.setTitleColor(UIColor(red: 0.615, green: 0.791, blue: 0.983, alpha: 1), for: .disabled)
        menuList.last?.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        iconView.contentMode = .scaleAspectFit
        
        descriptionLab.numberOfLines = 0
        addSubview(descriptionLab)
        
        stackView = UIStackView(arrangedSubviews: menuList)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        addSubview(stackView)
        
        vLine.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        hLine.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        
        layer.addSublayer(hLine)
        addSubviews(iconView, descriptionLab, stackView, vLine)
    }
    
    func config(activityType: EventCategory, timeperiod: TimePeriod) {
        
        guard let timeFormatter = TimeFormatter(timePeriod: timeperiod) else { return }
        
        let attr = NSMutableAttributedString()
        attr.append(NSAttributedString(string: "\(activityType.title) scheduled for\n", attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: UIColor(red: 0.925, green: 0.384, blue: 0.337, alpha: 1),
            .paragraphStyle: NSParagraphStyle.lineSpacing(6)
        ]))
        attr.append(NSAttributedString(string: "\(timeFormatter.dayFormat) \n", attributes: [
            .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
            .foregroundColor: UIColor.black,
            .paragraphStyle: NSParagraphStyle.lineSpacing(6)
        ]))
        attr.append(NSAttributedString(string: "from\n", attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: UIColor(red: 0.925, green: 0.384, blue: 0.337, alpha: 1),
            .paragraphStyle: NSParagraphStyle.lineSpacing(6)
        ]))
        attr.append(NSAttributedString(string: timeFormatter.timeFormat, attributes: [
            .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
            .foregroundColor: UIColor.black,
            .paragraphStyle: NSParagraphStyle.lineSpacing(6)
        ]))
        descriptionLab.attributedText = attr
        descriptionLab.textAlignment = .center
        iconView.image = activityType.image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let descriptionMarginTop: CGFloat = 12
        let descriptionMarginBottom: CGFloat = 12
        let iconMarginTip: CGFloat = 70
        
        stackView.frame = CGRect(x: 0, y: bounds.height - 56, width: bounds.width, height: 56)
        hLine.frame = CGRect(x: 0, y: stackView.frame.minY - 0.5, width: bounds.width, height: 0.5)
        vLine.frame = CGRect(x: bounds.midX, y: hLine.frame.minY, width: 0.5, height: 56)
        iconView.frame = CGRect(x: (bounds.width - 70)/2, y: iconMarginTip, width: 70, height: 70)
        descriptionLab.frame = CGRect(x: 30, y: iconView.frame.maxY + descriptionMarginTop, width: frame.width - 60, height: stackView.frame.minY - iconView.frame.maxY - descriptionMarginTop - descriptionMarginBottom)
    }
    
}
