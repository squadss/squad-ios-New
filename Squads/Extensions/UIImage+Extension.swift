//
//  UIImage+Extension.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

extension UIImage {
    /**
     根据传入的颜色值，返回一个绘制好的UIImage
     
     - parameter color: 颜色
     
     - returns: 图片
     */
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    public convenience init?(color: UIColor, size: CGSize, offset: CGPoint = .zero, radius: CGFloat) {
        let rect = CGRect(origin: offset, size: size)
        let maxSize = CGSize(width: rect.width + rect.origin.x, height: rect.height + rect.origin.y)
        UIGraphicsBeginImageContextWithOptions(maxSize, false, 0.0)
        
        let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        
        let context = UIGraphicsGetCurrentContext();
        context?.addPath(bezierPath.cgPath)
        context?.setFillColor(color.cgColor)
        context?.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    public convenience init?(color: UIColor,
                             bgColor: UIColor = .white,
                             radius: CGFloat,
                             padding: UIEdgeInsets = .zero) {
        
        let rect = CGRect(x: padding.left, y: padding.top, width: radius * 2, height: radius * 2)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.maxX + padding.right, height: rect.maxY + padding.bottom), false, 1.0)
        bgColor.setFill()
        
        let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        
        let context = UIGraphicsGetCurrentContext();
        context?.addPath(bezierPath.cgPath)
        context?.setFillColor(color.cgColor)
        context?.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    /// 生成传入字符串相关信息的二维码
    ///
    /// - Parameters:
    ///   - qrString : 信息字符串
    ///   - qrImageName: 中间的logo图片，不设置就传""
    /// - Returns: 二维码图片
    public class func createQR(with qrString: String?, logoName: String? = nil, size: CGSize) -> UIImage? {
        let image = logoName.flatMap{ UIImage(named: $0) }
        // Fix: 有些情况下使用图片名称不能获取到图片(不同bundle), 在不改变api的情况下兼容新的情况
        return createQR(with: qrString, qrIconImage: image, size: size)
    }
    
    /// 生成传入字符串相关信息的二维码
    ///
    /// - Parameters:
    ///   - qrString : 信息字符串
    ///   - qrIconImage: 中间的logo图片
    ///   - size: 生成图片的尺寸
    /// - Returns: 二维码图片
    class func createQR(with qrString: String?, qrIconImage: UIImage? = nil, size: CGSize) -> UIImage? {
        
        guard
            let sureQRString = qrString,
            let qrFilter = CIFilter(name: "CIQRCodeGenerator"),
            let colorFilter = CIFilter(name: "CIFalseColor")
            else { return nil }
        
        let stringData = sureQRString.data(using: .utf8, allowLossyConversion: false)
        //创建一个二维码的滤镜
        
        qrFilter.setValue(stringData, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        
        let outputImage = qrFilter.outputImage
        
        // 创建一个颜色滤镜,黑白色
        colorFilter.setDefaults()
        colorFilter.setValue(outputImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
        
        let transform = outputImage.flatMap { CGAffineTransform(scaleX: size.width / $0.extent.size.width, y: size.height / $0.extent.size.height) } ?? CGAffineTransform(scaleX: 1, y: 1)
        
        // 返回二维码image
        let ciiImagre: CIImage? = colorFilter.outputImage?.transformed(by: transform)
        let qrImage = ciiImagre.flatMap{ UIImage(ciImage: $0) }
        
        // 中间放logo
        guard
            let codeImage = qrImage,
            let iconImage = qrIconImage
            else { return qrImage }
        
        let rect = CGRect(x: 0, y: 0, width: codeImage.size.width, height: codeImage.size.height)
        
        UIGraphicsBeginImageContext(rect.size)
        codeImage.draw(in: rect)
        let avatarSize = CGSize(width: rect.size.width*0.25, height: rect.size.height*0.25)
        
        let x = (rect.width - avatarSize.width) * 0.5
        let y = (rect.height - avatarSize.height) * 0.5
        iconImage.draw(in: CGRect(x: x, y: y, width: avatarSize.width, height: avatarSize.height))
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    func drawColor(_ color: UIColor) -> UIImage? {
        if #available(iOS 13, *) {
            return withTintColor(color)
        }
        else {
            return _drawColor(color)
        }
    }
    
    private func _drawColor(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        color.setFill()
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(bounds)
        draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage
    }
    
    /// 压缩图片
    ///
    /// - Parameter maxLength: 最大的字节尺寸 bt为单位
    /// - Returns: 新的图片大小
    func compressImage(toByte maxLength: Int) -> UIImage {
        var compression: CGFloat = 1
        //先判断当前质量是否满足要求,不满足才进行压缩
        guard var data = jpegData(compressionQuality: compression),
            data.count > maxLength else { return self }
        
        // Compress by size
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = jpegData(compressionQuality: compression)!
            if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
        }
        var resultImage: UIImage = UIImage(data: data)!
        if data.count < maxLength { return resultImage }
        
        // Compress by size
        var lastDataLength: Int = 0
        while data.count > maxLength, data.count != lastDataLength {
            lastDataLength = data.count
            let ratio: CGFloat = CGFloat(maxLength) / CGFloat(data.count)
            let size: CGSize = CGSize(width: Int(resultImage.size.width * sqrt(ratio)),
                                      height: Int(resultImage.size.height * sqrt(ratio)))
            UIGraphicsBeginImageContext(size)
            resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            data = resultImage.jpegData(compressionQuality: compression)!
        }
        return resultImage
    }
    
}

// 翻转图片
extension UIImage {
    
