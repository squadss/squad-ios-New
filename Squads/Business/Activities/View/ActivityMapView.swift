//
//  ActivityMapView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/8/18.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import MapKit

class ActivityMapView: BaseView {
    
    var mapView: MKMapView!
    
    override func setupView() {
        
        mapView = MKMapView()
        mapView.mapType = .standard //显示标准地图
        mapView.isScrollEnabled = true //是否可以滚动
        mapView.isZoomEnabled = true //是否可以缩放
        mapView.isRotateEnabled = true //是否可以旋转
        mapView.showsBuildings = true //显示建筑物
        mapView.showsCompass = true //显示指南针
        mapView.showsPointsOfInterest = true    //显示兴趣点
        mapView.showsScale = false  //显示比例尺
        mapView.showsTraffic = false //显示交通
//        mapView.set
        addSubview(mapView)
        
        //显示用户位置
        
    }
    
//    func addAnnotationWithCoordinate(_ center: CLLocationCoordinate2D, title: String, subtitle: String) -> MKAnnotation {
////        MKAnnotation.
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mapView.frame = bounds
    }
}

//class ActivityAnnotation: MKAnnotation {
//
//    var coordinate: CLLocationCoordinate2D {
//
//    }
//
//    var title: String? {
//
//    }
//
//    var subtitle: String? {
//
//    }
//
//    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
//        self.coordinate = coordinate
//        self.title = title
//        self.subtitle = subtitle
//    }
//}
