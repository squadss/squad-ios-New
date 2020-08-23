//
//  TimeLineCollectionView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/20.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
//import AudioToolbox

final class TimeLineCollectionView: BaseView {
    
    private var collection: UICollectionView!
    private(set) var foregroundView: TimeLineForegroundView?
    private var bottomLine: UIView!
    
    // 是否可以选择多个时间段 默认允许, 如果不允许, 则只能选择单个区域
    var allowMutilSelected: Bool = true
    
    // 是否允许编辑时间段, 默认不允许
    var canEdit: Bool = false {
        didSet {
            if canEdit {
                guard foregroundView == nil else { return }
                foregroundView = TimeLineForegroundView()
                foregroundView?.delegate = self
                foregroundView.flatMap { addSubview($0) }
                collection.isUserInteractionEnabled = false
            } else {
                foregroundView?.delegate = nil
                foregroundView?.removeFromSuperview()
                foregroundView = nil
                collection.isUserInteractionEnabled = true
            }
        }
    }
    
    // 取消当选中时间的时候, 改变时间值
    var cancelChangedTimeWhenSelected: Bool = false
    
    // 调整pengingEvent的大小
    var insertSelectedRect: UIEdgeInsets = .zero {
        didSet {
            foregroundView?.insertSelectedRect = insertSelectedRect
        }
    }
    
    // 自动调整对齐的尺寸
    var adjustSelectedRect: Bool = false {
        didSet {
            foregroundView?.adjustSelectedRect = adjustSelectedRect
        }
    }
    
    // 网格的高度
    var gridHeight: CGFloat = 25 {
        didSet { foregroundView?.gridHeight = gridHeight }
    }
    
    // 当前选中最小的index
    var minSelectedIndex: Int {
        return timeList.firstIndex(where: { $0 != 0 }) ?? 0
    }
    
    // 当前选中最大的index
    var maxSelectedIndex: Int {
        return timeList.reversed().firstIndex(where: { $0 != 0 }) ?? timeList.count - 1
    }
    
    // 当前选中的时间, 此属性只有在 cancelChangedTimeWhenSelected = true 时才有值
    private(set) var currentSelectedTimes: TimePeriod?
    
    // 正在选择时间时的回调, 可以根据此回调, 同步其它时间选择器的数据, 此回调只有在canEdit=true, cancelChangedTimeWhenSelected = false时, 才有效
    var timePeriodsDidSelectedCompletion: ((Array<TimePeriod>) -> Void)?
    
    private var didEndSelectedTimeRelay = PublishRelay<Array<TimePeriod>>()
    var didEndSelectedTimeObservable: Observable<Array<TimePeriod>> {
        return didEndSelectedTimeRelay.asObservable()
    }
    
    enum CellStyle {
        case dash
        case num
        case normal
    }
    
    // 设置显示样式
    var cellStyle: CellStyle = .normal
    
    private var lastAccessed: IndexPath?
    private var timeList = Array<Int>(repeating: 0, count: 48)//private
    private var startOffTime: Date?
    private var minNum: Int = 1
    private var maxNum: Int = 1
    
    override func setupView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.allowsMultipleSelection = false
        collection.register(NumberGridCell.self, forCellWithReuseIdentifier: "NumberGridCellKey")
        collection.register(NormalGridCell.self, forCellWithReuseIdentifier: "NormalGridCellKey")
        collection.register(SolidBoardGridCell.self, forCellWithReuseIdentifier: "SolidBoardGridCellKey")
        collection.register(DashBoardGridCell.self, forCellWithReuseIdentifier: "DashBoardGridCellKey")
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.backgroundColor = .white
        collection.delegate = self
        collection.dataSource = self
        collection.isScrollEnabled = false
        addSubview(collection)
        
