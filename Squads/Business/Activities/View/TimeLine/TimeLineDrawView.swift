//
//  TimeLineDrawView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/22.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class TimeLineDrawView: TimeLineCanvasView {
    
    private(set) var selectedTimePeriod: TimePeriod?
    
    // 日期列表
    var dateList: Array<Date> = [] {
        didSet {
            column = dateList.count
        }
    }
    
    //绘制区域
    var drawRect: CGRect {
        return commonLayer?.rect ?? .zero
    }
    
    var color = TimeColor.normal
    
    private let key = "SelectLayerKey"
    private var commonLayer: TimeLineLayer?
    
    func draw(with rect: CGRect) {
        if commonLayer == nil {
            commonLayer = insertColor(color.uiColor, key: key)
        }
        commonLayer?.rect = rect
    }
    
    func clearDraw() {
        commonLayer?.rect = .zero
    }
    
    func commitEditing() {
        if drawRect != .zero, let currentDate = xToDate(drawRect.minX) {
            let startDate = yToDate(drawRect.minY, referenceDate: currentDate)
            let endDate = yToDate(drawRect.maxY, referenceDate: currentDate)
            selectedTimePeriod = TimePeriod(color: color,
                                            beginning: startDate.timeIntervalSince1970,
                                            end: endDate.timeIntervalSince1970)
        } else {
            selectedTimePeriod = nil
        }
    }
    
    //MARK: - 时间与坐标系之间的关系转换
    
    func dateToY(period: TimePeriod) -> CGRect? {
        let beginningOffset = dateToY(timeInterval: period.beginning)
        let endOffset = dateToY(timeInterval: period.end)
        if let x = dateToX(timeInterval: min(period.beginning, period.end)) {
            return CGRect(x: x, y: beginningOffset, width: gridWidth, height: max(endOffset - beginningOffset, 0))
        }
        return nil
    }
    
    /// 将日期对象转为坐标origin.y值
    ///  当传入 时间对象2020年7月22日 15:00时
    ///  则 返回的长度距离为200
    ///  解析: 当传入2020年7月22日 15:00时, 对比相同日期下11am, 它们之间相差240分钟, 按照当前每格高度25计算, 240 * 25 * 2 / 60 = 200
    /// - Parameter currentDate: 目标日期
    func dateToY(date currentDate: Date) -> CGFloat {
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
        let currentMinutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        let am11Minutes = 11 * 60
        
        // 一分钟占的高度
        let minuteDividedByHeight = gridHeight * 2 / 60
        
        let dateHeight = minuteDividedByHeight * CGFloat(currentMinutes - am11Minutes)
        return max(dateHeight, 0)
    }
    
    func dateToY(timeInterval: TimeInterval) -> CGFloat {
        let date = Date(timeIntervalSince1970: timeInterval)
        return dateToY(date: date)
    }
    
    func dateToX(date: Date) -> CGFloat? {
        if let index = dateList.firstIndex(where: { $0 == date }) {
            return CGFloat(index) * gridWidth
        }
        return nil
    }
    
    func dateToX(timeInterval: TimeInterval) -> CGFloat? {
        let date = Date(timeIntervalSince1970: timeInterval)
        return dateToX(date: date)
    }
    
    /// 将坐标转为当前时间对象, 坐标系顶点为11点钟
    ///  例如当传入 200.0时, 参考的时间为 2020年7月22日 23:27
    ///  则 返回的时间格式为 2020年7月22日 15:00
    ///  解析: 当传入200.0时, 按照每个格25的高度计算, 应该是4个小时间隔的时间, 由于起点时间为11am, 所以累加在一起就是3pm
    /// - Parameter y: 坐标中垂直方向距离
    /// - Parameter referenceDate: 参考的时间, 主要参考的是年月日这三项数据, 返回的对象和参考的对象年月日是一样的, 只不过返回的对象更具体
    func yToDate(_ y: CGFloat, referenceDate: Date) -> Date {
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: referenceDate)
        components.hour = 0
        components.minute = 0
        let startDate = calendar.date(from: components)!
        
        // 一分钟占的高度
        let minuteDividedByHeight = gridHeight * 2 / 60
        if minuteDividedByHeight <= 0 {
            return referenceDate
        }
        
        let am11Minutes = 11 * 60
        let value = Int(y/minuteDividedByHeight)
        
        return calendar.date(byAdding: .minute, value: value + am11Minutes, to: startDate)!
    }
    
    func xToDate(_ x: CGFloat) -> Date? {
        let columnIndex = Int(floor(x/gridWidth))
        if columnIndex >= 0 && columnIndex < dateList.count {
            return dateList[columnIndex]
        }
        return nil
    }
}

extension TimeLineDrawView {
    
    func adjustOriginYOrderFloor(_ value: CGFloat) -> CGFloat {
        return floor(value / gridHeight) * gridHeight
    }
    
    func adjustOriginYOrderCeil(_ value: CGFloat) -> CGFloat {
        return ceil(value / gridHeight) * gridHeight
    }
    
    func adjustOriginXOrderFloor(_ value: CGFloat) -> CGFloat {
        let columnIndex = Int(floor(value/gridWidth))
        return CGFloat(columnIndex) * gridWidth
    }
}
