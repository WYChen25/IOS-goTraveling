//
//  Photo.swift
//  goTravelling
//
//  Created by smallchen on 2018/11/30.
//  Copyright © 2018 cn.nju.edu.cn. All rights reserved.
//

import UIKit
import os.log

class Photo:NSObject,NSCoding{
    
    //MARK: Properties
    var name:String?
    var image:UIImage?
    var message:String?
    
    //MARK:Archiving Paths
    /*
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
     */
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let message = "message"
    }
    
    //MARK:Actions
    init?(name:String?,image:UIImage?,message:String?) {
        //默认皆可为空，但逻辑上这些内容不为空
        self.name = name
        self.image = image
        self.message = message
    }
    
    //MARK:NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name,forKey:PropertyKey.name)
        aCoder.encode(image,forKey:PropertyKey.photo)
        aCoder.encode(message,forKey:PropertyKey.message)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String 
        
        // Because photo is an optional property of Meal, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        let message = aDecoder.decodeObject(forKey: PropertyKey.message) as?String
        
        // Must call designated initializer.
        self.init(name: name, image: photo, message: message)
    }
}
