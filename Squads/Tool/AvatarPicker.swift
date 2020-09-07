//
//  AvatarPicker.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import Photos
import RxSwift
import RxCocoa

/**
 // 必须声明为属性, 否则出了方法作用域就被释放了
 let picker = AvatarPicker()
 
 //调用此方法
 picker
 .image(optionSet: [.camera, .photo], delegate: self)
 .map{
     if let image = $0.1 { return image }
     return $0.0
 }
 .bind(to: imageView.rx.image)
 .disposed(by: rx.disposeBag)
 
 */

class AvatarPicker: NSObject, RxMediaPickerDelegate {
    
    private weak var parent: UIViewController?
    private var picker: RxMediaPicker!
    
    override init() {
        super.init()
        picker = RxMediaPicker(delegate: self)
    }
    
    func image(optionSet: AvatarPickerOptionSet, delegate: UIViewController) -> Observable<(UIImage, UIImage?, PHAsset?)> {
        
        self.parent = delegate
        
        var actions = [RxAlertAction]()
        if optionSet.contains(.photo) && allowedPhoto {
            actions.append(RxAlertAction(title: "photo", type: 1, style: .default))
        }
        if optionSet.contains(.camera) && allowedCamera {
            actions.append(RxAlertAction(title: "camera", type: 2, style: .default))
        }
        actions.append(RxAlertAction(title: "cancel", type: 3, style: .cancel))
        
        let alert = UIAlertController(title: "select photo", message: nil, preferredStyle: .actionSheet)
        delegate.present(alert, animated: true)
        
        return alert.addAction(actions: actions).flatMap { [unowned self] (value) -> Observable<(UIImage, UIImage?, PHAsset?)> in
            switch value {
            case 1: return self.picker.selectImage(editable: true)
            case 2: return self.picker.takePhoto()
            default: return Observable.empty()
            }
        }
        .observeOn(MainScheduler.instance)
    }
    
    func camera(delegate: UIViewController) -> Observable<(UIImage, UIImage?, PHAsset?)> {
        self.parent = delegate
        return self.picker.takePhoto()
    }
    
    func present(picker: UIImagePickerController) {
        parent?.present(picker, animated: true)
    }
    
    func dismiss(picker: UIImagePickerController) {
        parent?.dismiss(animated: true)
    }
    
    /// 相机权限
    private var allowedCamera: Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        return authStatus != .restricted && authStatus != .denied
    }
    
    /// 相册权限
    private var allowedPhoto: Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        return authStatus != .restricted && authStatus != .denied
    }
}

struct AvatarPickerOptionSet: OptionSet {
    var rawValue: Int
    static var camera = AvatarPickerOptionSet(rawValue: 1 << 0)
    static var photo = AvatarPickerOptionSet(rawValue: 1 << 1)
}
