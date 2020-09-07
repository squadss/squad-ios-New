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
}

struct TimeLineAxisLayout {
    // 滚动条距离tableView轴的距离
    var indicatorsInsert: UIEdgeInsets = .zero
    var topHandlerMarginTop: CGFloat = 5
    var bottomHanderMarginBottom: CGFloat = 5
}

class TimeLineAxisControl: BaseView, UIScrollViewDelegate {

    var layout = TimeLineAxisLayout() {
        didSet { layoutUI() }
    }
    
    // 滑动暂停时的回调, 将当前Hour返回
    var scrollDidStop: ((Int) -> Void)?
    // 滑动时考虑label的高度, 需要偏移的值
    private let labOffset: CGFloat = 5
    private var tableView = UITableView()
    private var topHandlerBtn = UIButton()
    private var bottomHandlerBtn = UIButton()
    private var indicatorsView = TimeLineAxisItemControl()
    private var dataSource: Array<Int> = (0..<24).map { $0 }
    
    override func setupView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.scrollsToTop = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.register(Reusable.timeLineAxisCalibrationCell)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        topHandlerBtn.isEnabled = false
        topHandlerBtn.setImage(UIImage(named: "timeline_up"), for: .normal)
        topHandlerBtn.theme.backgroundColor = UIColor.background
        bottomHandlerBtn.isEnabled = false
        bottomHandlerBtn.setImage(UIImage(named: "timeline_down"), for: .normal)
        bottomHandlerBtn.theme.backgroundColor = UIColor.background
        
        indicatorsView.clipsToBounds = true
        indicatorsView.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        addSubviews(indicatorsView, tableView, topHandlerBtn, bottomHandlerBtn)
        
        layoutUI()
    }
    
    
    /// 根据传入的时间段列表, 滚动到其适应的位置
    /// - Parameter array: 时间段列表
    func scrollToAdaptDate(array: Array<TimePeriod>) {
        guard let adaptTimestamp = getAdaptDate(array: array) else {
            return
        }
        let calendar = Calendar.current
        let adaptDate = Date(timeIntervalSince1970: adaptTimestamp)
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: adaptDate)
        if let hour = components.hour {
            scrollToDate(hour: hour)
        }
    }
    
    func getAdaptDate(array: Array<TimePeriod>) -> TimeInterval? {
        var maxTime: TimeInterval?
        var minTime: TimeInterval?
        array.forEach { timePeriod in
            
            let end = timePeriod.end
            let beginning = timePeriod.beginning
            
            if let _minTime = minTime {
                minTime = min(beginning, _minTime)
            } else {
                minTime = beginning
            }
            if let _maxTime = maxTime {
                maxTime = max(end, _maxTime)
            } else {
                maxTime = end
            }
        }
        
        if let _maxTime = maxTime, let _minTime = minTime {
            // 最大时间减去最小时间超过5小时, 就以最小时间为准
            if _maxTime - _minTime >= 5 * 3600 {
                return _minTime
            } else {
                return _minTime - floor((5 * 3600 - (_maxTime - _minTime)) / 2)
            }
        }
        return nil
    }
    
    func scrollToCurrentDate(currentHour: Int = TimeLineAxisControl.currentHour, animated: Bool = false) {
        scrollToDate(hour: currentHour, animated: animated)
    }
    
    /// 滚动到当前时刻下
    func scrollToDate(hour: Int, animated: Bool = false) {
        guard hour >= 0 && hour < 24 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // https://www.jianshu.com/p/6935ef251cfb
            let calcHour = min(hour, 19)
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            self.tableView.scrollToRow(at: IndexPath(row: calcHour, section: 0), at: .top, animated: false)
            self.adjustIndicatorsFrame(scrollView: self.tableView)
            self.scrollDidStop?(calcHour)
        }
    }
    
    private var lastIndex: Int?
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 调整滚动条的显示
        adjustIndicatorsFrame(scrollView: scrollView)
        
        // 添加振动效果
        let offsetY = scrollView.contentOffset.y
        let index = Int(round(offsetY / max(50, 1)))
        if lastIndex != index {
            AudioServicesPlaySystemSound(1519)
            lastIndex = index
        }
    }
    
    private func adjustIndicatorsFrame(scrollView: UIScrollView) {
        let contentOffset = floor(scrollView.contentOffset.y)
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
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
    
    // https://www.it1352.com/926464.html
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            setContentOffset(scrollView: scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setContentOffset(scrollView: scrollView)
    }
    
    private func setContentOffset(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let index = Int(round(offsetY / 50))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(index) * 50), animated: true)
        }
        let hour = dataSource[index]
        scrollDidStop?(hour)
    }
    
    static var currentHour: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: Date())
        let hour = components.hour ?? 0
        return hour
    }
    
    private func layoutUI() {
        indicatorsView.frame = CGRect(x: layout.indicatorsInsert.left, y: layout.indicatorsInsert.top, width: 7,
                                      height: bounds.height - layout.indicatorsInsert.top - layout.indicatorsInsert.bottom)
        indicatorsView.handleView.frame = CGRect(x: 0, y: 0, width: 7, height: 50)
        let contentWidth = bounds.width - indicatorsView.frame.maxX - layout.indicatorsInsert.right
        let contentMinX = indicatorsView.frame.maxX + layout.indicatorsInsert.right
        topHandlerBtn.frame = CGRect(x: contentMinX, y: layout.topHandlerMarginTop, width: contentWidth, height: 10)
        bottomHandlerBtn.frame = CGRect(x: contentMinX, y: bounds.height - layout.bottomHanderMarginBottom - 10,
                                        width: contentWidth, height: 10)
        tableView.frame = CGRect(x: contentMinX, y: topHandlerBtn.frame.maxY, width: contentWidth,
                                 height: bottomHandlerBtn.frame.minY - topHandlerBtn.frame.maxY)
    }
}

extension TimeLineAxisControl: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hour = dataSource[indexPath.row]
        let cell = tableView.dequeue(Reusable.timeLineAxisCalibrationCell)!
        cell.selectionStyle = .none
        cell.titleLab.text = String(hour == 12 ? 12 : hour % 12) + (hour < 12 ? " AM" : " PM")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataSource.count == indexPath.row + 1 {
            return 50 + 12.5
        }
        return 50
    }
}

//MARK: - 此类已废弃
/*
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
*/
