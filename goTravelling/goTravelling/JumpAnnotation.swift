//
//  JumpAnnotation.swift
//  goTravelling
//
//  Created by smallchen on 2018/12/2.
//  Copyright © 2018 cn.nju.edu.cn. All rights reserved.
//

import UIKit
import MapKit

class JumpAnnotation: NSObject,MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var province:Province
    var title:String?
    var image:UIImage?
    
    init(province:Province) {
        self.province = province
        self.title = province.name
        self.coordinate = province.capital
        if province.isArrived == true {
            image = UIImage(named: "BlueLandMark")
        }
        else{
            image = UIImage(named: "YellowLandMark")
        }
        print(self.coordinate)
    }
    
}
