//
//  CreateEventAvailabilityCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/11.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class ItemView: BaseView {
    
}

class SectionView: BaseView {
    
    struct Coordinates: Equatable {
        let rowIndex: Int
        let start: Int
        let end: Int
        
        static func == (lhs: Coordinates, rhs: Coordinates) -> Bool {
            return lhs.rowIndex == rhs.rowIndex
                && lhs.start == rhs.start
                && lhs.end == rhs.end
        }
        
        func isValid(fromRow row: Int) -> Bool {
            if rowIndex < 0 || rowIndex >= row || start < 0 || end < 0 || start >= end {
                return false
            }
            return true
        }
    }
    
    // 每一项的行高
    var itemHeight: CGFloat = 25
    // 每一项的行宽
    var itemWidth: CGFloat {
        return bounds.width / CGFloat(max(column, 1))
    }
    
    // 列数
    var column: Int = 1 {
        didSet {
            drawBorderPath()
        }
    }
    
    // 行数
    var row: Int = 10 {
        didSet {
            drawBorderPath()
        }
    }
    
    override var frame: CGRect {
        didSet {
            drawBorderPath()
        }
    }
    
    private var borderLayer = CAShapeLayer()
    private var backgroundLayers = Array<ItemLayer>()
    
    override func setupView() {
        borderLayer.lineWidth = 1
        borderLayer.theme.strokeColor = UIColor.textGray.map{ $0?.cgColor }
        borderLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(borderLayer)
    }
    
    private func drawBorderPath() {
        let outsideRect = CGRect(x: 0, y: 0, width: bounds.width, height: CGFloat(row) * itemHeight)
        let bezi = UIBezierPath(rect: outsideRect)
        (0..<(row - 1)).forEach { index in
            bezi.move(to: CGPoint(x: 0, y: itemHeight * CGFloat(index + 1)))
            bezi.addLine(to: CGPoint(x: bounds.width, y: itemHeight * CGFloat(index + 1)))
        }
        (0..<column).forEach { index in
            bezi.move(to: CGPoint(x: itemWidth * CGFloat(index + 1), y: 0))
            bezi.addLine(to: CGPoint(x: itemWidth * CGFloat(index + 1), y: CGFloat(row) * itemHeight))
        }
        borderLayer.path = bezi.cgPath
    }
    
    /// 插入一个layer
    /// - Parameter color: 背景色
    /// - Parameter rowIndex: 列的索引  从0开始 小于row的值
    /// - Parameter start: 开始的位置 一个完整的格步长为3
    /// - Parameter end: 结束的位置 一个完整的格步长为3
    /// - Parameter key: 标示此layer, 便于后期对其操作
    @discardableResult
    fileprivate func insertColor(_ color: UIColor, withCoordinates coordinates: Coordinates, key: String? = nil) -> ItemLayer? {
        guard coordinates.isValid(fromRow: row) else { return nil }
        
        var subLayer: ItemLayer?
        if let unwrappedKey = key {
            subLayer = layer.sublayers?.reversed().first(where: {
                return ($0 as? ItemLayer)?.key == unwrappedKey
            }) as? ItemLayer
        }
        
        if subLayer == nil {
            subLayer = getLayerFromCache(key: key)
            layer.insertSublayer(subLayer!, at: 0)
        }
        
        subLayer?.path = UIBezierPath(rect: getRect(fromCoordinates: coordinates)).cgPath
        subLayer?.fillColor = color.cgColor
        return subLayer
    }
    
    /// 根据标示移除一个layer
    /// - Parameter key : 标示
    func removeColor(_ key: String) {
        let subLayer = layer.sublayers?.reversed().first(where: { (layer) -> Bool in
            if let itemLayer = layer as? ItemLayer {
                return itemLayer.key == key
            }
            return false
        })
        subLayer?.removeFromSuperlayer()
        cacheLayer(subLayer as! ItemLayer)
    }
    
    /// 清空所有的颜色值
    func clearColors() {
        layer.sublayers?.filter{ $0.isKind(of: ItemLayer.self) }.forEach {
            $0.removeFromSuperlayer()
            cacheLayer($0 as! ItemLayer)
        }
    }
    
    private func cacheLayer(_ layer: ItemLayer) {
        backgroundLayers.append(layer)
    }
    
