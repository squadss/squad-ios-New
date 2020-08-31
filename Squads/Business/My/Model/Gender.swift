//
//  Gender.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/28.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation

enum Gender: String, Codable, CaseIterable {
    case male = "M"      //"男"
    case female = "F"    //"女"
    case unknown = "N"   //"未知"
    
    var title: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .unknown: return "Unknown"
        }
    }
    
    init?(title: String) {
        switch title {
        case "Male":
            self = .male
        case "Female":
            self = .female
        case "Unknown":
            self = .unknown
        default:
            return nil
        }
    }
}
