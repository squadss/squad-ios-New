//
//  CreateFlickInputView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/20.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class CreateFlickInputView: BaseView {
    
    var insert = UIEdgeInsets(top: 0, left: 26, bottom: 0, right: 26)
    var textField = UITextField()
    
    override func setupView() {
        addSubview(textField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textField.frame = CGRect(x: insert.left, y: insert.top, width: bounds.width - insert.left - insert.right, height: bounds.height - insert.top - insert.bottom)
    }
}
