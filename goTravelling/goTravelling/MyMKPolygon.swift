//
//  MyMKPolygon.swift
//  goTravelling
//
//  Created by smallchen on 2018/12/2.
//  Copyright © 2018 cn.nju.edu.cn. All rights reserved.
//

/*
 自定义继承自MKOverlay的MKPolygon类，该类包含一个MKPolygon，以及必要的省份信息
 以此在填充时保证对对应的省份着不同颜色（已到达省份着红色，否则着白色）
 以此在mapView的填充delegate中，保证对省份的识别
 */

import UIKit
import MapKit

class MyMKPolygon:NSObject, MKOverlay{
    
    //MARK:Properties
    
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    var polygon : MKPolygon
    var province:Province
    
    
    //MARK:initialize
    
    init(province:Province) {
        self.province = province
        self.coordinate = province.midCoordinate
        self.boundingMapRect = province.boundingMapRect
        self.polygon = MKPolygon(coordinates: province.boundary, count:province.boundary.count)
    }
    
}
