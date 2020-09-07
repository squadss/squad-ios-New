//
//  Date+Extension.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/18.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation

extension Date {
    
    func isSameDay(with other: Date) -> Bool {
        let calenday = Calendar.current
        let comp1 = calenday.dateComponents([.year, .month, .day], from: self)
        let comp2 = calenday.dateComponents([.year, .month, .day], from: other)
        return comp1.day == comp2.day
            && comp1.month == comp2.month
            && comp1.year == comp2.year
    }
}
