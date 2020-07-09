//
//  UIButton+Extension.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

extension UIButton {
    
    static func createFromImage(_ image: UIImage?) -> UIButton {
        let btn = UIButton()
        btn.setImage(image, for: .normal)
        return btn
    }
    
}
