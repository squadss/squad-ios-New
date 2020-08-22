//
//  Array+Extension.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation

extension Array {
    /// 安全的下标引用
    subscript (safe index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }
}
