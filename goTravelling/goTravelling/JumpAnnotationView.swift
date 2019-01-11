//
//  JumpAnnotationView.swift
//  goTravelling
//
//  Created by smallchen on 2018/12/2.
//  Copyright © 2018 cn.nju.edu.cn. All rights reserved.
//
/*
 自定义的MKAnnotationView，用于显示所需要的自定义图标。
 */

import UIKit
import MapKit

class JumpAnnotationView: MKAnnotationView {
    
    //MARK:Initialize
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        guard let jumpAnnotation = self.annotation as? JumpAnnotation else {
            return
        }
        image = jumpAnnotation.image
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
