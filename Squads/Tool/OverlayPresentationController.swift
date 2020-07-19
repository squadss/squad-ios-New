//
//  OverlayPresentationController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/18.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

protocol OverlayTransitioningDelegate: UIViewController {
    var transitioningProvider: OverlayTransitioningProvider? { get }
}

extension UIViewController {
    
    func transitionPresent<ViewController: OverlayTransitioningDelegate>(_ vc: ViewController, animated: Bool, completion: (() -> Void)? = nil) {
        
        if let provider = vc.transitioningProvider {
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = provider
            vc.modalPresentationCapturesStatusBarAppearance = true
        }
        
        self.present(vc, animated: animated, completion: completion)
    }
    
    //    var topViewController: UIViewController {
    //
    //        func getTop(_ vc: UIViewController?) -> UIViewController? {
    //
    //            guard let vc = vc else { return nil }
    //
    //            if let tabbarController = vc as? UITabBarController {
    //                return getTop(tabbarController.selectedViewController) ?? tabbarController
    //            } else if let navigationController = vc as? UINavigationController {
    //                return getTop(navigationController.topViewController) ?? navigationController
    //            } else {
    //                return vc
    //            }
    //
    //        }
    //
    //        return getTop(self) ?? self
    //    }
}

class OverlayTransitioningProvider: NSObject, UIViewControllerTransitioningDelegate {
    
    let height: CGFloat
    let maskOpacity: CGFloat
    
    init(height: CGFloat = 200, maskOpacity: CGFloat = 0.5, supportTap: Bool = false, supportSlider: Bool = false) {
        self.height = height
        self.maskOpacity = maskOpacity
        super.init()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayTransitioning(height: height, maskOpacity: maskOpacity)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayTransitioning(height: height, maskOpacity: maskOpacity)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let vc =  OverlayPresentationController(presentedViewController: presented, presenting: presenting)
        vc.maskOpacity = maskOpacity
        return vc
    }
    
}


class OverlayPresentationController: UIPresentationController {
    
    var maskOpacity: CGFloat = 0.5
    let maskView = UIView()
    
    /// 重写此方法可以在弹框即将出现时执行所需要的操作
    override func presentationTransitionWillBegin() {
        
        guard let containerView = containerView else { return }
        
        maskView.bounds = containerView.bounds
        
        if maskOpacity == 0 {
            maskView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        } else {
            maskView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        }
        
        containerView.addSubview(maskView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.maskView.backgroundColor = UIColor(white: 0.0, alpha: self.maskOpacity)
        }, completion: nil)
    }
    
    /// 将要消失前所需要执行的操作
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.maskView.alpha = 0.0
        }, completion: nil)
    }
    
    /// 将要布局子视图, 自定义presentdView 的大小和位置(仅调用一次)
    override func containerViewWillLayoutSubviews() {
        guard let containerView = containerView else { return }
        maskView.center = containerView.center
        maskView.bounds = containerView.bounds
    
        maskView.bounds = CGRect(x: containerView.bounds.origin.x, y: containerView.bounds.origin.y - 40, width: containerView.bounds.size.width, height: containerView.bounds.size.height + 80)
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
    }
    
}

class OverlayTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    let height: CGFloat
    let maskOpacity: CGFloat
    
    public init(height: CGFloat, maskOpacity: CGFloat) {
        self.height = height
        self.maskOpacity = maskOpacity
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let fromView = fromVC.view,
            let toView = toVC.view else {
                return
        }
        
        let containterView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        if toVC.isBeingPresented {
            
            // 此时 toView 为 PickerViewController.view
            containterView.addSubview(toView)
            
            // 先将 toView 移动到预定位置
            toView.frame.origin.y = height
            
            // 向上的动画
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                // 恢复原状
                toView.frame.origin.y = 0
            }, completion: { finished in
                let isCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!isCancelled)
            })
        }
        
        if fromVC.isBeingDismissed {
            
            // 向下的动画
            UIView.animate(withDuration: duration, animations: {
                fromView.frame.origin.y = self.height
            }) { (finished) in
                let isCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!isCancelled)
            }
            
        }
    }
    
}
