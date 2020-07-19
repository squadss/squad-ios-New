//
//  SquadGameViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class SquadGameViewController: ReactorViewController<SquadGameReactor> {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.theme.backgroundColor = UIColor.background
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(ss(gesture:)))
//        tap.cancelsTouchesInView = false
        tap.minimumPressDuration = 0.25
        tap.delaysTouchesBegan = true
        let btn = UIView(frame: CGRect(x: 10, y: 100, width: 300, height: 300))
        btn.addGestureRecognizer(tap)
        btn.backgroundColor = .blue
        view.addSubview(btn)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("touchesBegan")
    }
    
    @objc
    func ss(gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            print("began")
        case .ended, .cancelled:
            print("cancel: \(gesture.state == .cancelled)")
            print("end: \(gesture.state == .ended)")
        case .changed:
            print("changed")
        default:
            break
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
