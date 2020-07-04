//
//  UIViewController+Toast.swift
//  FlowerField
//
//  Created by 武飞跃 on 2019/7/1.
//  Copyright © 2019 武飞跃. All rights reserved.
//

import UIKit
import Toast_Swift
import RxSwift
import RxCocoa

typealias ToastModel = (message: String, level: ToastLevel)

enum ToastLevel {
    case waring     //警告⚠️, 它默认显示在viewController.view上
    case success    //成功✅, 它默认显示在viewController.view上
    case error      //错误❎, 它默认显示在viewController.view上
    case normal     //默认 不包含图标, 它默认显示在navigationController.view上
}

extension ToastLevel {
    fileprivate var image: UIImage? {
        switch self {
        case .waring:
            return UIImage(named: "toast_error_tips_white")
        case .success:
            return UIImage(named: "toast_error_tips_white")
        case .error:
            return UIImage(named: "toast_error_tips_white")
        case .normal:
            return nil
        }
    }
}

protocol Toastable {
    
    func showToast(message: String)
    
    /// 显示toast
    ///
    /// - Parameters:
    ///   - message: 显示文本
    ///   - icon: 显示图标
    ///   - offsetY: 距离垂直中心点的偏移量
    func showToast(message: String, icon: UIImage?, offsetY: CGFloat)
    
    func showLoading(target: UIView?, offsetY: CGFloat)
    func hideLoading(target: UIView?)
}

extension Toastable where Self: UIViewController {
    
    func showToast(message: String, level: ToastLevel, offsetY: CGFloat) {
        showToast(message: message, icon: level.image, offsetY: offsetY)
    }
    
    func showLoadingOnNavigationView(offsetY: CGFloat) {
        showLoading(target: navigationController?.view, offsetY: offsetY)
    }
    
    func hideLoadingOnNavigationView() {
        hideLoading(target: navigationController?.view)
    }
    
    //MARK: - 具体实现细节
    
    func showToast(message: String) {
        navigationController?.view.makeToast(message, duration: 3, position: .center)
    }
    
    /// 显示纯文本自定义toast, 背景色自定义, 文字自定义,  高度自定义, 显示的位置自定义, 宽度与屏幕等宽, 字体居中对齐
    /// - Parameter message: 自定义文本
    /// - Parameter fontSize: 字体大小
    /// - Parameter fontColor: 字体大小
    /// - Parameter bgColor: 背景色
    /// - Parameter height: 显示区域的高度
    /// - Parameter offsetY: 显示区域的位置, 例如: 如果要显示在参考视图view1下, 就传入 view1.frame.maxY
    func showToast(message: String, fontSize: CGFloat, fontColor: UIColor, bgColor: UIColor, height: CGFloat, offsetY: CGFloat) {
        
        let wrapperView = UIView()
        wrapperView.backgroundColor = bgColor
        wrapperView.bounds = CGRect(x: 0, y: 0, width: view.bounds.width, height: height)
        
        let titleLabel = UILabel(frame: wrapperView.bounds)
        titleLabel.font = UIFont.systemFont(ofSize: fontSize)
        titleLabel.textColor = fontColor
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.text = message
        
        wrapperView.addSubview(titleLabel)
        
        view.showToast(wrapperView, duration: 3, point: CGPoint(x: view.bounds.size.width / 2.0, y: height / 2.0 + offsetY))
    }
    
