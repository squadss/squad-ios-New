//
//  String+Extension.swift
//  FlowerField
//
//  Created by 武飞跃 on 2019/6/28.
//  Copyright © 2019 武飞跃. All rights reserved.
//

import UIKit

extension String {
    
    func height(considering width: CGFloat, and font: UIFont) -> CGFloat {
        
        let constraintBox = CGSize(width: width, height: .greatestFiniteMagnitude)
        let rect = self.boundingRect(with: constraintBox, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.height
        
    }
    
    func width(considering height: CGFloat, and font: UIFont) -> CGFloat {
        
        let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: height)
        let rect = self.boundingRect(with: constraintBox, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.width
        
    }
    
    subscript(i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, count) ..< count]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)), upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    
    /// 13888888888 --> 138****8888
    public var secrecyPhone: String {
        guard count >= 7 else { return self }
        var temp = self
        let start = temp.index(temp.startIndex, offsetBy: 3)
        let end = temp.index(start, offsetBy: 4)
        let range: Range<String.Index> = start..<end
        temp.replaceSubrange(range, with: "****")
        return temp
    }
    
    /// 插入空格(对手机号的操作)
    public var insertSpacePhone: String {
        var insertPhone = scanToNumber
        
        if insertPhone.count > 3 {
            let stringIndex = insertPhone.index(insertPhone.startIndex, offsetBy: 3)
            insertPhone.insert(" ", at: stringIndex)
        }
        
        if insertPhone.count > 8 {
            let stringIndex = insertPhone.index(insertPhone.startIndex, offsetBy: 8)
            insertPhone.insert(" ", at: stringIndex)
        }
        
        return insertPhone
    }
    
    public var scanToNumber: String {
        return components(separatedBy: CharacterSet(charactersIn: "0123456789").inverted).joined()
    }
    
    public func isEmpty(then replace: String) -> String {
        return isEmpty ? replace : self
    }
    
    public var isPhoneNum: Bool {
        let mobile = "1[3|4|5|6|7|8|9|][0-9]{9}"
        let isMobile = NSPredicate(format: "SELF MATCHES %@", mobile).evaluate(with: self)
        return isMobile
    }
    
    /// 简单转换成的时间格式字符串
    public var simpleTime: String {
        //字符串截取
        if count == 19 {
            return String(self.prefix(16))
        }
        return self
    }
}

extension String {
    var asURL: URL? {
        return URL(string: self)
    }
    
    var asFileURL: URL {
        return URL(fileURLWithPath: self)
    }
}
