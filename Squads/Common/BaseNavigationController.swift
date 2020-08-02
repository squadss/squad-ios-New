//
//  BaseNavigationController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return globalStatusBarStyle.value
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false
        
        if #available(iOS 11, *) {
            navigationBar.shadowImage = UIImage()
        }
        else {
            //此方法会导致在push到下个页面时，状态栏会闪一下，因此需要给状态栏加个白色背景
            navigationBar.clipsToBounds = true
            
            let window = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow
            let statusBar = window?.value(forKey: "statusBar") as? UIView
            statusBar?.backgroundColor = .white
        }
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomImageView?.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bottomImageView?.isHidden = true
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bottomImageView?.isHidden = true
    }
    
}

extension UINavigationController {
    
    var bottomImageView: UIImageView? {
        return findNavBarBottomImage(view: navigationBar)
    }
    
    private func findNavBarBottomImage(view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.height <= 1.0 {
            return view as? UIImageView
        }
        for subview in view.subviews {
            let imageView = findNavBarBottomImage(view: subview)
            if imageView != nil {
                return imageView
            }
        }
        return nil
    }
    
}
