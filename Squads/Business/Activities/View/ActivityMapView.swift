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
    var geocoder: CLGeocoder!
    var placeholderImageView: UIImageView?
    
    override func setupView() {
        
        geocoder = CLGeocoder()
        
        mapView = MKMapView()
        mapView.layer.cornerRadius = 8
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
    
    
    func setCenterCoordinate(_ coordinate: CLLocationCoordinate2D, zoomLevel: Int, animated: Bool) {
        let zoom = min(zoomLevel, 28)
        let span = coordinateSpanWithMapView(self.mapView, center: coordinate, zoomLevel: zoom)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: animated)
    }
    
    func showAddress(position: SquadLocation) {
        // 经纬度
        let point = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
        let location = CLLocation(latitude: point.latitude, longitude: point.longitude)
        self.setCenterCoordinate(point, zoomLevel: 14, animated: false)
        geocoder.reverseGeocodeLocation(location) { [weak self] (markList, error) in
            if markList?.isEmpty == false && error == nil {
                self?.setAnnotation(title: position.address, coordinate: point)
            }
        }
    }
    
    func openSystemMaps() {
        
//        MKMapItem.openMaps(with: <#T##[MKMapItem]#>, launchOptions: <#T##[String : Any]?#>)
    }
    
    private func setAnnotation(title: String, coordinate: CLLocationCoordinate2D) {
        if mapView.annotations.isEmpty {
            let annotation = MKPointAnnotation()
            annotation.title = title
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        } else {
            let annotation = mapView.annotations.first as? MKPointAnnotation
            annotation?.title = title
            annotation?.coordinate = coordinate
        }
    }
    
    struct Mercator {
        let offset: Double = 268435456
        let radius: Double = 85445659.44705395
    }
    
    var mercator = Mercator()
    
    private func coordinateSpanWithMapView(_ mapView: MKMapView, center coordinate: CLLocationCoordinate2D, zoomLevel: Int) -> MKCoordinateSpan {
        
        let centerPixelX = longitudeToPixelSpaceX(coordinate.longitude)
        let centerPixelY = latitudeToPixelSpaceY(coordinate.latitude)
        
        let zoomExponent = 20 - zoomLevel
        let _zoomScale = pow(2, zoomExponent)
        let zoomScale = NSDecimalNumber(decimal: _zoomScale).doubleValue
        
        let mapSizeInPixels = mapView.bounds.size
        let scaledMapWidth: CGFloat = mapSizeInPixels.width * CGFloat(zoomScale)
        let scaledMapHeight: CGFloat = mapSizeInPixels.height * CGFloat(zoomScale)
        
        let topLeftPixelX = CGFloat(centerPixelX) - (scaledMapWidth / 2)
        let topLeftPixelY = CGFloat(centerPixelY) - (scaledMapHeight / 2)
        
        let minLng: CLLocationDegrees = pixelSpaceXToLongitude(Double(topLeftPixelX))
        let maxLng: CLLocationDegrees = pixelSpaceXToLongitude(Double(topLeftPixelX + scaledMapWidth))
        let longitudeDelta: CLLocationDegrees = maxLng - minLng
        
        let minLat: CLLocationDegrees = pixelSpaceYToLatitude(Double(topLeftPixelY))
        let maxLat: CLLocationDegrees = pixelSpaceYToLatitude(Double(topLeftPixelY + scaledMapHeight))
        let latitudeDelta: CLLocationDegrees = -1 * (maxLat - minLat)
        
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
    
    private func longitudeToPixelSpaceX(_ longitude: Double) -> Double {
        return round(mercator.offset + mercator.radius * longitude * Double.pi/180.0)
    }
    
    private func latitudeToPixelSpaceY(_ latitude: Double) -> Double {
        let a1 = mercator.offset - mercator.radius * Double(logf(1 + sinf(Float(latitude * Double.pi / 180.0))))
        let a2 = Double(sinf(Float(latitude * Double.pi / 180.0)))
        return round(a1/(1 - a2) / 2.0)
    }
    
    private func pixelSpaceXToLongitude(_ pixelX: Double) -> Double {
        return ((round(pixelX) - mercator.offset)/mercator.radius) * 180.0 / Double.pi
    }
    
    private func pixelSpaceYToLatitude(_ pixelY: Double) -> Double {
        return (Double.pi / 2.0 - 2.0 * atan(exp((round(pixelY) - mercator.offset)/mercator.radius))) * 180.0 / Double.pi
    }
    
    func showPlaceholder() {
        if placeholderImageView == nil {
            placeholderImageView = UIImageView()
            placeholderImageView?.isHidden = false
            placeholderImageView?.layer.cornerRadius = 8
            addSubview(placeholderImageView!)
        }
        if let urlPath = Bundle.main.path(forResource: "hangout_placeholder", ofType: "jpeg") {
           placeholderImageView?.image = UIImage(contentsOfFile: urlPath)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mapView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - 20)
        placeholderImageView?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - 20)
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
