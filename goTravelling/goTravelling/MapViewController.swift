//
//  MapViewController.swift
//  goTravelling
//
//  Created by smallchen on 2018/12/1.
//  Copyright © 2018 cn.nju.edu.cn. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    var chinaBoundary:[CLLocationCoordinate2D] = []
    
    
    //let provinceName = ["JiangSu","HeNan","GanSu"]
    
    var chinaMidCoordinate = CLLocationCoordinate2D()
    var chinaTopLeftCoordinate = CLLocationCoordinate2D()
    var chinaTopRightCoordinate = CLLocationCoordinate2D()
    var chinaBottomLeftCoordinate = CLLocationCoordinate2D()
    var chinaBottomRightCoordinate:CLLocationCoordinate2D {
        get{
            return CLLocationCoordinate2DMake(chinaBottomLeftCoordinate.latitude, chinaTopRightCoordinate.longitude)
        }
    }
    
    var boundingMapRect:MKMapRect{
        get {
            let topLeft = MKMapPoint.init(chinaTopLeftCoordinate)
            let topRight = MKMapPoint.init(chinaTopRightCoordinate)
            let bottomLeft = MKMapPoint.init(chinaBottomLeftCoordinate)
            
            return MKMapRect.init(
                x:topLeft.x,
                y:topLeft.y,
                width:fabs(topLeft.x - topRight.x),
                height:fabs(topLeft.y - bottomLeft.y)
            )
        }
    }

    //MARK: View did load
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initChina()
        let latDelta = fabs(chinaTopLeftCoordinate.latitude - chinaBottomRightCoordinate.latitude)
        
        let span = MKCoordinateSpan.init(latitudeDelta: latDelta, longitudeDelta: 0.0)
        let region = MKCoordinateRegion.init(center: chinaMidCoordinate, span: span)
        
        mapView.region = region
        addAnnotation()
        mapView.delegate = self
        addBoundary()
    }
    
    //MARK: INIT
    
    //初始化中国地理信息，用于主界面显示
    func initChina(){
        guard let properties = Province.plist("China") as? [String:Any],
            let boundaryPoints = properties["Boundary"] as? [String] else {return}
        
        chinaMidCoordinate = Province.parseCoord(dict: properties, fieldName: "ChinaMidCoord")
        chinaTopLeftCoordinate = Province.parseCoord(dict: properties, fieldName: "ChinaTopLeftCoord")
        chinaTopRightCoordinate = Province.parseCoord(dict: properties, fieldName: "ChinaTopRightCoord")
        chinaBottomLeftCoordinate = Province.parseCoord(dict: properties, fieldName: "ChinaBottomLeftCoord")
        
        let cgPoints = boundaryPoints.map { NSCoder.cgPoint(for: $0) }
        chinaBoundary = cgPoints.map { CLLocationCoordinate2DMake(CLLocationDegrees($0.x), CLLocationDegrees($0.y)) }
        
        if let loadProvinces = Province.loadPhoto() {
            provinces = loadProvinces
        }
        else {
 
            for name in provinceName {
                var province = Province(name: name,photos:nil)
                //province.initBoundary()
                provinces.append(province)
            }
        }
    }

    //添加边界和填充区域
    func addBoundary(){
        
        mapView.addOverlay(MKPolygon(coordinates: chinaBoundary, count: chinaBoundary.count))
        //print(province.boundary[4])
        for pro in provinces {
            mapView.addOverlay(MyMKPolygon(province: pro))
        }
    }
    //添加大头针
    func addAnnotation(){
        for pro in provinces {
            let annotation = JumpAnnotation(province: pro)
            mapView.addAnnotation(annotation)
        }
    }
    
    //重新显示地图，刷新填充区域和大头针的显示
    func paintProvince(province:Province){
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        currentProvince = province
        currentProvince?.isArrived = true
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "provinceView")
        navigationController?.pushViewController(viewController ?? UIViewController(), animated: true)
        addBoundary()
        addAnnotation()
    }

    
    //点击已去过的省份，调用该方法显示已存照片
    func showDetail(province:Province){
        print("touch the button show")
        currentProvince = province
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "provinceView")
        navigationController?.pushViewController(viewController ?? UIViewController(), animated: true)
        //self.present(viewController ?? UIViewController(), animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}

//Mark：MapView Delegate

extension MapViewController:MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.green
            return lineView
        }
        else if overlay is MKPolygon {
            //let polygonView = MKPolygonRenderer(overlay: overlay)
            //polygonView.fillColor = UIColor.red
            //polygonView.strokeColor = UIColor.red
            //polygonView.lineWidth = CGFloat(1.0)
            //return polygonView
        }
        else if overlay is MyMKPolygon {
            if let myOverlay = overlay as? MyMKPolygon{
                let polygonView = MKPolygonRenderer(overlay: myOverlay.polygon)
                let paintProvince = myOverlay.province
                if paintProvince.isArrived == true{
                    polygonView.strokeColor = UIColor.black
                    polygonView.lineWidth = CGFloat(1.0)
                    polygonView.fillColor = UIColor.red
                }
                else {
                    polygonView.strokeColor = UIColor.black
                    polygonView.lineWidth = CGFloat(1.0)
                    polygonView.fillColor = UIColor.white
                }
                
                return polygonView
            }
        }
        
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let jumpAnnotation = annotation as? JumpAnnotation {
            
            let annotationView = JumpAnnotationView(annotation: jumpAnnotation, reuseIdentifier: jumpAnnotation.title)
            
            annotationView.canShowCallout = true
            if jumpAnnotation.province.isArrived == true{
                let paintButton = UIButton(type: .detailDisclosure)
                //paintButton.backgroundColor = UIColor.black
                annotationView.rightCalloutAccessoryView = paintButton
            }
            else {
                let paintButton = UIButton(type: .contactAdd)
                annotationView.rightCalloutAccessoryView = paintButton
            }
            
            return annotationView
        }
        return JumpAnnotationView(annotation:annotation, reuseIdentifier: "wrong")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? JumpAnnotation {
            if annotation.province.isArrived == true{
                showDetail(province: annotation.province)
            }
            else {
                paintProvince(province: annotation.province)
            }
        }
        
    }
}