    private func getLayerFromCache(key: String?) -> ItemLayer {
        if let layer = backgroundLayers.last {
            layer.key = key
            backgroundLayers.removeLast()
            return layer
        }
        let layer = ItemLayer()
        layer.key = key
        layer.bounds = bounds
        layer.anchorPoint = .zero
        return layer
    }
    
    /// 将坐标点转为frame
    /// - Parameter rowIndex: 列的索引
    /// - Parameter start: 开始位置
    /// - Parameter end: 结束位置
    func getRect(fromCoordinates coordinates: Coordinates) -> CGRect {
        let x = CGFloat(coordinates.rowIndex) * itemWidth
        let y = CGFloat(coordinates.start) * itemHeight / 3
        let height = CGFloat(coordinates.end - coordinates.start) * itemHeight / 3
        return CGRect(x: x, y: y, width: itemWidth, height: height)
    }
    
    /// 将frame转为坐标点
    /// - Parameter layer: 传入一个layer
    func coordinates(fromFrame rect: CGRect) -> Coordinates {
        let rowIndex = Int(floor((rect.origin.x)/max(1, itemWidth)))
        let start = Int(floor(rect.origin.y * 3 / itemHeight))
        let end = Int(floor(rect.maxY * 3 / itemHeight))
        return Coordinates(rowIndex: rowIndex, start: start, end: end)
    }
    
}

struct SlidableTimeItem: Hashable {
    
    var start: TimeInterval
    var end: TimeInterval
    var color: UIColor
    
    init(color: UIColor, start: TimeInterval, end: TimeInterval) {
        self.start = start
        self.end = end
        self.color = color
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(start.hashValue)
        hasher.combine(end.hashValue)
        hasher.combine(color.hashValue)
    }
    
    var key: String {
        return "\(hashValue)_key"
    }
}

struct SlidableTimeSectionModel {
    var headTitle: String
    var footTitle: String
    var items: Array<SlidableTimeItem>
}

import RxSwift

class SlidableTimeView: BaseView {
    
    struct TitleStyle {
        
        var textAlignment: NSTextAlignment
        var textColor: Observable<UIColor?>
        var font: UIFont
        
        static let small = TitleStyle(textAlignment: .center, textColor: UIColor.secondary, font: .systemFont(ofSize: 9, weight: .bold))
    }
    
    var dataSource: Array<SlidableTimeSectionModel>? {
        didSet {
            guard let unwrappedDataSource = dataSource else { return }
            configView(unwrappedDataSource)
        }
    }
    
    var headerTitleStyle = TitleStyle.small
    var footerTitleStyle = TitleStyle.small
    
    private var contentView = PanSectionView1()
    private var topListView = Array<UILabel>()
    private var topStackView = UIStackView()
    private var bottomListView = Array<UILabel>()
    private var bottomStackView = UIStackView()
    private var longRecognizer: UILongPressGestureRecognizer!
    
    // 起始点/终点
    private var startY: CGFloat?
    private var endY: CGFloat?
    private var originX: CGFloat = 0
//    private var originY: CGFloat?
    private var lastPoint: CGPoint?
    private var contentHeight: CGFloat?
    private var height: CGFloat?
    
