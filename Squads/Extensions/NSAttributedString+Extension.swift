//
//  NSAttributedString+Extension.swift
//  FlowerField
//
//  Created by 武飞跃 on 2019/6/28.
//  Copyright © 2019 武飞跃. All rights reserved.
//

import UIKit

extension NSAttributedString {
    
    func height(considering width: CGFloat) -> CGFloat {
        
        let constraintBox = CGSize(width: width, height: .greatestFiniteMagnitude)
        let rect = self.boundingRect(with: constraintBox, options: .usesLineFragmentOrigin, context: nil)
        return rect.height
        
    }
    
    func width(considering height: CGFloat) -> CGFloat {
        
        let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: height)
        let rect = self.boundingRect(with: constraintBox, options: .usesLineFragmentOrigin, context: nil)
        return rect.width
        
    }
}

