//
//  TimeLineAxisView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/22.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class TimeLineAxisView: BaseView {
    
    var list: Array<String>? {
        didSet {
            guard list?.count == stackView.arrangedSubviews.count else { return }
            stackView.arrangedSubviews.map{ $0 as? UILabel }.enumerated().forEach { (index, btn) in
                btn?.text = list?[index]
            }
        }
    }
    
    override var frame: CGRect {
        didSet {
            guard frame != .zero && frame != oldValue else { return }
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 10, y: 0))
            path.addLine(to: CGPoint(x: 10, y: frame.height))
            line.path = path
            line.bounds = CGRect(x: 0, y: 0, width: 10, height: frame.height)
            line.position = CGPoint(x: 2, y: frame.height/2)
            stackView.frame = CGRect(x: insert.left, y: insert.top, width: frame.width - insert.left - insert.right, height: frame.height - insert.top - insert.bottom)
        }
    }
    
    var insert: UIEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
    
    var lineDashPhase: CGFloat = 0 {
        didSet {
            line.lineDashPhase = lineDashPhase
        }
    }
    
    var isHiddenLine: Bool {
        set { line.isHidden = newValue }
        get { line.isHidden }
    }
    
    private var line = CAShapeLayer()
    private var stackView: UIStackView!
    
    override func setupView() {
        
        line.lineWidth = 2
        line.lineJoin = .round
        line.lineCap = .round
        line.lineDashPattern = [0.001, 10] as [NSNumber]
        line.fillColor = UIColor.clear.cgColor
        line.strokeColor = UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 1).cgColor
        layer.addSublayer(line)
        
        var listView = Array<UIView>()
        for _ in 0..<6 {
            let lab = UILabel()
            lab.theme.textColor = UIColor.textGray
            lab.font = UIFont.systemFont(ofSize: 9, weight: .bold)
            lab.theme.backgroundColor = UIColor.background
            listView.append(lab)
        }
        stackView = UIStackView(arrangedSubviews: listView)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        addSubview(stackView)
    }
    
}