    override func setupView() {
        
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.alignment = .fill
        
        topStackView.axis = .horizontal
        topStackView.distribution = .fillEqually
        topStackView.alignment = .fill
        
        longRecognizer = UILongPressGestureRecognizer()
        longRecognizer.addTarget(self, action: #selector(recognizerAction(gesture:)))
        longRecognizer.minimumPressDuration = 0.1
        contentView.addGestureRecognizer(longRecognizer)
        addSubviews(topStackView, contentView, bottomStackView)
    }
    
    // 移动时记录的最后一个格的位置
    private var lastGridPoint: CGFloat?
    
    // 是否需要标记为清空状态
    private var needFlagClear: Bool = false
    // 锁定滑动方向
    private var lockSlidingDirection: Bool?
    
    @objc
    private func recognizerAction(gesture: UILongPressGestureRecognizer) {
        
        let currentPoint = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            
            var rect = CGRect(x: adjustOffsetX(currentPoint.x), y: 0, width: gridWidth, height: 0)
            // 在表格中的位置
            let realPoint = adjustOffsetY(currentPoint.y)
            
            // 确定起始点和终点位置
            if let _startY = startY, let _endY = endY {
                let _height = _endY - _startY
                
                // 如果用户只选择了一格, 当再次点击时, 可标记为清空, 等手势end结束时, 判断是否需要clear
                if _height == gridHeight && realPoint == _startY {
                    needFlagClear = true
                }
                
                rect.origin.y = _startY
                rect.size.height = _height
                contentHeight = _height
            } else {
                //新增一个起始点和终点位置
                
                startY = realPoint
                contentHeight = gridHeight
                endY = realPoint + gridHeight
                rect.origin.y = realPoint
                rect.size.height = gridHeight
            }
            
            // 记录最后一次点击位置
//            originY = startY
            lastPoint = currentPoint
            contentView.began(rect: rect)
            originX = adjustOffsetX(currentPoint.x)
        case .changed:
            guard let _lastPoint = lastPoint else { return }
            
            // 获取移动的距离
            let distance = currentPoint.y - _lastPoint.y
            let currentGridPoint = adjustOffsetY(currentPoint.y)
            let gridDidChanged = lastGridPoint == nil ? true : lastGridPoint != currentGridPoint
            
            if !gridDidChanged {
                return
            }
            
            // 将当前网格保存, 便于下次比较
            lastGridPoint = currentGridPoint
            
            // 移动的距离超过网格的一半, 这时网格数据会变化, 可以锁定滑动方向
            if lockSlidingDirection == nil, abs(distance) >= gridHeight * 0.5 {
                lockSlidingDirection = distance > 0
            }
            
            print("发生改变, 可以添加手机振动")
            
            switch (lockSlidingDirection, distance > 0) {
            case (.some(true), true):   //向下
                print("向下")
                guard let originY = startY, let height = contentHeight else { return }
                let rect = CGRect(x: originX, y: originY, width: gridWidth, height: adjustOffsetY(distance + height))
                contentView.move(rect: rect)
                endY = rect.maxY
            case (.some(false), false):  //向上
                print("向上")
                guard let maxY = endY, let height = contentHeight else { return }
                let rect = CGRect(x: originX, y: maxY - abs(distance) - height, width: gridWidth, height: adjustOffsetY(abs(distance) + height))
                contentView.move(rect: rect)
                startY = rect.minY
            default:
                print("舍弃")
            }
            
        case .ended, .cancelled:
            if needFlagClear {
                let realPoint = adjustOffsetY(currentPoint.y)
                if let _endY = endY, let _startY = startY, gridHeight == _endY - _startY, startY == realPoint {
                    
                    endY = nil
                    startY = nil
                    needFlagClear = false
                    
                    contentView.clear()
                }
            }
            // 解锁滑动的方向
            lockSlidingDirection = nil
        default:
            break
        }
    }
    
    private var gridWidth: CGFloat {
        return contentView.itemWidth
    }
    
    private var gridHeight: CGFloat {
        return contentView.itemHeight
    }
    
    private func adjustOffsetY(_ value: CGFloat) -> CGFloat {
        return floor(value / contentView.itemHeight) * contentView.itemHeight
    }
    
    private func adjustOffsetX(_ value: CGFloat) -> CGFloat {
       let rowIndex = floor(value/contentView.itemWidth)
       return CGFloat(rowIndex) * contentView.itemWidth
    }
    
    private func configView(_ list: Array<SlidableTimeSectionModel>) {
        // 将子视图清空
        removeBottomViews()
        removeTopViews()
        
        list.forEach { (model) in
            let bottomLabel = getBottomView()
            bottomLabel.text = model.footTitle
            bottomStackView.addArrangedSubview(bottomLabel)
            
            let topLabel = getTopView()
            topLabel.text = model.headTitle
            topStackView.addArrangedSubview(topLabel)
        }
    }
    
    private func getBottomView() -> UILabel {
        
        if let last = bottomListView.last {
            bottomListView.removeLast()
            return last
        }
        
        let label = UILabel()
        label.textAlignment = footerTitleStyle.textAlignment
        label.theme.textColor = footerTitleStyle.textColor
        label.font = footerTitleStyle.font
        return label
    }
    