    func showToast(message: String, icon: UIImage?, offsetY: CGFloat) {
        
        let style = ToastManager.shared.style
        
        let wrapperView = UIView()
        wrapperView.backgroundColor = style.activityBackgroundColor
        wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        wrapperView.layer.cornerRadius = style.cornerRadius
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = icon
        
        let titleLabel = UILabel()
        titleLabel.font = style.messageFont
        titleLabel.textColor = style.messageColor
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = message
        
        wrapperView.addSubview(imageView)
        wrapperView.addSubview(titleLabel)
        
        let maxTitleSize = CGSize(width: view.bounds.width * style.maxWidthPercentage,
                                  height: view.bounds.height * style.maxHeightPercentage)
        let titleSize = titleLabel.sizeThatFits(maxTitleSize)
        
        let contentWidth = max(style.activitySize.width - 2 * style.horizontalPadding, titleSize.width)
        
        let centerX = contentWidth / 2 + style.horizontalPadding
        
        imageView.frame = CGRect(origin: CGPoint(x: centerX - style.imageSize.width/2, y: style.verticalPadding),
                                 size: style.imageSize)
        
        titleLabel.frame = CGRect(x: style.horizontalPadding,
                                  y: imageView.frame.maxY + 11,
                                  width: contentWidth,
                                  height: titleSize.height)
        
        wrapperView.frame = CGRect(x: 0.0,
                                   y: 0.0,
                                   width: contentWidth + 2 * style.horizontalPadding,
                                   height: max(style.activitySize.height, titleLabel.frame.maxY + style.verticalPadding))
        
        view.showToast(wrapperView, duration: 3, point: CGPoint(x: view.bounds.size.width / 2.0,
                                                                y: view.bounds.size.height / 2.0 + offsetY))
    }
    
    func showLoading(target: UIView? = .none, offsetY: CGFloat) {
        if let unwrappedTarget = target {
            unwrappedTarget.makeToastActivity(CGPoint(x: unwrappedTarget.bounds.size.width / 2.0,
                                                      y: unwrappedTarget.bounds.size.height / 2.0 + offsetY))
        }
        else {
            view.makeToastActivity(CGPoint(x: view.bounds.size.width / 2.0,
                                           y: view.bounds.size.height / 2.0 + offsetY))
        }
    }
    
    func hideLoading(target: UIView? = .none) {
        if let unwrappedTarget = target {
            unwrappedTarget.hideToastActivity()
        }
        else {
            view.hideToastActivity()
        }
    }
    
}

extension Toastable where Self: UIView {
    
    func showToast(message: String) {
        makeToast(message, duration: 3, position: .center)
    }
    
    func showToast(message: String, level: ToastLevel, offsetY: CGFloat) {
        showToast(message: message, icon: level.image, offsetY: offsetY)
    }
    
    /// 显示toast
    ///
    /// - Parameters:
    ///   - message: 显示文本
    ///   - icon: 显示图标
    ///   - offsetY: 距离垂直中心点的偏移量
    func showToast(message: String, icon: UIImage?, offsetY: CGFloat) {
        
        let style = ToastManager.shared.style
        
        let wrapperView = UIView()
        wrapperView.backgroundColor = style.activityBackgroundColor
        wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        wrapperView.layer.cornerRadius = style.cornerRadius
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = icon
        
        let titleLabel = UILabel()
        titleLabel.font = style.messageFont
        titleLabel.textColor = style.messageColor
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = message
        
        wrapperView.addSubview(imageView)
        wrapperView.addSubview(titleLabel)
        
        let maxTitleSize = CGSize(width: bounds.width * style.maxWidthPercentage,
                                  height: bounds.height * style.maxHeightPercentage)
        let titleSize = titleLabel.sizeThatFits(maxTitleSize)
        
        let contentWidth = max(style.activitySize.width - 2 * style.horizontalPadding, titleSize.width)
        
        let centerX = contentWidth / 2 + style.horizontalPadding
        
        imageView.frame = CGRect(origin: CGPoint(x: centerX - style.imageSize.width/2, y: style.verticalPadding),
                                 size: style.imageSize)
        
        titleLabel.frame = CGRect(x: style.horizontalPadding,
                                  y: imageView.frame.maxY + 11,
                                  width: contentWidth,
                                  height: titleSize.height)
        
        wrapperView.frame = CGRect(x: 0.0,
                                   y: 0.0,
                                   width: contentWidth + 2 * style.horizontalPadding,
                                   height: max(style.activitySize.height, titleLabel.frame.maxY + style.verticalPadding))
        
        showToast(wrapperView, duration: 3, point: CGPoint(x: bounds.size.width / 2.0,
                                                           y: bounds.size.height / 2.0 + offsetY))
    }
    
