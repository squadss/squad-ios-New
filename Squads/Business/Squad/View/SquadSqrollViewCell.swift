//
//  SquadSqrollViewCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/5.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class SquadSqrollViewCell: BaseTableViewCell {
    
    var disposeBag = DisposeBag()
    var dataSubject = PublishSubject<[String]>()
    
    var tapObservable: Observable<String> {
        return collectionView.rx.itemSelected.map{ [unowned self] in self.dataSource[$0] }
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, String>>!
    
    override func setupView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 97, height: 97)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 2
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(Reusable.squadSqrollCollectionCell)
        collectionView.theme.backgroundColor = UIColor.background
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 0)
        contentView.addSubview(collectionView)
        
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, String>>(configureCell: { (data, collectionView, indexPath, model) -> UICollectionViewCell in
            let cell = collectionView.dequeue(Reusable.squadSqrollCollectionCell, for: indexPath)
            cell.pritureView.kf.setImage(with: model.asURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
            return cell
        })
        
        dataSubject
            .map{ [SectionModel(model: "", items: $0)] }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
}
