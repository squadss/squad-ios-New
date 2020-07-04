//
//  UIView+Extension.swift
//  FlowerField
//
//  Created by 武飞跃 on 2019/12/4.
//  Copyright © 2019 武飞跃. All rights reserved.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach{ addSubview($0) }
    }
}
