//
//  ViewController.swift
//  goTravelling
//
//  Created by smallchen on 2018/11/29.
//  Copyright © 2018 cn.nju.edu.cn. All rights reserved.
//

import UIKit
import os.log

class PhotoViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {
    
    //MARK:Properties
    
    @IBOutlet weak var photoNameTextField: UITextField!
    @IBOutlet weak var travelPhoto: UIImageView!
    @IBOutlet weak var thinkTexView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
     This value is either passed by `MealTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new meal.
     */
    var photo:Photo?
    
    //MARK: Help Properties
    var flag = false
    var flagNameText = false
    var str = String.init();
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        photoNameTextField.delegate = self
        thinkTexView.delegate = self
        
        //setup meals if editing an exiting meal
        if let photo = photo {
            navigationItem.title = photo.name
            photoNameTextField.text = photo.name
            travelPhoto.image = photo.image
            thinkTexView.text = photo.message
        }
    }
    
    //MARK:TextField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hiden keyboard
        textField.resignFirstResponder();
        return true;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveButton.isEnabled = true
        //默认textField内容为“no name photo”
        if photoNameTextField.text! == "" {
            photoNameTextField.text = "no name photo"
            flagNameText = false
        }
        navigationItem.title = photoNameTextField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //saveButton is not valid when you input something
        saveButton.isEnabled = false
        if !flagNameText {
            photoNameTextField.text = ""
            flagNameText = true
        }
    }
    
    //MARK:UIImagePickController delegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //dismiss the picker if the user cancle
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //从照片库取得图片
        guard let selectImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        travelPhoto.image = selectImage
        
        dismiss(animated: true, completion:nil)
    }
    
    //MARK:TextView delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        //开始编辑时textView上移防止被键盘遮挡
        UIView.beginAnimations("animations", context: nil)
        //设置动画时长
        UIView.setAnimationDuration(0.2)
        //从当前位置移动
        UIView.setAnimationBeginsFromCurrentState(true)
        //移动距离
        self.view.frame = CGRect.init(x: self.view.frame.origin.x, y: self.view.frame.origin.y-310, width: self.view.frame.size.width, height: self.view.frame.size.height)
        //动画结束
        UIView.commitAnimations()
        
        //第一次输入删除placeholder内容
        if !flag {
            thinkTexView.text = ""
            flag = true
        }
        
        saveButton.isEnabled = false
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        //编辑结束后恢复textView位置
        UIView.beginAnimations("animations", context: nil)
        UIView.setAnimationDuration(0.2)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.view.frame = CGRect.init(x: self.view.frame.origin.x, y: self.view.frame.origin.y+310, width: self.view.frame.size.width, height: self.view.frame.size.height)
        UIView.commitAnimations()
        saveButton.isEnabled = true
        
        //默认textView内容为no thoughts
        if thinkTexView.text! == "" {
            thinkTexView.text = "no thoughts"
            flag = false
        }
        return true
    }
    
    //MARK:Nagivation
    
    @IBAction func cancle(_ sender: UIBarButtonItem) {
        //depend on  style of presentation
        let isPresentingInAddPhotoMode = presentingViewController is UINavigationController
        
        if isPresentingInAddPhotoMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The photoViewController is not inside a nagivation controller")
        }
    }
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = photoNameTextField.text ?? ""
        let image = travelPhoto.image
        let message = thinkTexView.text ?? ""
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        photo = Photo(name: name, image: image, message: message)
    }
    
    //MARK:Actions
    //从相册选择照片
    @IBAction func pickImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        //Hiden keyboard
        photoNameTextField.resignFirstResponder()
        
        let imagePickController = UIImagePickerController()
        imagePickController.sourceType = .photoLibrary
        
        imagePickController.delegate = self
        
        present(imagePickController, animated: true, completion: nil)
    }
    
    //按下屏幕隐藏键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: Private Methods
    
    
    
    
}

