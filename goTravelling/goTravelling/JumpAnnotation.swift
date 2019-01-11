//
//  JumpAnnotation.swift
//  goTravelling
//
//  Created by smallchen on 2018/12/2.
//  Copyright © 2018 cn.nju.edu.cn. All rights reserved.
//
/*
 继承自MKAnnomation,细节同MyMKPolygon；
 用于对省份区别显示。
 */

import UIKit
import MapKit

class JumpAnnotation: NSObject,MKAnnotation {
    
    //MARK:Properties
    
    var coordinate: CLLocationCoordinate2D
    var province:Province
    var title:String?
    var image:UIImage?
    
    
    //MARK:Initialize
    
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
        //print(self.coordinate)
    }
    
}
