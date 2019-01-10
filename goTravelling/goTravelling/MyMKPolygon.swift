//
//  MyMKPolygon.swift
//  goTravelling
//
//  Created by smallchen on 2018/12/2.
//  Copyright © 2018 cn.nju.edu.cn. All rights reserved.
//

import UIKit
import MapKit

class MyMKPolygon:NSObject, MKOverlay{
    var coordinate: CLLocationCoordinate2D
    
    var boundingMapRect: MKMapRect
    
    var polygon : MKPolygon
    
    var province:Province
    
    init(province:Province) {
        self.province = province
        self.coordinate = province.midCoordinate
        self.boundingMapRect = province.boundingMapRect
        self.polygon = MKPolygon(coordinates: province.boundary, count:province.boundary.count)
    }
    
    
    
}
