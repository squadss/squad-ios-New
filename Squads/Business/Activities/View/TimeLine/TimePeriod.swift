//
//  TimePeriod.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/23.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import SwiftDate

enum TimeChunk {
    case halfHour   //半小时
    
    var timeInterval: TimeInterval {
        switch self {
        case .halfHour: return 1800
        }
    }
}

enum TimeColor: Int {
    case normal = 0
    case lightGray = -1
    case level5 = 5
    case level4 = 4
    case level3 = 3
    case level2 = 2
    case level1 = 1
    
    var uiColor: UIColor {
        switch self {
        case .normal: return UIColor(hexString: "#EF7C72")
        case .lightGray: return UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 0.1)
        case .level5:
            return UIColor(hexString: "#EF7C72")
        case .level4:
            return UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 0.85)
        case .level3:
            return UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 0.55)
        case .level2:
            return UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 0.4)
        case .level1:
            return UIColor(red: 0.937, green: 0.486, blue: 0.447, alpha: 0.25)
        }
    }
    
    func next() -> TimeColor {
        if self == .level5 { return .level5 }
        return TimeColor(rawValue: rawValue + 1)!
    }
    
    func next(in colors: [TimeColor]) -> TimeColor {
        guard
            let index = colors.firstIndex(of: self),
            colors.indices.contains(index + 1)
            else { return self }
        return colors[index + 1]
    }
    
    func prev(in colors: [TimeColor]) -> TimeColor {
        guard
            let index = colors.firstIndex(of: self),
            colors.indices.contains(index - 1)
            else { return self }
        return colors[index - 1]
    }
}

struct TimePeriod: Hashable, Codable {

    var middleDate: Date {
        return Date(timeIntervalSince1970: max(end - beginning, 0)/2 + beginning)
    }
    
    var startOffTime: Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: middleDate)
        return calendar.date(from: components)
    }
    
    var beginning: TimeInterval
    var end: TimeInterval
    var color: TimeColor
    var num: Int = 0
    
    var isEmpty: Bool {
        return end == beginning || end < beginning
    }
    
    var isSameDay: Bool {
        let beginningDate = Date(timeIntervalSince1970: beginning)
        let endDate = Date(timeIntervalSince1970: end)
        return beginningDate.isSameDay(with: endDate)
    }
    
    init(color: TimeColor = .normal, beginning: TimeInterval, end: TimeInterval) {
        self.beginning = beginning
        self.end = end
        self.color = color
    }
    
    init(color: TimeColor = .normal, beginning: TimeInterval, duration: TimeInterval, num: Int) {
        self.beginning = beginning
        self.end = beginning + duration
        self.color = color
        self.num = num
    }
    
    init(color: TimeColor = .normal, beginning: TimeInterval, chunk: TimeChunk) {
        self.beginning = beginning
        self.end = beginning + chunk.timeInterval
        self.color = color
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(beginning.hashValue)
        hasher.combine(end.hashValue)
        hasher.combine(color.hashValue)
    }

    var key: String {
        return "\(hashValue)_key"
    }
    
    init(from decoder: Decoder) throws {
        beginning = try decoder.decode("startTime")
        end = try decoder.decode("endTime")
        color = .normal
    }
    
    func encode(to encoder: Encoder) throws {
        try encoder.encode(beginning, for: "startTime")
        try encoder.encode(end, for: "endTime")
    }
    
    func nextLevel() -> TimePeriod {
        return TimePeriod(color: color.next(), beginning: beginning, end: end)
    }
    
    func toLevel1() -> TimePeriod {
        return TimePeriod(color: .level1, beginning: beginning, end: end)
    }
    
}

struct TimeFormatter {
    var date: Date
    var start: TimeInterval
    var end: TimeInterval
    
    // Saturday, April 4, 2020
    var dayFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
     
    var timeFormat: String {
        return formatTime(seconds: start) + "-" + formatTime(seconds: end)
    }
    
    let timePeriod: TimePeriod
    
    init?(timePeriod: TimePeriod) {
        
        guard timePeriod.isSameDay else {
            return nil
        }
        
        let calendar = Calendar.current
        let duration = timePeriod.end - timePeriod.beginning
        let beginningDate = Date(timeIntervalSince1970: timePeriod.beginning)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: beginningDate)
        
        let hourSecond: TimeInterval = TimeInterval(components.hour ?? 0) * 3600
        let minuteSecond: TimeInterval = TimeInterval(components.minute ?? 0) * 60
        
        self.start = hourSecond + minuteSecond
        self.end = self.start + duration
        self.timePeriod = timePeriod
        
        components.hour = 0
        components.minute = 0
        if let date = calendar.date(from: components) {
            self.date = date
        } else {
            return nil
        }
    }
    
    init?(startTime: String?, endTime: String?) {
        if let startDate = startTime?.toDate()?.date, let endDate = endTime?.toDate()?.date {
            self.init(timePeriod: TimePeriod(color: .normal, beginning: startDate.timeIntervalSince1970, end: endDate.timeIntervalSince1970))
        } else {
            return nil
        }
    }
    
    func formatTime(seconds: TimeInterval) -> String {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.dateFormat = "hh:mm aa"
        return formatter.string(from: date.addingTimeInterval(seconds))
    }
}
