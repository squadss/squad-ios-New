//
//  CreateEventLocationViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/31.
//  Copyright © 2020 Squads. All rights reserved.
//  兴趣点搜索

import UIKit
import MapKit
import RxSwift
import RxCocoa
import RxDataSources
import CoreLocation

class CreateEventLocationViewController: BaseViewController, CLLocationManagerDelegate {

    var itemSelected: Observable<MKMapItem> {
        return tableView.rx.itemSelected.map { [unowned self] in self.dataSource[$0] }.do(onNext: { [unowned self] _ in
            self.dismiss(animated: true)
        })
    }
    
    private var disposeBag = DisposeBag()
    private var inputField = UITextField()
    private var tableView = UITableView()
    private var cancelBtn = UIButton()
    private var locationManager = CLLocationManager()
    private var region: MKCoordinateRegion?
    private var backgroundLayer = UIView()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, MKMapItem>>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        self.navBarBgAlpha = 0.0
        self.navBarTintColor = .clear
        view.theme.backgroundColor = UIColor.background
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputField.becomeFirstResponder()
    }
    
    override func setupView() {
        
        backgroundLayer.backgroundColor = UIColor(hexString: "#F4F5F4")
        view.addSubview(backgroundLayer)
        
        tableView.rowHeight = 70
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 26, bottom: 0, right: 26)
        tableView.separatorColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
        tableView.register(Reusable.createEventLocationCell)
        view.addSubview(tableView)
        
        let tempView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 30))
        let imageView = UIImageView(frame: CGRect(x: 5, y: 3, width: 24, height: 24))
        imageView.image = UIImage(named: "Search Location")
        tempView.addSubview(imageView)
        inputField.leftView = tempView
        inputField.leftViewMode = .always
        inputField.borderStyle = .none
        inputField.backgroundColor = UIColor(hexString: "#E5E5E7")
        inputField.placeholder = "Search"
        inputField.layer.cornerRadius = 10
        view.addSubview(inputField)
        
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancelBtn.setTitleColor(UIColor(hexString: "#007AFE"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(rightBarButtonItemDidTapped), for: .touchUpInside)
        view.addSubview(cancelBtn)
        
        let leftBarItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(leftBarButtonItemDidTapped))
        navigationItem.leftBarButtonItem = leftBarItem
    }
    
    @objc
    private func leftBarButtonItemDidTapped() {
        dismiss(animated: true)
    }
    
    @objc
    private func rightBarButtonItemDidTapped() {
        dismiss(animated: true)
    }
    
    override func setupConstraints() {
        
        backgroundLayer.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            maker.height.equalTo(110)
            maker.top.equalToSuperview()
        }
        
        cancelBtn.snp.makeConstraints { (maker) in
            maker.width.equalTo(67)
            maker.height.equalTo(36)
            maker.top.equalTo(inputField)
            maker.trailing.equalTo(-9)
        }
        
        inputField.snp.makeConstraints { (maker) in
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(4)
            } else {
                maker.top.equalTo(topLayoutGuide.snp.bottom).offset(4)
            }
            maker.leading.equalToSuperview().inset(20)
            maker.trailing.equalTo(cancelBtn.snp.leading)
            maker.height.equalTo(36)
        }
        
        tableView.snp.makeConstraints { (maker) in
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalTo(topLayoutGuide.snp.top)
            }
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(backgroundLayer.snp.bottom)
        }
    }
    
    override func addTouchAction() {
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, MKMapItem>>(configureCell: { (data, tableView, indexPath, item) in
            let cell = tableView.dequeue(Reusable.createEventLocationCell)!
            cell.titleLab.text = item.name
            cell.contentLab.text = item.placemark.title
            cell.iconView.image = UIImage(named: "CreateEvent Location Black")
            return cell
        })
        
        inputField.rx.text.orEmpty
            .filter{ !$0.isEmpty }
            .throttle(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { [unowned self] text in
                self.requestLocation(key: text)
            }
            .map{ [SectionModel(model: "", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    // 定位失败
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位失败")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //获取到位置后, 就停止定位
        locationManager.stopUpdatingLocation()
        
        let location = locations.last
        let coordinate = location?.coordinate
        
        // 创建一个位置信息对象, 第一个参数为经纬度, 第二个参数为纬度检索范围, 单位是米, 第三个为经度检索范围 单位是米
        if let coordinate = coordinate {
            region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        }
    }
    
    func requestLocation(key: String) -> Observable<Array<MKMapItem>> {
        return Observable.create({ [unowned self] observer in
            
            // 初始化一个检索请求对象
            let req = MKLocalSearch.Request()
            req.naturalLanguageQuery = key
            
            if let region = self.region {
                req.region = region
            }
            
            let search = MKLocalSearch(request: req)
            
            search.start { (response, error) in
                if let unwrappedResponse = response {
                    observer.onNext(unwrappedResponse.mapItems)
                    observer.onCompleted()
                } else {
                    observer.onNext([])
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        })
    }
    
}
