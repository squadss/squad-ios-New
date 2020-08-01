//
//  TimePeriod.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/23.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

enum TimeChunk {
    case halfHour   //半小时
    
    var timeInterval: TimeInterval {
        switch self {
        case .halfHour: return 1800
        }
    }
}

enum TimeColor: Int {
    case normal
    case lightGray
    
    var uiColor: UIColor {
        switch self {
        case .normal: return UIColor(hexString: "#EC6256")
        case .lightGray: return UIColor(hexString: "#DFDFDF")
        }
    }
}

struct TimePeriod: Hashable {

    var beginning: TimeInterval
    var end: TimeInterval
    var color: TimeColor

    init(color: TimeColor, beginning: TimeInterval, end: TimeInterval) {
        self.beginning = beginning
        self.end = end
        self.color = color
    }
    
    init(color: TimeColor, beginning: TimeInterval, duration: TimeInterval) {
        self.beginning = beginning
        self.end = beginning + duration
        self.color = color
    }
    
    init(color: TimeColor, beginning: TimeInterval, chunk: TimeChunk) {
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
}
