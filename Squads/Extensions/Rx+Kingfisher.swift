//
//  Rx+Kingfisher.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Kingfisher

extension Reactive where Base: UIImageView {

    public func imageURL(withPlaceholder placeholderImage: UIImage?,
                         options: KingfisherOptionsInfo? = []) -> Binder<URL?> {
        return Binder(self.base, binding: { (imageView: UIImageView, url) in
            imageView.kf.setImage(with: url, placeholder: placeholderImage, options: options, progressBlock: nil, completionHandler: nil)
        })
    }
}
