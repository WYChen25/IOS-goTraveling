//
//  photoListViewController.swift
//  goTravelling
//
//  Created by smallchen on 2018/11/30.
//  Copyright © 2018 cn.nju.edu.cn. All rights reserved.
//

import UIKit
import os.log
import MapKit

@IBDesignable class photoListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,MKMapViewDelegate {
    
    
    //MARK: Properties
    
    var photos = [Photo]()
    @IBOutlet weak var photoList: UITableView!
    @IBOutlet weak var provinceMapView: MKMapView!
    
    
    //MARK: -Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //根据标识判断seguel种类，决定添加照片或是显示照片。
        switch(segue.identifier ?? "") {
            
            case "AddItem":
                os_log("Adding a new photo.", log: OSLog.default, type: .debug)
            
            case "ShowDetail":
                guard let photoDetailViewController = segue.destination as? PhotoViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
            
                guard let selectedPhotoCell = sender as? photoTableViewCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
            
                guard let indexPath = photoList.indexPath(for: selectedPhotoCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
            
                let selectedPhoto = photos[indexPath.row]
                photoDetailViewController.photo = selectedPhoto
            
            default:
                fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK:Action
    
    @IBAction func unwindToPhotoList(sender:UIStoryboardSegue){
        if let sourceViewController = sender.source as? PhotoViewController, let photo = sourceViewController.photo{
            
            if let selectedIndexPath = photoList.indexPathForSelectedRow {
                //update an existing photo
                photos[selectedIndexPath.row] = photo
                photoList.reloadRows(at: [selectedIndexPath], with: .none)
                
            }
            else{
                let newIndexPath = IndexPath(row: photos.count, section: 0)
                photos.append(photo)
                photoList.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            currentProvince?.updatePhotos(photos: photos)
        }
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:Private Method
    
    private func loadPhotos(){
        let image1 = UIImage(named: "Image")
        guard let photo1 = Photo(name: "test", image: image1, message: "1234") else{
            fatalError("failed to load photo")
        }
        photos += [photo1]
    }
    /*
    private func savePhoto(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(photos, toFile: Photo.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadPhoto()->[Photo]?{
        let loadPhoto = NSKeyedUnarchiver.unarchiveObject(withFile: Photo.ArchiveURL.path) as? [Photo]
        return loadPhoto
    }
    */

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //navigationItem.leftBarButtonItem = editButtonItem
        
        //load photos saved
        //给photoList添加代理
        photoList.delegate = self
        photoList.dataSource = self
        
        //对View初始化
        initView()
        //若检测到有存储的photo，则获得存储的photo，否则采用loadPhoto
        /*
        if let savedPhotos = loadPhoto(){
            photos+=savedPhotos
        }
        else {
            //load sample data
            loadPhotos()
        }
        //photoList.beginUpdates();
        */
    }
    //INIT:
    
    func initView(){
        if let tempProvince = currentProvince {
            let latDelta = fabs(tempProvince.topLeftCoordinate.latitude - tempProvince.bottomRightCoordinate.latitude)
            
            let span = MKCoordinateSpan.init(latitudeDelta:latDelta,longitudeDelta:0.0)
            let region = MKCoordinateRegion.init(center: tempProvince.capital, span: span)
            
            provinceMapView.region = region
            provinceMapView.delegate = self
            provinceMapView.addOverlay(MKPolygon(coordinates: tempProvince.boundary, count:  tempProvince.boundary.count))
            
            if let provincePhotos = tempProvince.photos {
                photos = provincePhotos
            }
        }
    }
    
    //MARK:table view delegate
    //Section 数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    //tableView 的行数
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(photos.count)
        return photos.count
    }
    
    //将table cell的内容加到tableb view中
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "photoTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? photoTableViewCell  else {
            fatalError("The dequeued cell is not an instance of PhotoTableViewCell.")
        }
        
        // Fetches the appropriate photo for the data source layout.
        let photo = photos[indexPath.row]
        
        cell.photoName.text = photo.name
        cell.photoView.image = photo.image
        cell.photoDesc.text = photo.message
        
        return cell
    }
    
    
    //view可左滑删除
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            photos.remove(at: indexPath.row)
            currentProvince?.updatePhotos(photos: photos)
            photoList.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    //MARK: mapView Delegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.lineWidth = CGFloat(3.0)
            polygonView.strokeColor = UIColor.black
            return polygonView
        }
        return MKOverlayRenderer()
    }

}