        bottomLine = UIView()
        bottomLine.theme.backgroundColor = UIColor.textGray
        addSubview(bottomLine)
    }
    
    /// 根据时间段数组, 会显示到时间段选择器上
    /// 例如:
    /// let list = [  TimePeriod(beginning: 1598027400, end: 1598031000),
    ///         TimePeriod(beginning: 1598027400, end: 1598036400),
    ///         TimePeriod(beginning: 1598031000, end: 1598032800),
    ///         TimePeriod(beginning: 1598031000, end: 1598034600)]
    /// - Parameter list: 数据源
    func setDataSource(_ list: Array<TimePeriod>,
                       startOffTime: Date? = nil,
                       clearOrigin: Bool = true) {
        // 还原数据
        if clearOrigin {
            for i in 0..<timeList.count { timeList[i] = 0 }
        }
        
        if startOffTime != nil {
            self.startOffTime = startOffTime
        } else if let time = list.first, self.startOffTime == nil {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: time.middleDate)
            self.startOffTime = calendar.date(from: components)
        }
        
        guard let timestamp = self.startOffTime?.timeIntervalSince1970 else {
            return
        }
        
        // 将时间按照每半小时一个格, 一天分为48个格来承载
        for time in list {
            let startHour = Int(round((time.beginning - timestamp)/1800))
            let endHour = Int(round((time.end - timestamp)/1800))
            (startHour..<endHour).forEach { current in
                if current >= 0 && current < timeList.count {
                    let num = timeList[current] + 1
                    timeList[current] = num
                    minNum = min(num, minNum)
                    maxNum = max(num, maxNum)
                }
            }
        }
        collection.reloadDataAndKeepOffset()
    }
    
    // 获取数据源
    func getDataSource() -> Array<TimePeriod> {
        guard let originTimestamp = startOffTime?.timeIntervalSince1970 else {
            return []
        }
        // 相邻两个时间点如果桶的数量相同, 将它们分到一组
        var isContinuous: Bool = true
        var newList = Array<TimePeriod>()
        for index in 0..<timeList.count {
            let number = timeList[index]
            if let time = newList.last {
                
                if number == time.num && isContinuous {
                    newList[newList.count - 1].end += 1800
                } else if number != 0 {
                    // 数组已经封口了, 需要重新添加一条数据
                    newList.append(TimePeriod(color: colorWith(number), beginning: originTimestamp + TimeInterval(index * 1800), duration: 1800, num: number))
                    isContinuous = true
                } else {
                    isContinuous = false
                }
            } else if number != 0 {
                // 数组还没有数据, 向数组中追加一条
                newList.append(TimePeriod(color: colorWith(number), beginning: originTimestamp + TimeInterval(index * 1800), duration: 1800, num: number))
                isContinuous = true
            } else {
                isContinuous = false
            }
        }
        return newList
    }
    
    func scrollHalfHour(_ halfHour: Int, animated: Bool = true) {
        guard halfHour >= 0 && halfHour < timeList.count else { return }
        let indexPath = IndexPath(row: halfHour, section: 0)
        collection.scrollToItem(at: indexPath, at: .top, animated: animated)
    }
    
    // 颜色跨度
    private func colorWith(_ elem: Int) -> TimeColor {
        if maxNum - minNum > 5 {
            switch elem {
            case minNum: return .level1
            case minNum + 1: return .level2
            case minNum + 2..<maxNum - 1: return .level3
            case maxNum - 1: return .level4
            case maxNum: return .level5
            default: return .normal
            }
        } else {
            switch elem {
            case minNum: return .level1
            case minNum + 1: return .level2
            case minNum + 2: return .level3
            case minNum + 3: return .level4
            case minNum + 4: return .level5
            default: return .normal
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collection.frame = bounds
        foregroundView?.frame = bounds
        bottomLine?.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
    }
    
}

extension TimeLineCollectionView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cellStyle {
        case .dash:
            if indexPath.row % 2 == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardGridCellKey", for: indexPath) as! DashBoardGridCell
                cell.num = timeList[indexPath.row]
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SolidBoardGridCellKey", for: indexPath) as! SolidBoardGridCell
                cell.num = timeList[indexPath.row]
                return cell
            }
        case .num:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberGridCellKey", for: indexPath) as! NumberGridCell
            cell.num = timeList[indexPath.row]
            return cell
        case .normal:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NormalGridCellKey", for: indexPath) as! NormalGridCell
            cell.num = timeList[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: gridHeight)
    }

}

extension TimeLineCollectionView: TimeLineForegroundViewDelegate {
    
    func foregroundView(_ view: TimeLineForegroundView, willDisplay identifier: String) -> Array<CGRect> {
        var rectList = Array<CGRect>()
        for cell in collection.visibleCells {
            if let indexPath = collection.indexPath(for: cell), timeList[indexPath.row] != 0 {
                if !cell.frame.isEmpty { rectList.append(cell.frame) }
            }
        }
        return rectList.sorted(by: { $0.origin.y < $1.origin.y })
    }
    
