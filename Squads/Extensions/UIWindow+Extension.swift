//
//  UIWindow+Extension.swift
//  FlowerField
//
//  Created by 武飞跃 on 2020/3/6.
//  Copyright © 2020 武飞跃. All rights reserved.
//

import UIKit

extension UIWindow {
    var layoutInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            let safeAreaInsets: UIEdgeInsets = self.safeAreaInsets
            if safeAreaInsets.bottom > 0 {
                //参考文章：https://mp.weixin.qq.com/s/Ik2zBox3_w0jwfVuQUJAUw
                return safeAreaInsets
            }
            return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }

    var navigationHeight: CGFloat {
        let statusBarHeight = layoutInsets.top
        return statusBarHeight + 44
    }
}
