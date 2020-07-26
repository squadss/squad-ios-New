//
//  RegisterGeneralViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/24.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class RegisterGeneralViewController: BaseViewController, BrickInputFieldStyle {

    var userTDO = UserTDO.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    /// 检查参数是否合法
    /// - Parameter properties: 待检查的参数
    func checkoutParams(properties: UserTDO.Properties) -> Result<UserTDO, GeneralError> {
        return userTDO.checkout(properties: properties)
    }
    
}
