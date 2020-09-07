//
//  Date+Helper.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/9.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation

extension Date {
    public func getWeek() -> String {
        let myWeekday: Int = Calendar.current.component(.weekday, from: self)
        switch myWeekday {
        case 1:
            return "SUN"
        case 2:
            return "MON"
        case 3:
            return "TUE"
        case 4:
            return "WED"
        case 5:
            return "THU"
        case 6:
            return "FRI"
        case 7:
            return "SAT"
        default:
            return ""
        }
    }
    
    public var chatTimeToString: String {
        get {
            let calendar = Calendar.current
            let now = Date()
            let nowComponents: DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
            let targetComponents:DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
            
            let year = (nowComponents.year ?? 0) - (targetComponents.year ?? 0)
            let month = (nowComponents.month ?? 0) - (targetComponents.month ?? 0)
            let day = (nowComponents.day ?? 0) - (targetComponents.day ?? 0)
            
            if year != 0 {
                return string(custom: "YYYY-MM-dd HH:mm")
            } else {
                if (month > 0 || day > 7) {
                    return string(custom: "MM-dd HH:mm")
                } else if (day > 1) {
                    return String(format: "%@ %02d:%02d", getWeek(), targetComponents.hour ?? 0, targetComponents.minute ?? 0)
                } else if (day == 1) {
                    return String(format: "yesterday %02d:%02d", targetComponents.hour ?? 0, targetComponents.minute ?? 0)
                } else if (day == 0){
                    return string(custom: "HH:mm")
                } else {
                    return ""
                }
            }
        }
    }
    
    private func string(custom: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = custom
        return dateFormatter.string(from: self)
    }
}