    private func removeBottomViews() {
        bottomStackView.arrangedSubviews.forEach { (view) in
            guard let label = view as? UILabel else { return  }
            bottomListView.append(label)
            bottomStackView.removeArrangedSubview(label)
        }
    }
    
    private func getTopView() -> UILabel {
        
        if let last = topListView.last {
            topListView.removeLast()
            return last
        }
        
        let label = UILabel()
        label.textAlignment = headerTitleStyle.textAlignment
        label.theme.textColor = headerTitleStyle.textColor
        label.font = headerTitleStyle.font
        return label
    }
    
    private func removeTopViews() {
        topStackView.arrangedSubviews.forEach { (view) in
            guard let label = view as? UILabel else { return  }
            topListView.append(label)
            topStackView.removeArrangedSubview(label)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topStackView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 17)
        contentView.frame = CGRect(x: 0, y: topStackView.frame.maxY + 5, width: bounds.width, height: 250)
        bottomStackView.frame = CGRect(x: 0, y: contentView.frame.maxY, width: bounds.width, height: 45)
    }
}

class PanSectionView1: SectionView {
    
    var color = UIColor.red
    let key = "SelectLayerKey"
    private var commonLayer: ItemLayer?
    
    func began(rect: CGRect) {
        commonLayer = insertColor(color, withCoordinates: coordinates(fromFrame: rect), key: key)
    }
    
    func move(rect: CGRect) {
        commonLayer?.path = UIBezierPath(rect: rect).cgPath
    }
    
    func clear() {
        move(rect: .zero)
    }
}

class PanSectionView: SectionView {
    
    private var indexKeys = Dictionary<String, ItemLayer?>()
    
    // 起点终点
    private var startPoint: CGPoint?
    private var height: CGFloat?
    private var endPoint: CGPoint?
    
    @discardableResult
    func began(color: UIColor, location: CGPoint, key: String) -> CGRect {
        
        // 还没有设置起点, 会将第一次进来的点作为原点, 后面舍弃点其它的点
        var rect = CGRect.zero
        if let _startPoint = startPoint {
            rect.origin = _startPoint
            print("began 存在startPoint: \(startPoint)")
        } else {
            rect.origin = CGPoint(x: adjustOffsetX(location.x), y: adjustOffsetY(location.y))
            startPoint = rect.origin
            print("began 新建startPoint: \(startPoint)")
        }
        
        if height == nil {
            height = itemHeight
        }
        
        // 还没有设置终点, 取itemheight加上起点坐标的值
        if let _endPoint = endPoint {
            
//            rect.size = CGSize(width: itemWidth, height: height)
            print("began 存在endPoint: \(endPoint) size: \(rect.size)")
        } else {
            rect.size = CGSize(width: itemWidth, height: itemHeight)
            endPoint = CGPoint(x: rect.origin.x, y: rect.origin.y + itemHeight)
            print("began 新建endPoint: \(endPoint) size: \(rect.size)")
        }
        
        let sublayer = insertColor(color, withCoordinates: coordinates(fromFrame: rect), key: key)
        indexKeys[key] = sublayer
        return rect
    }
    
    func move(_ key: String, vector: CGFloat) {
        guard let subLayer = indexKeys[key], let _height = height else { return }
        
        if vector > 0 {
            //向下扩大, 起点不变, 增大终点
            guard let _startPoint = startPoint else { return }
            let rect = CGRect(x: _startPoint.x, y: _startPoint.y, width: itemWidth, height: adjustOffsetY(_height + vector))
            subLayer?.path = UIBezierPath(rect: rect).cgPath
            endPoint = CGPoint(x: _startPoint.x, y: rect.maxY)
            print("move 向下 vector: \(vector) startPoint: \(startPoint), endPoint: \(endPoint)")
        } else if vector < 0 {
            //向上收缩, 终点
            guard let _endPoint = endPoint else { return }
            let rect = CGRect(x: _endPoint.x, y: _endPoint.y + vector, width: itemWidth, height: adjustOffsetY(_height + vector))
            subLayer?.path = UIBezierPath(rect: rect).cgPath
            startPoint = CGPoint(x: _endPoint.x, y: rect.origin.y)
            print("move 向上 vector: \(vector)  startPoint: \(startPoint), endPoint: \(endPoint)")
        }
    }
    