    func showLoading(target: UIView?, offsetY: CGFloat) {
        if let unwrappedTarget = target {
            unwrappedTarget.makeToastActivity(CGPoint(x: unwrappedTarget.bounds.size.width / 2.0,
                                                      y: unwrappedTarget.bounds.size.height / 2.0 + offsetY))
        }
        else {
            makeToastActivity(CGPoint(x: bounds.size.width / 2.0,
                                      y: bounds.size.height / 2.0 + offsetY))
        }
    }
    
    func hideLoading(target: UIView?) {
        if let unwrappedTarget = target {
            unwrappedTarget.hideToastActivity()
        }
        else {
            hideToastActivity()
        }
    }
}

extension UIViewController: Toastable { }

extension UIView: Toastable { }

extension Reactive where Base: UIViewController {
    
    var toast: Binder<ToastModel> {
        return Binder(self.base) { viewController, model in
            switch model.level {
            case .normal:
                viewController.showToast(message: model.message)
            default:
                viewController.showToast(message: model.message, level: model.level, offsetY: -60)
            }
        }
    }
    
    /// 默认没有图标, 只有纯文本, toast显示在导航栏上
    public var toastNormal: Binder<String> {
        return Binder(self.base) { viewController, title in
            viewController.showToast(message: title)
        }
    }
    
    /// 提示警告信息, 显示在ViewController上
    public var toastWarning: Binder<String> {
        return toast(level: .waring)
    }
    
    /// 提示错误信息, 显示在ViewController上
    public var toastError: Binder<String> {
        return toast(level: .error)
    }
    
    /// 提示成功信息, 显示在ViewController上
    public var toastSuccess: Binder<String> {
        return toast(level: .success)
    }
    
    private func toast(level: ToastLevel) -> Binder<String> {
        return Binder(self.base) { viewController, title in
            viewController.showToast(message: title, level: level, offsetY: -60)
        }
    }
    
    public var loading: Binder<Bool> {
        return Binder(self.base) { viewController, state in
            if state {
                viewController.showLoading(offsetY: -60)
            }
            else {
                viewController.hideLoading()
            }
        }
    }
    
    public var loadingOnNavigationView: Binder<Bool> {
        return Binder(self.base) { viewController, state in
            if state {
                viewController.showLoadingOnNavigationView(offsetY: 0)
            }
            else {
                viewController.hideLoadingOnNavigationView()
            }
        }
    }
}

extension Reactive where Base: UIView {
    
    var toast: Binder<ToastModel> {
        return Binder(self.base) { view, model in
            switch model.level {
            case .normal:
                view.showToast(message: model.message)
            default:
                view.showToast(message: model.message, level: model.level, offsetY: 0)
            }
        }
    }
    
    /// 默认没有图标, 只有纯文本, toast显示在导航栏上
    public var toastNormal: Binder<String> {
        return Binder(self.base) { view, title in
            view.showToast(message: title)
        }
    }
    
    /// 提示警告信息, 显示在ViewController上
    public var toastWarning: Binder<String> {
        return toast(level: .waring)
    }
    
    /// 提示错误信息, 显示在ViewController上
    public var toastError: Binder<String> {
        return toast(level: .error)
    }
    
    /// 提示成功信息, 显示在ViewController上
    public var toastSuccess: Binder<String> {
        return toast(level: .success)
    }
    
    private func toast(level: ToastLevel) -> Binder<String> {
        return Binder(base) { view, title in
            view.showToast(message: title, level: level, offsetY: 0)
        }
    }
    
    public var loading: Binder<Bool> {
        return Binder(base) { view, state in
            if state {
                view.showLoading(target: nil, offsetY: 0)
            }
            else {
                view.hideLoading(target: nil)
            }
        }
    }
    
}
