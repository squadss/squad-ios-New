//
//  TimeLineTapView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/22.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class TimeLineDrawTapView: TimeLineDrawView {
    
    private var longGestureRecognizer = UILongPressGestureRecognizer()
    
    override func setupView() {
        super.setupView()
        longGestureRecognizer.addTarget(self, action: #selector(handleResizeHandleLongResture(_:)))
        longGestureRecognizer.cancelsTouchesInView = true
        addGestureRecognizer(longGestureRecognizer)
    }
    
    @objc
    private func handleResizeHandleLongResture(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            break
        case .ended, .cancelled:
            break
        default:
            break
        }
    }
}