    /// 水平翻转图像
    func flipToHorizontal() -> UIImage {
        let flipOrientation = (imageOrientation.rawValue + 4) % 8
        return UIImage(cgImage: cgImage!, scale: scale, orientation: Orientation(rawValue: flipOrientation)!)
    }
    
    /// 垂直翻转图像
    func flipToVertical() -> UIImage {
        var flipOrientation = (imageOrientation.rawValue + 4) % 8
        flipOrientation += (flipOrientation % 2 == 0 ? 1 : -1)
        return UIImage(cgImage: cgImage!, scale: scale, orientation: Orientation(rawValue: flipOrientation)!)
    }
}

extension CALayer {
    
    enum ViewCorner: CaseIterable {
        
        case top
        case bottom
        case allCorners
        
        var rectCorner: UIRectCorner {
            switch self {
            case .top:
                return [.topLeft, .topRight]
            case .bottom:
                return [.bottomLeft, .bottomRight]
            case .allCorners:
                return .allCorners
            }
        }
        
        var cornerMask: CACornerMask {
            switch self {
            case .top:
                return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case .bottom:
                return [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            case .allCorners:
                return [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            }
        }
        
    }
    
    func maskCorners(_ radius: CGFloat, rect: CGRect, corner: ViewCorner = .allCorners) {
        if #available(iOS 11, *) {
            cornerRadius = radius
            maskedCorners = corner.cornerMask
        } else {
            let maskLayer = CAShapeLayer()
            let size = CGSize(width: radius, height: radius)
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corner.rectCorner, cornerRadii: size)
            maskLayer.path = path.cgPath
            maskLayer.frame = rect
            mask = maskLayer
        }
    }
    
    func maskCorners(_ radius: CGFloat) {
        maskCorners(radius, rect: bounds)
    }
       
}

class CornersImageView: UIImageView {
    
    var radius: CGFloat?
    
    override var frame: CGRect {
        didSet {
            guard frame != oldValue else { return }
            
            var value: CGFloat {
                if let unwrappedRadius = radius {
                    return unwrappedRadius
                } else {
                    return min(frame.width, frame.height) / 2
                }
            }
            if value >= 0 {
                layer.maskCorners(value)
            }
        }
    }
}

class CornersButton: UIButton {
    
    var radius: CGFloat?
    
    override var frame: CGRect {
        didSet {
            guard frame != oldValue else { return }
            
            var value: CGFloat {
                if let unwrappedRadius = radius {
                    return unwrappedRadius
                } else {
                    return min(frame.width, frame.height) / 2
                }
            }
            if value >= 0 {
                layer.maskCorners(value)
            }
        }
    }
}

class CornersView: BaseView {
    
    var radius: CGFloat?
    
    override var frame: CGRect {
        didSet {
            guard frame != oldValue else { return }
            
            var value: CGFloat {
                if let unwrappedRadius = radius {
                    return unwrappedRadius
                } else {
                    return min(frame.width, frame.height) / 2
                }
            }
            if value >= 0 {
                layer.maskCorners(value)
            }
        }
    }
}
