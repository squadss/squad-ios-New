//
//  BaseCollectionView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//
import UIKit
import HGPlaceholders
import RxDataSources
import RxSwift
import RxCocoa

class VC1: UIViewController {
    
    var provider = OnlineProvider<UserAPI>()
    
    let layout = UICollectionViewFlowLayout()
    lazy var collection = CollectionView(frame: CGRect(x: 0, y: 100, width: view.bounds.width, height: view.bounds.height - 100), collectionViewLayout: layout)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.backgroundColor = .white
        view.addSubview(collection)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, String>>(configureCell: { (data, collectionView, indexPath, model) -> UICollectionViewCell in
            
            let cell = UICollectionViewCell()
            return cell
        })
        
//        Observable<Array<String>>.just(["1"])
//            .map{ [SectionModel(model: "", items: $0)] }
//            .bind(to: collection.rx.items(dataSource: dataSource))
//            .disposed(by: rx.disposeBag)
        
        collection.rx.actionButtonTapped
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: rx.disposeBag)
        
        provider
            .request(target: .signUp(username: "123", password: "123", rePassword: "123", inviteCode: "123"),
                     model: String.self,
                     atKeyPath: .data)
            .asObservable()
            .debug()
            .compactMap{ $0.error }
            .bind(to: collection.rx.placeholder)
            .disposed(by: rx.disposeBag)
    }
    
}
