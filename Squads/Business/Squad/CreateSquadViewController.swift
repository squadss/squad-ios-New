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
    
    override var allowedCustomBackBarItem: Bool {
        return false
    }
    
    var isShowLeftBarButtonItem: Bool = true
    
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
        
        let buttonItem = UIBarButtonItem()
        buttonItem.title = "Next"
        buttonItem.style = .plain
        buttonItem.theme.tintColor = UIColor.secondary
        navigationItem.rightBarButtonItem = buttonItem
        
        if isShowLeftBarButtonItem {
            let buttonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backBarButtonItemDidTapped))
            buttonItem.theme.tintColor = UIColor.text
            navigationItem.leftBarButtonItem = buttonItem
        }
        
        setupContentView()
    }
    
    private func setupContentView() {
        
        let viewWidth: CGFloat = view.bounds.width
        
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "Avatar Placeholder")
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
        
        let rightTap = navigationItem.rightBarButtonItem?.rx.tap
        
        rightTap?.subscribe(onNext: { [unowned self] in
            self.showLoading(offsetY: 0)
        })
        .disposed(by: disposeBag)
        
        rightTap?
            .flatMap { [unowned self] _ -> Observable<Result<SquadDetail, GeneralError>> in
            guard let data = self.imageView.highlightedImage?.pngData() else {
                return .just(.failure(.custom("Please upload squad avatar!")))
            }
            guard let name = self.inputField.text, !name.isEmpty else {
                return .just(.failure(.custom("Please fill in the name of squad!")))
            }
            return self.provider.request(target: .createSquad(name: name, avator: data, remark: ""), model: SquadDetail.self, atKeyPath: .data).asObservable()
        }
        .subscribe(onNext: { [unowned self] result in
            switch result {
            case .success(let model):
                
                self.hideLoading()
                DataCenter.topSquad = model
                UserDefaults.standard.topSquad = "\(model.id)"
                
                let reactor = SquadInvithNewReactor(squadId: "\(model.id)")
                let vc = SquadInvithNewViewController(reactor: reactor)
                vc.isHideBackButtonItem = true
                self.navigationController?.pushViewController(vc, animated: true)
            case .failure(let error):
                self.hideLoading()
                self.showToast(message: error.message)
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
}
