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

class SquadSqrollViewCell: BaseTableViewCell, UICollectionViewDataSource {
    
    var disposeBag = DisposeBag()
    
    var tapObservable: Observable<URL> {
        return collectionView.rx.itemSelected.map{ [unowned self] in self.dataSource[$0.row] }
    }
    
    var dataSource: [URL]! {
        didSet { collectionView.reloadData() }
    }
    
    private var collectionView: UICollectionView!
    
    override func setupView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 97, height: 97)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 2
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(Reusable.squadSqrollCollectionCell)
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 0)
        collectionView.dataSource = self
        contentView.addSubview(collectionView)
        contentView.theme.backgroundColor = UIColor.background
        theme.backgroundColor = UIColor.background
        collectionView.theme.backgroundColor = UIColor.background
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource == nil ? 0 : dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = dataSource[indexPath.row]
        let cell = collectionView.dequeue(Reusable.squadSqrollCollectionCell, for: indexPath)
        cell.pritureView.kf.setImage(with: model, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        return cell
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
