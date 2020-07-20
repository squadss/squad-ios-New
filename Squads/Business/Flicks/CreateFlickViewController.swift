//
//  CreateFlickViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/20.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import Photos
import RxDataSources

class CreateFlickViewController: ReactorViewController<CreateFlickReactor>, UICollectionViewDelegateFlowLayout {
    
    // 纵横比
    let aspectRatio: CGFloat = 1.12
    
    private lazy var inputBar = CreateFlickInputView()
    private var contentLayout = UICollectionViewFlowLayout()
    private lazy var contentView = UICollectionView(frame: .zero, collectionViewLayout: contentLayout)
    private var photoLayout = UICollectionViewFlowLayout()
    private lazy var photoView = UICollectionView(frame: .zero, collectionViewLayout: photoLayout)
    
    private var photoDataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, CreateFlickReactor.CellType<PHAsset>>>!
    private var contentDataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, PHAsset>>!
    
    override var inputAccessoryView: UIView? {
        return inputBar
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputBar.textField.becomeFirstResponder()
    }
    
    override func setupView() {
        setupNavigationBarItem()
        setupInputBar()
        setupCollectionView()
    }
    
    private func setupNavigationBarItem() {
        
        //自定义导航栏按钮
        let leftBtn = UIButton()
        leftBtn.setTitle("Cancel", for: .normal)
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        leftBtn.theme.titleColor(from: UIColor.text, for: .normal)
        leftBtn.addTarget(self, action: #selector(leftBtnDidTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        //自定义右导航按钮
        let rightBtn = UIButton()
        rightBtn.setTitle("Post", for: .normal)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        rightBtn.setTitleColor(UIColor(red: 0.925, green: 0.384, blue: 0.337, alpha: 1), for: .normal)
        rightBtn.addTarget(self, action: #selector(rightBtnBtnDidTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    
    private func setupInputBar() {
        inputBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 54)
        inputBar.backgroundColor = UIColor(hexString: "#F1F1F1")
        inputBar.textField.text = "Add a name..."
        inputBar.textField.font = UIFont.systemFont(ofSize: 16)
        inputBar.textField.theme.textColor = UIColor.textGray
        inputBar.textField.returnKeyType = .search
        if #available(iOS 13.0, *) {
            inputBar.textField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [
                .foregroundColor: UIColor(red: 0.571, green: 0.571, blue: 0.571, alpha: 1),
                .font: UIFont.systemFont(ofSize: 16),
            ])
        } else {
            inputBar.textField.placeholder = "Search"
            inputBar.textField.setValue(UIColor(red: 0.571, green: 0.571, blue: 0.571, alpha: 1), forKeyPath: "_placeholderLabel.textColor")
            inputBar.textField.setValue(UIFont.systemFont(ofSize: 16), forKeyPath: "_placeholderLabel.font")
        }
    }
    
    private func setupCollectionView() {
        
        contentLayout.scrollDirection = .vertical
        contentLayout.minimumLineSpacing = 0
        contentLayout.minimumInteritemSpacing = 0
        
        contentView.register(Reusable.createFlickContentViewCell)
        contentView.alwaysBounceVertical = true
        contentView.scrollsToTop = false
        contentView.keyboardDismissMode = .onDrag
        contentView.backgroundColor = UIColor.white
        contentView.delegate = self
        contentView.showsHorizontalScrollIndicator = false
        contentView.showsVerticalScrollIndicator = false
        
        photoLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        photoLayout.scrollDirection = .horizontal
        photoLayout.itemSize = CGSize(width: 86, height: 86)
        photoLayout.minimumLineSpacing = 3
        photoLayout.minimumInteritemSpacing = 10
        
        photoView.register(Reusable.createFlickPhotoViewCell)
        photoView.backgroundColor = UIColor.white
        photoView.scrollsToTop = false
        
        view.addSubviews(photoView, contentView)
    }
    
    override func setupConstraints() {
        
        photoView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                maker.top.equalTo(topLayoutGuide.snp.bottom)
            }
            maker.height.equalTo(110)
        }
        
        contentView.snp.makeConstraints { (maker) in
            maker.leading.equalTo(14)
            maker.trailing.equalToSuperview()
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
            maker.top.equalTo(photoView.snp.bottom).offset(6)
        }
    }
    
    override func bind(reactor: CreateFlickReactor) {
        
        photoDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, CreateFlickReactor.CellType<PHAsset>>>(configureCell: { data, collectionView, indexPath, model in
            let cell = collectionView.dequeue(Reusable.createFlickPhotoViewCell, for: indexPath)
            switch model {
            case .camera:
                cell.pirtureView.layer.borderWidth = 1
                cell.pirtureView.layer.borderColor = UIColor.black.cgColor
                cell.pirtureView.image = UIImage(named: "Flicks Camera")
                cell.pirtureView.contentMode = .center
            case .photos:
                cell.pirtureView.layer.borderWidth = 1
                cell.pirtureView.layer.borderColor = UIColor.black.cgColor
                cell.pirtureView.image = UIImage(named: "Flicks Photos")
                cell.pirtureView.contentMode = .center
            case .pirture(let asset):
                cell.pirtureView.contentMode = .scaleAspectFill
            }
            return cell
        })
        
        reactor.state
            .compactMap{ $0.photos }
            .map{ [SectionModel(model: "", items: $0)] }
            .bind(to: photoView.rx.items(dataSource: photoDataSource))
            .disposed(by: disposeBag)
        
        contentDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, PHAsset>>(configureCell: { data, collectionView, indexPath, model in
            
            let cell = collectionView.dequeue(Reusable.createFlickContentViewCell, for: indexPath)
            cell.pirtureView.kf.setImage(with: URL(string: "http://image.biaobaiju.com/uploads/20180803/23/1533309823-fPyujECUHR.jpg"), for: .normal, placeholder: UIImage(named: "Member Placeholder"), options: nil, progressBlock: nil, completionHandler: nil)
            
            cell.pirtureView.rx.tap
                .subscribe(onNext: { [unowned self] in
                    //TODO: 图片预览
                    self.showToast(message: "PirtureView")
                })
                .disposed(by: cell.disposeBag)
            
            return cell
        })
        
        reactor.state
            .compactMap{ $0.selectedPhotos }
            .map{ [SectionModel(model: "", items: $0)] }
            .bind(to: contentView.rx.items(dataSource: contentDataSource))
            .disposed(by: disposeBag)
    }
    
    @objc
    private func leftBtnDidTapped() {
        dismiss(animated: true)
    }
    
    @objc
    private func rightBtnBtnDidTapped() {
        dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 3
        return CGSize(width: width, height: width * aspectRatio + 10)
    }
}
