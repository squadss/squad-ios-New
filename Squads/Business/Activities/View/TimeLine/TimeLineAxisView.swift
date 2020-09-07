//
//  TimeLineAxisView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/22.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import AudioToolbox

class TimeLineAxisItemControl: BaseView {
    
    var handleView = UIView()
    
    override func setupView() {
        addSubview(handleView)
        handleView.theme.backgroundColor = UIColor.secondary
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        handleView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 50)
    }
}

class TimeLineAxisControl: BaseView, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    struct Model {
        var hour: Int
        var format12: String
    }
    
    var scrollDidStop: ((Int) -> Void)?
    var indicatorsMarginRight: CGFloat = 0
    private var topHandler = UIButton()
    private var bottomHandler = UIButton()
    private var dataSource: Array<Model>!
    private var tableView = UITableView()
    private var indicatorsView = TimeLineAxisItemControl()
    
    override func setupView() {
        
        dataSource = (0..<24).map { value in
            let suffix: String = value < 12 ? " AM" : " PM"
            return Model(hour: value, format12: "\(value == 12 ? 12 : value % 12)" + suffix)
        }
        
        topHandler.setImage(UIImage(named: "timeline_up"), for: .normal)
        topHandler.theme.backgroundColor = UIColor.background
        bottomHandler.setImage(UIImage(named: "timeline_down"), for: .normal)
        bottomHandler.theme.backgroundColor = UIColor.background
        
        tableView.rowHeight = 50
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 15, right: 0)
        tableView.register(Reusable.timeLineAxisCalibrationCell)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        indicatorsView.clipsToBounds = true
        indicatorsView.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        addSubviews(indicatorsView, tableView, topHandler, bottomHandler)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indicatorsView.frame = CGRect(x: 0, y: 0, width: 7, height: bounds.height - 15)
        tableView.frame = CGRect(x: indicatorsView.frame.maxX + indicatorsMarginRight, y: 0, width: bounds.width - indicatorsView.frame.maxX, height: bounds.height - 20)
        topHandler.frame = CGRect(x: tableView.frame.minX, y: 0, width: tableView.bounds.width, height: 10)
        bottomHandler.frame = CGRect(x: tableView.frame.minX, y: bounds.height - 25, width: tableView.bounds.width, height: 10)
    }
    
    func scrollToCurrentDate(animated: Bool = false) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: Date())
        let hour = components.hour ?? 0
        tableView.scrollToRow(at: IndexPath(row: hour, section: 0), at: .top, animated: animated)
        scrollDidStop?(hour)
    }
    
    private var lastIndex: Int?
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        slideWithContentOffset(contentOffset: scrollView.contentOffset.y,
                               contentHeight: scrollView.contentSize.height,
                               scrollViewHeight: scrollView.frame.size.height)
        
        // 添加振动效果
        let offsetY = scrollView.contentOffset.y - scrollView.contentInset.top
        let index = Int(round(offsetY / max(tableView.rowHeight, 1)))
        if lastIndex != index {
            AudioServicesPlaySystemSound(1519)
            lastIndex = index
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let offsetY = scrollView.contentOffset.y
            let index = Int(round(offsetY / max(tableView.rowHeight, 1)))
            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
            let model = dataSource[index]
            scrollDidStop?(model.hour)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let index = Int(round(offsetY / max(tableView.rowHeight, 1)))
        tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        let model = dataSource[index]
        scrollDidStop?(model.hour)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row]
        let cell = tableView.dequeue(Reusable.timeLineAxisCalibrationCell)!
        cell.selectionStyle = .none
        cell.titleLab.text = model.format12
        return cell
    }
    
    private func slideWithContentOffset(contentOffset: CGFloat, contentHeight: CGFloat, scrollViewHeight: CGFloat) {
        let scrollAreaHeight = contentHeight - scrollViewHeight
        if scrollAreaHeight == 0 { return }
        if contentOffset < 0 || contentOffset > scrollAreaHeight { return }
        // 滚动的比例
        let scale = contentOffset / scrollAreaHeight
        
        let slideViewHeight: CGFloat = 50
        let blankHeight: CGFloat = indicatorsView.bounds.height - slideViewHeight
        
        // 根据比例, 等比计算出滑块的位置
        let slideOffset = blankHeight * scale
        
        // 更新滑块的位置
        var frame = indicatorsView.handleView.frame
        frame.origin.y = slideOffset
        indicatorsView.handleView.frame = frame
    }
}

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
