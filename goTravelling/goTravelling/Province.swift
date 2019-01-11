//
//  Province.swift
//  goTravelling
//
//  Created by smallchen on 2018/12/1.
//  Copyright © 2018 cn.nju.edu.cn. All rights reserved.
//

import UIKit
import MapKit
import os.log

//import AMapFoundationKit
//import AMapSearchKit

/*
 省份类：
 存储省份名称，在该省份存储照片的数组信息;
 存储边界经纬度数组，省会经纬度，左上和右下角经纬度（用于单独显示该省份时使用）,以及用于显示的boundMapRect。
*/

class Province :NSObject,NSCoding{
    
    //MARK:Properties
    
    var name:String
    var photos:[Photo]?
    
    var isArrived:Bool
    
    //var search:AMapSearchAPI
    
    var boundary:[CLLocationCoordinate2D] = []
    
    var capital = CLLocationCoordinate2D()
    
    var midCoordinate = CLLocationCoordinate2D()
    var topLeftCoordinate = CLLocationCoordinate2D()
    var topRightCoordinate = CLLocationCoordinate2D()
    var bottomLeftCoordinate = CLLocationCoordinate2D()
    var bottomRightCoordinate:CLLocationCoordinate2D {
        get{
            return CLLocationCoordinate2DMake(bottomLeftCoordinate.latitude, topRightCoordinate.longitude)
        }
    }
    
    var boundingMapRect:MKMapRect{
        get {
            let topLeft = MKMapPoint.init(topLeftCoordinate)
            let topRight = MKMapPoint.init(topRightCoordinate)
            let bottomLeft = MKMapPoint.init(bottomLeftCoordinate)
            
            return MKMapRect.init(
                x:topLeft.x,
                y:topLeft.y,
                width:fabs(topLeft.x - topRight.x),
                height:fabs(topLeft.y - bottomLeft.y)
            )
        }
    }
    
    
    //MARK:init
    
    init(name:String,photos:[Photo]?){
        self.name = name
        //self.isArrived = arrived
        self.photos = photos
        self.isArrived = (self.photos != nil)
        //self.search = AMapSearchAPI()
        
        guard let properties = Province.plist(name) as? [String : Any],
            let boundaryPoints = properties["boundary"] as? [String] else {return}
        capital = Province.parseCoord(dict: properties, fieldName: "capital")
        midCoordinate = Province.parseCoord(dict: properties, fieldName: "midCoord")
        topLeftCoordinate = Province.parseCoord(dict: properties, fieldName: "topLeftCoord")
        topRightCoordinate = Province.parseCoord(dict: properties, fieldName: "topRightCoord")
        bottomLeftCoordinate = Province.parseCoord(dict: properties, fieldName: "bottomLeftCoord")
    
        
        let cgPoints = boundaryPoints.map { NSCoder.cgPoint(for: $0) }
        boundary = cgPoints.map { CLLocationCoordinate2DMake(CLLocationDegrees($0.x), CLLocationDegrees($0.y)) }
    }
    /*
    func initBoundary(){
        let request = AMapDistrictSearchRequest()
        request.keywords = self.name
        print(self.name)
        request.requireExtension = true
        print("request")
        self.search.aMapDistrictSearch(request)
    }
    */
    
    //MARK: Methods
    
    func updatePhotos(photos:[Photo]?) {
        self.photos?.removeAll()
        self.photos = photos
        Province.saveProvince()
    }
    
    
    //MARK: static function
    
    static func plist(_ plist:String)->Any?{
        guard let filePath = Bundle.main.path(forResource: plist, ofType: "plist"),
            let data = FileManager.default.contents(atPath: filePath) else { return nil }
        
        do {
            return try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        } catch {
            return nil
        }
    }
    
    static func parseCoord(dict: [String: Any], fieldName: String) -> CLLocationCoordinate2D{
        if let coord = dict[fieldName] as? String {
            let point = NSCoder.cgPoint(for: coord)
            return CLLocationCoordinate2DMake(CLLocationDegrees(point.x), CLLocationDegrees(point.y))
        }
        return CLLocationCoordinate2D()
    }
    
    
    //MARK: NSCoding
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("provinces")
    
    struct PropertyKey {
        static let name = "name"
        static let isArrive = "arrive"
        static let photos = "photos"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name,forKey:PropertyKey.name)
        //aCoder.encode(isArrived, forKey: PropertyKey.isArrive)
        //print(isArrived)
        aCoder.encode(photos,forKey:PropertyKey.photos)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.name) as! String
        //let isArrived = aDecoder.decodeObject(forKey:PropertyKey.isArrive) as? Bool
        let photos = aDecoder.decodeObject(forKey:PropertyKey.photos) as? [Photo]
        self.init(name: name,photos:photos)
    }
    
    static func saveProvince(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(provinces, toFile: Province.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    static func loadPhoto()->[Province]?{
        let loadProvinces = NSKeyedUnarchiver.unarchiveObject(withFile: Province.ArchiveURL.path) as? [Province]
        return loadProvinces
    }
    
    
    //MARK: delegate
    /*
    func onDistrictSearchDone(_ request: AMapDistrictSearchRequest!, response: AMapDistrictSearchResponse!) {
        
        for aDistrict in response.districts{
            for subDistrict in aDistrict.districts{
                
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(subDistrict.center.latitude), longitude:CLLocationDegrees(subDistrict.center.longitude))
               print(coordinate)
               self.boundary.append(coordinate)
            }
        }
    }
 */
 
}


//Global variable

let provinceName = ["HeNan","JiangSu","GanSu","AnHui","Aomen","ChongQing","FuJian","GuangDong","GuangXi",
                    "GuiZhou","HaiNan","HeBei","HeiLongJiang","HuBei","HuNan","JiangXi","JiLin",
                    "LiaoNing","NeiMengGu","MingXia","QingHai","Shan3Xi","ShanDong","ShangHai",
                    "ShanXi","SiChuan","TaiWan","TianJin","XiangGang","XinJiang","XiZang","YunNan",
                    "ZheJiang","BeiJing"]

var provinces:[Province] = []

var currentProvince:Province? = nil

