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
    
    enum CellType<T> {
        case camera
        case photos
        case pirture(T)
    }
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        // 发布成功
        var postSuccess: Bool?
        // 相册资源
        var photos: Array<CellType<PHAsset>>?
        // 选中的图片
        var selectedPhotos: Array<PHAsset>?
    }
    
    var initialState: State
    
    init() {
        initialState = State(postSuccess: false, photos: [CellType.camera,  CellType.pirture(PHAsset()), CellType.pirture(PHAsset()), CellType.pirture(PHAsset()), CellType.pirture(PHAsset()), CellType.pirture(PHAsset()), CellType.photos], selectedPhotos: [PHAsset(), PHAsset(), PHAsset(), PHAsset(), PHAsset()])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
