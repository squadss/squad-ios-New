//
//  CreateFlickReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/20.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa
import Photos

class CreateFlickReactor: Reactor {
    
    enum CellType {
        case camera
        case photos
        case pirture
    }
    
    enum Action {
        // 加载相册中的图片
        case loadPhotos(count: Int, status: PHAuthorizationStatus)
        // 移除选中的照片
        case deletePhoto(PHAsset)
        // 添加选中的照片
        case addPhoto(PHAsset)
        // 设置
        case setPhoto(Array<PHAsset>)
        // 创建flick
        case uploadFlick(title: String, url: String)
    }
    
    enum Mutation {
        case setPhotos(Array<CellType>?, isDenied: Bool)
        case setDeletePhoto(PHAsset)
        case setAddPhoto(PHAsset)
        case setPhoto(Array<PHAsset>)
        case setToast(String)
        case setUploadSuccess(state: Bool, toast: String)
        case setLoading(Bool)
    }
    
    struct State {
        // 发布成功
        var postSuccess: Bool?
        // 相册资源
        var photos: Array<CellType>?
        // 选中的图片
        var selectedPhotos: Array<PHAsset>?
        // 是否被拒绝
        var isDenied: Bool?
        // 提示
        var toast: String?
        //
        var isLoading: Bool?
    }
    
    var initialState: State
    var provider = OnlineProvider<SquadAPI>()
    let squadId: Int
    init(squadId: Int) {
        self.squadId = squadId
        initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .loadPhotos(count, status):
            var cellTypeList: Array<CellType>!
            let isDenied = status != .authorized
            if count != 0 {
                cellTypeList = Array(repeating: .pirture, count: count)
                cellTypeList.insert(.camera, at: 0)
                cellTypeList.append(.photos)
            }
            return .just(.setPhotos(cellTypeList, isDenied: isDenied))
        case .deletePhoto(let asset):
            if currentState.selectedPhotos?.contains(asset) == true {
                return Observable.just(.setDeletePhoto(asset))
            } else {
                return Observable.just(.setToast(NSLocalizedString("system.wrongOperation", comment: "")))
            }
        case .setPhoto(let assets):
            return Observable.just(.setPhoto(assets))
        case .addPhoto(let asset):
            if currentState.selectedPhotos == nil
            || currentState.selectedPhotos!.count < 9
            && currentState.selectedPhotos!.contains(asset) == false {
                return Observable.just(.setAddPhoto(asset))
            }
            return Observable.empty()
        case let .uploadFlick(title, url):
            guard let media = currentState.selectedPhotos else {
                return .empty()
            }
            
            return assets2Datas(media).flatMap { [unowned self] in
                return self.provider.request(target: .addMediaWithFlick(squadId: self.squadId, mediaType: .priture, media: $0, title: title, url: url), model: GeneralModel.Plain.self)
            }.asObservable().map{ result -> Mutation in
                switch result {
                case .success(let plain): return .setUploadSuccess(state: true, toast: plain.message)
                case .failure(let error): return .setToast(error.message)
                }
            }.startWith(.setLoading(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setPhotos(list, isDenied):
            if let unwrappedList = list {
                state.isDenied = nil
                state.photos = unwrappedList
            } else {
                state.photos = nil
                state.isDenied = isDenied
            }
        case .setPhoto(let list):
            if state.selectedPhotos == nil || state.selectedPhotos?.elementsEqual(list) == false {
                state.selectedPhotos = list
            }
        case .setDeletePhoto(let asset):
            var photos = state.selectedPhotos
            photos?.removeAll(where: { $0.localIdentifier == asset.localIdentifier })
            state.selectedPhotos = photos
        case .setAddPhoto(let asset):
            var photos = state.selectedPhotos ?? []
            photos.append(asset)
            state.selectedPhotos = photos
        case .setToast(let s):
            state.isLoading = false
            state.toast = s
        case let .setUploadSuccess(s, toast):
            state.isLoading = false
            state.toast = toast
            state.postSuccess = s
        case .setLoading(let s):
            state.toast = nil
            state.isLoading = s
        }
        return state
    }
    
    // 将PHAsset 转为 Data对象
    private func asset2Data(_ asset: PHAsset) -> Observable<Data> {
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        return Observable.create { (observer) -> Disposable in
            var id: PHImageRequestID
            if #available(iOS 13, *) {
                id = PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { (data, _, _, _) in
                    if let data = data {
                        observer.onNext(data)
                    }
                    observer.onCompleted()
                }
            } else {
                id = PHImageManager.default().requestImageData(for: asset, options: options) { (data, _, orientation, _) in
                    if let data = data {
                        //FIXME: - 需要处理图片旋转问题
                        observer.onNext(data)
                    }
                    observer.onCompleted()
                }
            }
            return Disposables.create {
                PHImageManager.default().cancelImageRequest(id)
            }
        }
    }
    
    // 将PHAsset 转为 Data对象
    private func assets2Datas(_ assets: Array<PHAsset>) -> Observable<Array<Data>> {
        return Observable.create { (observer) -> Disposable in
            
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .none
            
            // 使用多线程下载图片
            var resultDatas = Array<Data>()
            var ids = Array<PHImageRequestID>()
            DispatchQueue.global(qos: .userInitiated).async {
                
                let asyncGroup = DispatchGroup()
                for asset in assets {
                    asyncGroup.enter()
                    
                    if #available(iOS 13, *) {
                        ids.append(PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { (data, _, _, _) in
                            if let data = data {
                                resultDatas.append(data)
                            }
                            asyncGroup.leave()
                        })
                    } else {
                        ids.append(PHImageManager.default().requestImageData(for: asset, options: options) { (data, _, orientation, _) in
                            if let data = data {
                                //FIXME: - 需要处理图片旋转问题
                                resultDatas.append(data)
                            }
                            asyncGroup.leave()
                        })
                    }
                }
            
                asyncGroup.notify(queue: .main, execute: {
                    observer.onNext(resultDatas)
                    observer.onCompleted()
                })
            }
            
            return Disposables.create {
                ids.forEach{ PHImageManager.default().cancelImageRequest($0) }
            }
        }
    }
}
