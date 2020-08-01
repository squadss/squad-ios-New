//
//  NSParagraphStyle+Extension.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

extension NSParagraphStyle {
    static func lineSpacing(_ value: CGFloat) -> NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = value
        return style
    }
    
    static func lineHeightMultiple(_ value: CGFloat) -> NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = value
        return style
    }
}