    func ended(key: String) {
        indexKeys.removeValue(forKey: key)
        if let end = endPoint, let start = startPoint {
            height = max(0, end.y - start.y)
        }
    }
    
//    private func needAdjectOffsetY(_ value: CGFloat) -> Bool {
//        return false
//    }
//
    /// 调整偏移量
    /// - Parameter value: 当前点
    private func adjustOffsetY(_ value: CGFloat) -> CGFloat {
        return floor(value / itemHeight) * itemHeight
    }
    
    private func adjustOffsetX(_ value: CGFloat) -> CGFloat {
        let rowIndex = Int(floor(value/itemWidth))
        return CGFloat(rowIndex) * itemWidth
    }
}

fileprivate class ItemLayer: CAShapeLayer {
    var key: String?
    override func removeFromSuperlayer() {
        super.removeFromSuperlayer()
        key = nil
    }
}

class TimeAxisView: BaseView {
    
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

class TimeSelectedView: BaseView, UIGestureRecognizerDelegate {
    
    // 刻度列表
    var dialList: Array<String>? {
        didSet {
            timeAxis.list = dialList
        }
    }
    
    // 两个item之间的距离
    var margin: CGFloat = 9
    
    private var availabilityLab = UILabel()
    private var myTimeLab = UILabel()
    private var timeAxis = TimeAxisView()
    private var availabilityView = SectionView()
    private var myTimeView = SlidableTimeView()
    private var availabilityStackView = UIStackView()
    private var myTimeStackView = UIStackView()
    
    private var longRecognizer: UILongPressGestureRecognizer!
    private var panRecognizer: UIPanGestureRecognizer!
    
    override func setupView() {
        
        timeAxis.list = ["11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM"]
        addSubviews(availabilityLab, myTimeLab, timeAxis, availabilityView, myTimeView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        timeAxis.frame = CGRect(x: 0, y: 0, width: 40, height: bounds.height)
        let itemWidth = (bounds.width - timeAxis.frame.maxX - margin) / 2
        
        availabilityLab.frame = CGRect(x: timeAxis.frame.maxX + 1,
                                       y: 0,
                                       width: itemWidth,
                                       height: 22)
        
        myTimeLab.frame = CGRect(x: bounds.width - itemWidth,
                                 y: 0,
                                 width: itemWidth,
                                 height: 22)
        
        availabilityStackView.frame = CGRect(x: timeAxis.frame.maxX + 1,
                                             y: bounds.height - 45,
                                             width: itemWidth,
                                             height: 45)
        
        myTimeStackView.frame = CGRect(x: bounds.width - itemWidth,
                                       y: bounds.height - 45,
                                       width: itemWidth,
                                       height: 45)
        
        availabilityView.frame = CGRect(x: timeAxis.frame.maxX + 1,
                                        y: availabilityLab.frame.maxY,
                                        width: itemWidth,
                                        height: 250)
        
        myTimeView.frame = CGRect(x: bounds.width - itemWidth,
                                  y: myTimeLab.frame.maxY,
                                  width: itemWidth,
                                  height: 250)
    }
}

class CreateEventAvailabilityCell: BaseTableViewCell {
    
    var timeView = TimeSelectedView()
    
    override func setupView() {
//        let axisTimeView = AxisTimeView(frame: CGRect(x: 10, y: 10, width: 400, height: 400))
//        axisTimeView.list = ["11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM"]
//        contentView.addSubview(axisTimeView)
        
//        let ss = SectionView(frame: CGRect(x: 10, y: 10, width: 200, height: 400))
//        ss.column = 2
//        ss.row = 5
        timeView.isUserInteractionEnabled = true
        contentView.addSubview(timeView)
        
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            ss.insertColor(.red, withRowIndex: 0, start: 6, end: 9)
//
//            ss.insertColor(.red, withRowIndex: 1, start: 4, end: 12)
//
//            ss.insertColor(.blue, withRowIndex: 1, start: 5, end: 9)
//
//            ss.clearColors()
//
//            ss.insertColor(.red, withRowIndex: 1, start: 3, end: 6)
//        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timeView.frame = CGRect(x: 20, y: 10, width: bounds.width - 40, height: bounds.height - 20)
    }
   
}