    func foregroundView(_ view: TimeLineForegroundView, didEndTouch rect: CGRect) {
        let list = getDataSource()
        didEndSelectedTimeRelay.accept(list)
    }
    
    func foregroundView(_ view: TimeLineForegroundView, didSelectedArea rect: CGRect) {
        
        if cancelChangedTimeWhenSelected {
            let _rect = view.convert(rect, to: collection)
            var maxIndex: Int?
            var minIndex: Int?
            for cell in collection.visibleCells {
                if isCeil(rect1: _rect, rect2: cell.frame) {
                    if let index = collection.indexPath(for: cell)?.row {
                        
                        if timeList[index] == 0 {
                            minIndex = nil
                            maxIndex = nil
                        }
                        
                        if let unwrappedMin = minIndex {
                            minIndex = min(unwrappedMin, index)
                        } else {
                            minIndex = index
                        }
                        
                        if let unwrappedMax = maxIndex {
                            maxIndex = max(unwrappedMax, index)
                        } else {
                            maxIndex = index
                        }
                        
                    }
                }
            }
            
            if let unwrappedMin = minIndex,
                let unwrappedMax = maxIndex,
                let originTimestamp = startOffTime?.timeIntervalSince1970,
                unwrappedMin != unwrappedMax {
                currentSelectedTimes = TimePeriod(beginning: Double(unwrappedMin * 1800) + originTimestamp,
                                                  end: Double(unwrappedMax * 1800) + originTimestamp)
            } else {
                currentSelectedTimes = nil
            }
        } else {
            var indexPaths = Array<IndexPath>()
            for cell in collection.visibleCells {
                guard let indexPath = collection.indexPath(for: cell) else { return }
                if allowMutilSelected {
                    let _rect = view.convert(rect, to: collection)
                    if isCeil(rect1: _rect, rect2: cell.frame) {
                        timeList[indexPath.row] = 1
                        indexPaths.append(indexPath)
                    } else if isFloor(rect1: _rect, rect2: cell.frame) {
                        timeList[indexPath.row] = 0
                        indexPaths.append(indexPath)
                    }
                } else {
                    let _rect = view.convert(rect, to: collection)
                    if isCeil(rect1: _rect, rect2: cell.frame) {
                        timeList[indexPath.row] = 1
                        indexPaths.append(indexPath)
                    } else {
                        timeList[indexPath.row] = 0
                        indexPaths.append(indexPath)
                    }
                }
            }
            collection.reloadItems(at: indexPaths)
            timePeriodsDidSelectedCompletion?(getDataSource())
        }
    }
    
    private func isCeil(rect1: CGRect, rect2: CGRect) -> Bool {
        return (rect1.maxY >= rect2.maxY && rect1.origin.y < rect2.origin.y + rect2.height * 0.5) ||
               (rect1.minY <= rect2.minY && rect1.maxY > rect2.maxY - rect2.height * 0.5)
    }
    
    private func isFloor(rect1: CGRect, rect2: CGRect) -> Bool {
        return (rect1.maxY >= rect2.maxY
            && rect2.maxY > rect1.minY
            && rect1.origin.y >= rect2.origin.y + rect2.height * 0.5) ||
            (rect1.minY <= rect2.minY
                && rect1.maxY > rect2.minY
                && rect1.maxY <= rect2.minY + rect2.height * 0.5)
    }
}

extension Reactive where Base: TimeLineCollectionView {
    func setDataSource(clearOrigin: Bool = true) -> Binder<Array<TimePeriod>> {
        return Binder(base) { view, list in
            view.setDataSource(list, startOffTime: nil, clearOrigin: clearOrigin)
        }
    }
}


extension UICollectionView {
    
    public func reloadDataAndKeepOffset() {
        // stop scrolling
        setContentOffset(contentOffset, animated: false)
        
        // calculate the offset and reloadData
        let beforeContentSize = contentSize
        reloadData()
        layoutIfNeeded()
        let afterContentSize = contentSize
        
        // reset the contentOffset after data is updated
        let newOffset = CGPoint(
            x: contentOffset.x + (afterContentSize.width - beforeContentSize.width),
            y: contentOffset.y + (afterContentSize.height - beforeContentSize.height))
        setContentOffset(newOffset, animated: false)
    }
}
