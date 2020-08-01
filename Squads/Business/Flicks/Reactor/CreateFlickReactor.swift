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
    }
    
    enum Mutation {
        case setPhotos(Array<CellType>?, isDenied: Bool)
        case setDeletePhoto(PHAsset)
        case setAddPhoto(PHAsset)
        case setToast(String)
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
    }
    
    var initialState: State
    
    init() {
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
                return Observable.just(.setToast("Wrong operation!"))
            }
        case .addPhoto(let asset):
            if currentState.selectedPhotos == nil
            || currentState.selectedPhotos!.count < 9
            && currentState.selectedPhotos!.contains(asset) == false {
                return Observable.just(.setAddPhoto(asset))
            }
            return Observable.empty()
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
        case .setDeletePhoto(let asset):
            var photos = state.selectedPhotos
            photos?.removeAll(where: { $0.localIdentifier == asset.localIdentifier })
            state.selectedPhotos = photos
        case .setAddPhoto(let asset):
            var photos = state.selectedPhotos ?? []
            photos.append(asset)
            state.selectedPhotos = photos
        case .setToast(let s):
            state.toast = s
        }
        return state
    }
}
