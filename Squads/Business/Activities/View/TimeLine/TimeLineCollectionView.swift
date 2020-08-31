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

final class TimeLineCollectionView: BaseView {
    
    /// 每个cell视图只有上左右方向有边框, 会导致整个collectionView没有底部边框, 所以新增了bottomLine放在最下面
    private var bottomLine: UIView!
    private var collection: UICollectionView!
    /// 用于绘制区域的视图
    private(set) var foregroundView: TimeLineForegroundView?
    
    /// 是否可以选择多个时间段 默认允许
    /// 如果不允许, 当选中多个时间段时, 前一个时间段会被置为默认不选中状态, 保障只有一个活跃
    var allowMutilSelected: Bool = true
    
    /// 是否允许编辑时间段, 默认不允许, 则不会创建foregroundView视图
    /// 它会控制foregroundView的懒加载, 只有被允许时, 才会创建该视图, 并只会创建一次
    var canEdit: Bool = false {
        didSet {
            setupForegroundViewIfNeeded()
        }
    }
    
    /// 当在foregroundView视图上选中时间段的时候, 会同步改变CollectionViewCell的显示, 默认是联动的, 可以通过该属性取消联动
    var cancelChangedTimeWhenSelected: Bool = false
    
    /// 调整pengingEvent的大小
    var insertSelectedRect: UIEdgeInsets = .zero {
        didSet { foregroundView?.insertSelectedRect = insertSelectedRect }
    }
    
    // 自动调整对齐的尺寸
    var adjustSelectedRect: Bool = false {
        didSet { foregroundView?.adjustSelectedRect = adjustSelectedRect }
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
    
    /// 当前选中的时间段, 此属性只有在 cancelChangedTimeWhenSelected = true 时才有值
    private(set) var currentSelectedTimes: TimePeriod?
    
    /// 正在选择时间段时的回调, 可以根据此回调, 联动其它时间选择器
    /// 此回调只有在canEdit = true, cancelChangedTimeWhenSelected = false时, 才有效
    var timePeriodsDidSelectedCompletion: ((Array<TimePeriod>) -> Void)?
    
    /// 结束编辑时间段时的回调流, 此回调在手势状态为state=.ended时会触发一次
    private var didEndSelectedTimeRelay = PublishRelay<Array<TimePeriod>>()
    var didEndSelectedTimeObservable: Observable<Array<TimePeriod>> {
        return didEndSelectedTimeRelay.asObservable()
    }
    
    // 设置显示样式
    var cellStyle: CellStyle = .normal
    
    private var minNum: Int = 1
    private var maxNum: Int = 1
    private var startOffTime: Date?
    private var lastAccessed: IndexPath?
    // 将一天的时间按照每半小时一个格, 一天分为48个格来承载
    private var timeList = Array<Int>(repeating: 0, count: 48)
    
    override func setupView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
        collection.allowsMultipleSelection = false
        addSubview(collection)
        
        bottomLine = UIView()
        bottomLine.theme.backgroundColor = UIColor.textGray
        addSubview(bottomLine)
    }
    
    private func setupForegroundViewIfNeeded() {
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
    
    /// 根据时间段数组, 会显示到时间段选择器上
    /// 例如:
    /// let list = [  TimePeriod(beginning: 1598027400, end: 1598031000),
    ///         TimePeriod(beginning: 1598027400, end: 1598036400),
    ///         TimePeriod(beginning: 1598031000, end: 1598032800),
    ///         TimePeriod(beginning: 1598031000, end: 1598034600)]
    /// - Parameter list: 数据源
    /// - Parameter startOffTime: 一天中开始的时间 比如: 2020-08-26 00:00:00
    /// - Parameter clearOrigin: 是否清空原数据, 如果重复调用此方法, 不清空数据的话, 数据会一直累加
    func setDataSource(_ list: Array<TimePeriod>,
                       startOffTime: Date? = nil,
                       clearOrigin: Bool = true) {
        
        // 设置参考的日期, 如果外部不传入startOffTime, 则取list中的第一个元素的startOffTime
        // 所以list要保证是同一天的时间段, 否则会出现不可预料的错误
        if startOffTime != nil {
            self.startOffTime = startOffTime
        } else {
            self.startOffTime = list.first?.startOffTime
        }
        
        // 是否需要清空旧数据
        if clearOrigin { for i in 0..<timeList.count { timeList[i] = 0 } }
        
        // 更新数据源, 刷新视图
        if let timestamp = self.startOffTime?.timeIntervalSince1970 {
            list.forEach { increase(timeperiod: $0, startOffTimestamp: timestamp) }
            collection.reloadDataAndKeepOffset()
        }
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
                    let timePeriod = TimePeriod(color: colorWith(number),
                                                beginning: originTimestamp + TimeInterval(index * 1800),
                                                duration: 1800,
                                                num: number)
                    newList.append(timePeriod)
                    isContinuous = true
                } else {
                    isContinuous = false
                }
            } else if number != 0 {
                // 数组还没有数据, 向数组中追加一条
                let timePeriod = TimePeriod(color: colorWith(number),
                                            beginning: originTimestamp + TimeInterval(index * 1800),
                                            duration: 1800,
                                            num: number)
                newList.append(timePeriod)
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
    
    // 自增
    private func increase(timeperiod time: TimePeriod, startOffTimestamp timestamp: TimeInterval) {
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
    
    // 递减
    private func decrease(timeperiod time: TimePeriod, startOffTimestamp timestamp: TimeInterval) {
        let startHour = Int(round((time.beginning - timestamp)/1800))
        let endHour = Int(round((time.end - timestamp)/1800))
        (startHour..<endHour).forEach { current in
            if current >= 0 && current < timeList.count {
                let num = max(timeList[current] - 1, 0)
                timeList[current] = num
                minNum = min(num, minNum)
                maxNum = max(num, maxNum)
            }
        }
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
        case .dash(let levelColor):
            if indexPath.row % 2 == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardGridCellKey", for: indexPath) as! DashBoardGridCell
                let num = timeList[indexPath.row]
                if let fixedNum = levelColor?.rawValue {
                    cell.num = num == 0 ? 0 : fixedNum
                } else {
                    cell.num = num
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SolidBoardGridCellKey", for: indexPath) as! SolidBoardGridCell
                let num = timeList[indexPath.row]
                if let fixedNum = levelColor?.rawValue {
                    cell.num = num == 0 ? 0 : fixedNum
                } else {
                    cell.num = num
                }
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

extension TimeLineCollectionView {
    
    enum CellStyle {
        case dash(level: TimeColor?)
        case num
        case normal
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
