//
//  CreateSquadViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/26.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateSquadViewController: BaseViewController {
    
    private var imageView = UIImageView()
    private var tipsLab = UILabel()
    private var inputField = UITextField()
    private var gradientLayer: CAGradientLayer!
    private var contentView = UIView()
    private var canEditView = UIButton()
    
    var disposeBag = DisposeBag()
    var provider = OnlineProvider<SquadAPI>()
    private var picker = AvatarPicker()
    
    override func setupView() {
        
        view.addSubview(contentView)
        view.theme.backgroundColor = UIColor.background
        
        let rightBarButtonItem = UIBarButtonItem()
        rightBarButtonItem.title = "Next"
        rightBarButtonItem.style = .plain
        rightBarButtonItem.theme.tintColor = UIColor.secondary
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backBarButtonItemDidTapped))
        leftBarButtonItem.theme.tintColor = UIColor.text
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        setupContentView()
    }
    
    private func setupContentView() {
        
        let viewWidth: CGFloat = view.bounds.width
        
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "Squad Placeholder")
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: (viewWidth - 80)/2, y: 0, width: 80, height: 80)
        
        canEditView.contentMode = .center
        canEditView.setImage(UIImage(named: "Edit Group"), for: .normal)
        canEditView.frame = CGRect(x: imageView.frame.maxX - 25, y: imageView.frame.maxY - 25, width: 29, height: 29)
        
        tipsLab.text = "What's your squad name?"
        tipsLab.font = UIFont.systemFont(ofSize: 14)
        tipsLab.textColor = UIColor.black
        tipsLab.textAlignment = .center
        tipsLab.frame = CGRect(x: 0, y: imageView.frame.maxY + 40, width: view.bounds.width, height: 20)
        
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(hexString: "#F7BDB7").cgColor,
                                UIColor(hexString: "#FDDEC8").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        gradientLayer.locations = [0, 1]
        gradientLayer.cornerRadius = 10
        gradientLayer.frame = CGRect(x: 34, y: tipsLab.frame.maxY + 8, width: viewWidth - 2 * 34, height: 44)
        contentView.layer.addSublayer(gradientLayer)
        
        inputField.borderStyle = .none
        inputField.backgroundColor = .white
        inputField.layer.cornerRadius = 8
        inputField.setInputAccessoryView(target: self, selector: #selector(inputAccessoryDidTapped))
        inputField.frame = CGRect(x: gradientLayer.frame.minX + 3, y: gradientLayer.frame.minY + 3, width: gradientLayer.frame.width - 6, height: gradientLayer.frame.height - 6)
        contentView.addSubviews(imageView, tipsLab, inputField, canEditView)
    }
    
    override func setupConstraints() {
        contentView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            } else {
                maker.top.equalTo(topLayoutGuide.snp.bottom).offset(80)
            }
            maker.height.equalTo(220)
        }
    }
    
    override func addTouchAction() {
        
        guard let accountId = User.currentUser()?.id else {
            return
        }
        
        let rightTap = navigationItem.rightBarButtonItem?.rx.tap
        
        rightTap?.subscribe(onNext: { [unowned self] in
            self.view.endEditing(true)
            self.showLoading(offsetY: 0)
        })
        .disposed(by: disposeBag)
        
        rightTap?.flatMap { [unowned self] _ -> Observable<Result<SquadDetail, GeneralError>> in
            guard let data = self.imageView.highlightedImage?.compressImage(toByte: 200000) else {
                return .just(.failure(.custom("Please upload squad avatar!")))
            }
            guard let name = self.inputField.text, !name.isEmpty else {
                return .just(.failure(.custom("Please fill in the name of squad!")))
            }
            return self.provider.request(target: .createSquad(name: name, avator: data, remark: ""), model: SquadDetail.self, atKeyPath: .data).asObservable()
        }
        .flatMap { [unowned self] result -> Observable<Result<SquadDetail, GeneralError>> in
            switch result {
            case .success(let detail):
                
                // 使用本地图片(😁表情), 上传到服务器作为群的默认头像
//                let urlPath = Bundle.main.path(forResource: "normal_channel_avatar", ofType: "jpg")
//                let url = URL(fileURLWithPath: urlPath!)
//                let avatarData = try! Data(contentsOf: url)
                let image = UIImage(named: "Normal Channel")!
                let avatarData = image.jpegData(compressionQuality: 1.0)!
                
                return self.provider.request(target: .createChannel(squadId: detail.id, name: "Main", avatar: avatarData, ownerAccountId: accountId), model: CreateChannel.self, atKeyPath: .data).asObservable().flatMap { result -> Observable<Void> in
                    switch result {
                    case .success(let channel):
                        return self.createGroupsFromTIM(groupId: String(channel.id), groupName: channel.channelName, faceURL: channel.headImgUrl)
                    case .failure:
                        return .empty()
                    }
                }.map{
                    return .success(detail)
                }
            case .failure(let error):
                return Observable.just(.failure(error))
            }
        }
        .subscribe(onNext: { [unowned self] result in
            switch result {
            case .success(let model):
                
                self.hideLoading()
                UserDefaults.standard.topSquad = model.id
                
                let reactor = SquadInvithNewReactor(squadId: model.id)
                let vc = SquadInvithNewViewController(reactor: reactor)
                vc.isHideBackButtonItem = true
                self.navigationController?.pushViewController(vc, animated: true)
            case .failure(let error):
                self.hideLoading()
                if case .loginStatusDidExpired = error {
                    let alert = UIAlertController(title: "Authentication has expired, please log in again", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            User.removeCurrentUser()
                            AuthManager.removeToken()
                            UserDefaults.standard.topSquad = nil
                            Application.shared.presentInitialScreent()
                        }
                    }))
                    self.present(alert, animated: true)
                } else {
                    self.showToast(message: error.message)
                }
                
            }
        })
        .disposed(by: disposeBag)
        
        canEditView.rx.tap
            .flatMap { [unowned self] in
                self.picker.image(optionSet: [.camera, .photo], delegate: self)
            }
            .map{
                if let image = $0.1 { return image }
                return $0.0
            }
            .bind(to: imageView.rx.setHighlightedImage())
            .disposed(by: disposeBag)
    }
    
    @objc
    private func inputAccessoryDidTapped() {
        inputField.resignFirstResponder()
    }
    
    @objc
    private func backBarButtonItemDidTapped() {
        self.dismiss(animated: true)
    }
    
    /// 从TIM中创建一个群
    /// - Parameter groupId: 自定义群组id
    /// - Parameter groupName: 群名称
    /// - Parameter faceURL: 群头像
    /// - Parameter inviteMembers: 准备受邀加入的成员列表
    private func createGroupsFromTIM(groupId: String,
                                     groupName: String,
                                     faceURL: String) -> Observable<Void> {
        return Observable.create { (observer) -> Disposable in
            
            let info = V2TIMGroupInfo()
            info.groupID = groupId
            info.groupType = "Work"
            info.faceURL = faceURL
            info.groupName = groupName
            
            V2TIMManager.sharedInstance()?.createGroup(info, memberList: [], succ: { _ in
                observer.onNext(())
                observer.onCompleted()
            }, fail: { (code, message) in
                observer.onNext(())
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
    }
}
