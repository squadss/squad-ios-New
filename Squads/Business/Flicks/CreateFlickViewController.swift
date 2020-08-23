//
//  CreateFlickViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/20.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import Photos
import RxSwift
import RxRelay
import RxDataSources
import JXPhotoBrowser
import TZImagePickerController

class CreateFlickViewController: ReactorViewController<CreateFlickReactor>, UICollectionViewDelegateFlowLayout, TZImagePickerControllerDelegate {
    
    // 纵横比
    let aspectRatio: CGFloat = 1.12
    // 最多预览5张图片
    let maxCount: Int = 5
    
    private lazy var contentView = UICollectionView(frame: .zero, collectionViewLayout: contentLayout)
    private var contentLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    private lazy var photoView = UICollectionView(frame: .zero, collectionViewLayout: photoLayout)
    private var photoLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 86, height: 86)
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 10
        return layout
    }()
    
    //相册内的资源
    private var assetsFetchResults: PHFetchResult<PHAsset>!
    private var imageManager: PHCachingImageManager!
    private var contentDataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, PHAsset>>!
    private var photoDataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, CreateFlickReactor.CellType>>!
    private var didFinishPickingPhotos = PublishRelay<Array<PHAsset>>()
    
    private let rightBtn = UIButton()
    private lazy var inputBar = CreateFlickInputView()
    override var inputAccessoryView: UIView? {
        return inputBar
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private let picker = AvatarPicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageManager = PHCachingImageManager()
        view.theme.backgroundColor = UIColor.background
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputBar.textField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageManager.stopCachingImagesForAllAssets()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
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
        rightBtn.setTitle("Post", for: .normal)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        rightBtn.setTitleColor(UIColor(red: 0.925, green: 0.384, blue: 0.337, alpha: 1), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    
    private func setupInputBar() {
        let insetsBottom = UIApplication.shared.keyWindow?.layoutInsets.bottom ?? 0
        inputBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 54 + insetsBottom)
        inputBar.insert.bottom = insetsBottom
        inputBar.backgroundColor = UIColor(hexString: "#F1F1F1")
        inputBar.textField.placeholder = "Add a name..."
        inputBar.textField.font = UIFont.systemFont(ofSize: 16)
        inputBar.textField.theme.textColor = UIColor.textGray
        inputBar.textField.returnKeyType = .done
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
        contentView.register(Reusable.createFlickContentViewCell)
        contentView.alwaysBounceVertical = true
        contentView.scrollsToTop = false
        contentView.keyboardDismissMode = .onDrag
        contentView.backgroundColor = UIColor.white
        contentView.delegate = self
        contentView.showsHorizontalScrollIndicator = false
        contentView.showsVerticalScrollIndicator = false
        
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
        
        let scale = UIScreen.main.scale
        let assetGridThumbnailSize = CGSize(width: photoLayout.itemSize.width * scale, height: photoLayout.itemSize.height * scale)
        
        photoDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, CreateFlickReactor.CellType>>(configureCell: { [unowned self] data, collectionView, indexPath, model in
            let cell = collectionView.dequeue(Reusable.createFlickPhotoViewCell, for: indexPath)
            switch model {
            case .camera:
                cell.pirtureView.layer.borderColor = UIColor.black.cgColor
                cell.pirtureView.image = UIImage(named: "Flicks Camera")
                cell.pirtureView.contentMode = .center
            case .photos:
                cell.pirtureView.layer.borderColor = UIColor.black.cgColor
                cell.pirtureView.image = UIImage(named: "Flicks Photos")
                cell.pirtureView.contentMode = .center
            case .pirture:
                cell.pirtureView.layer.borderColor = UIColor.clear.cgColor
                cell.pirtureView.contentMode = .scaleAspectFill
                let asset = self.assetsFetchResults[indexPath.row]
                self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize, contentMode: .aspectFill, options: nil) { (image, nfo) in
                    cell.pirtureView.image = image
                }
            }
            return cell
        })
        
        reactor.state
            .compactMap{ $0.photos }
            .map{ [SectionModel(model: "", items: $0)] }
            .bind(to: photoView.rx.items(dataSource: photoDataSource))
            .disposed(by: disposeBag)
        
        contentDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, PHAsset>>(configureCell: { data, collectionView, indexPath, asset in
            
            let layout = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
            let targetSize = CGSize(width: layout.itemSize.width * scale, height: layout.itemSize.height * scale)
            
            let cell = collectionView.dequeue(Reusable.createFlickContentViewCell, for: indexPath)
            self.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { (image, nfo) in
                cell.pirtureView.setImage(image, for: .normal)
            }
            
            cell.closeBtnDidTapped
                .map { Reactor.Action.deletePhoto(asset) }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            
            cell.pirtureView.rx.tap
                .subscribe(onNext: { [unowned self] in
                    let browser = JXPhotoBrowser()
                    browser.numberOfItems = { reactor.currentState.selectedPhotos?.count ?? 0 }
                    browser.reloadCellAtIndex = { context in
                        let browerCell = context.cell as? JXPhotoBrowserImageCell
                        self.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { (image, nfo) in
                            browerCell?.imageView.image = image
                        }
                    }
                    browser.cellClassAtIndex = { _ in JXPhotoBrowserImageCell.self }
                    browser.pageIndex = reactor.currentState.selectedPhotos?.firstIndex(of: asset) ?? 0
                    browser.show()
                })
                .disposed(by: cell.disposeBag)
            
            return cell
        })
        
        reactor.state
            .compactMap{ $0.selectedPhotos }
            .map{ [SectionModel(model: "", items: $0)] }
            .bind(to: contentView.rx.items(dataSource: contentDataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.toast }
            .bind(to: rx.toastNormal)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.isLoading }
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        requestAuthorization()
            .subscribeOn(MainScheduler.instance)
            .map{ Reactor.Action.loadPhotos(count: $0, status: $1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        photoView.rx.itemSelected
            .filter{ [unowned self] in self.photoDataSource[$0] == .pirture }
            .map { [unowned self] indexPath in
                let asset = self.assetsFetchResults[indexPath.row]
                return Reactor.Action.addPhoto(asset)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        photoView.rx.itemSelected
            .filter{ [unowned self] in self.photoDataSource[$0] == .photos }
            .subscribe(onNext: { [unowned self] _ in
                if let pickerController = TZImagePickerController(maxImagesCount: 9, delegate: self) {
                    let assets: [PHAsset] = reactor.currentState.selectedPhotos ?? []
                    pickerController.selectedAssets = NSMutableArray(array: assets)
                    pickerController.modalPresentationStyle = .fullScreen
                    self.present(pickerController, animated: true)
                } else {
                    self.showToast(message: "Unknown")
                }
            })
            .disposed(by: disposeBag)
        
        photoView.rx.itemSelected
            .filter{ [unowned self] in self.photoDataSource[$0] == .camera }
            .flatMap{ [unowned self] _ in self.picker.camera(delegate: self) }
            .compactMap {
                if let asset = $0.2 { return Reactor.Action.addPhoto(asset) }
                return nil
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rightBtn.rx.tap
            .map{ [unowned self] in
                let text = self.inputBar.textField.text ?? ""
                return Reactor.Action.uploadFlick(title: text, url: "")
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        inputBar.textField.rx.text.orEmpty
            .map{
                if reactor.currentState.selectedPhotos?.isEmpty == false {
                    return !$0.isEmpty
                }
                return false
            }
            .bind(to: rightBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        didFinishPickingPhotos
            .map { Reactor.Action.setPhoto($0) }
            .bind(to: reactor.action)
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
    
    @objc
    private func keyboardWillShowNotification(_ notification: Notification) {
        guard inputBar.transform == .identity else { return }
        let insetsBottom = UIApplication.shared.keyWindow?.layoutInsets.bottom ?? 0
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration ?? 0.25) {
            self.inputBar.transform = CGAffineTransform(translationX: 0, y: insetsBottom)
        }
    }
    
    @objc
    private func keyboardWillHideNotification(_ notification: Notification) {
        guard inputBar.transform != .identity else { return }
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration ?? 0.25) {
            self.inputBar.transform = .identity
        }
    }
    
    private func requestAuthorization() -> Observable<(Int, PHAuthorizationStatus)> {
        return Observable.create { [unowned self] (observer) -> Disposable in
            PHPhotoLibrary.requestAuthorization { [unowned self] (state) in
                
                guard state == .authorized else {
                    observer.onNext((0, state))
                    observer.onCompleted()
                    return
                }
                
                //列出所有系统的智能相册
                let options = PHFetchOptions()
                let collection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: options)
                // 通过外部传入的筛选条件, 列出所有相册里的照片 并赋值给 albumList
                self.convertCollection(collection: collection, observer: observer)
                
                //列出所有用户创建的相册
                let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
                self.convertCollection(collection: userCollections as! PHFetchResult<PHAssetCollection>, observer: observer)
                
                let selectCount = min(self.assetsFetchResults.count, self.maxCount)
                observer.onNext((selectCount, .authorized))
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
 
    //转化处理获取到的相册
    private func convertCollection(collection: PHFetchResult<PHAssetCollection>, observer: RxSwift.AnyObserver<(Int, PHAuthorizationStatus)>) {
        for i in 0..<collection.count {
            //获取当前相册内的所有照片
            let resultOptions = PHFetchOptions()
            resultOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            resultOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            
            //得到一个相册,一个集合就是一个相册
            let c = collection[i]
            let assetsFetchResult = PHAsset.fetchAssets(in: c, options: resultOptions)
            //过滤掉没有照片的空相册
            if assetsFetchResult.count > 0 && c.localizedTitle == "Recents" {
                //reloadData
                self.assetsFetchResults = assetsFetchResult
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 3
        return CGSize(width: width, height: width * aspectRatio + 10)
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        guard let assetsList = assets as? [PHAsset] else { return }
        didFinishPickingPhotos.accept(assetsList)
    }
}
