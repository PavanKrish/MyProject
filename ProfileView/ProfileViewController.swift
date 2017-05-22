//
//  ProfileViewController.swift
//  ProfileView
//
//  Created by User on 5/17/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import IHKeyboardAvoiding


// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class ProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var genderTable: UITableView!
    @IBOutlet weak var hobby: UITextField!
    @IBOutlet weak var bgColor: UILabel!
    @IBOutlet weak var colorTable: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var avoidingView: UIView!
    
    var firebase: FIRDatabaseReference!
    var imagePicker: UIImagePickerController = UIImagePickerController()
    var bgBool: Bool = true
    var genderBool: Bool = true
    var strLabel = UILabel()
    var activityIndicator = UIActivityIndicatorView()
    var messageFrame = UIView()
    
    var genderArray: [String] = ["Male", "Female"]
    var colorArray: [String] = ["Red","Blue", "Green", "Yellow", "Grown", "Brown", "Orange", "White"]
    var Profiles: Profile!
    var ProfileArray: [Profile]!
    var profiles_edit: [Profile] = [Profile]()
    var selectID: String!
    var edit: Bool = false
    
    
    var presentationAnimation: CAAnimationGroup {
        get{
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.fromValue = 0.0
            fadeAnimation.toValue = 1.0
            fadeAnimation.duration = 0.3
            fadeAnimation.fillMode = kCAFillModeForwards
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.toValue = 1.0
            scaleAnimation.fromValue = 0.8
            scaleAnimation.duration = 0.3
            scaleAnimation.fillMode = kCAFillModeForwards
            
            let groupAnimation = CAAnimationGroup()
            groupAnimation.duration = 0.3
            groupAnimation.animations = [fadeAnimation, scaleAnimation]
            groupAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            return groupAnimation
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.progressBarDisplayer(msg: "Loading", true)
        KeyboardAvoiding.avoidingView = self.avoidingView
        //Firebase reference path
        self.firebase = FIRDatabase.database().reference()
        //ImagePicker Delegate confirm
        self.imagePicker.delegate = self
        self.genderTable.isHidden = true
        self.colorTable.isHidden = true
        //specificial cell register
        self.genderTable.register(UITableViewCell.self, forCellReuseIdentifier: "gender")
        self.colorTable.register(UITableViewCell.self, forCellReuseIdentifier: "color")
        
        //self.edit == true
        if self.edit == true {
            
            
            
            self.id.text = self.Profiles.id
            self.id.isEnabled = false
            self.name.text = self.Profiles.name
            self.name.isEnabled = false
            self.age.text = self.Profiles.age
            //self.age.isEnabled = false
            self.gender.text = self.Profiles.gender
            self.hobby.text = self.Profiles.hobby
            self.bgColor.text = self.Profiles.bgColor
            self.profileImage.image = self.Profiles.image
        }else {
            self.deleteButton.isHidden = true
            self.deleteButton.isEnabled = true
        }
        self.messageFrame.removeFromSuperview()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.view.layer.removeAllAnimations()
        self.view.layer.add(presentationAnimation, forKey: "present")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Making ProgressView.
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        print(msg)
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 245, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.white
        messageFrame = UIView(frame: CGRect(x: view.frame.midX - 100, y: view.frame.midY - 25 , width: 215, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.5)
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        view.addSubview(messageFrame)
    }
    
    
    //textFieldDelegate method
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        KeyboardAvoiding.avoidingView = self.avoidingView
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.becomeFirstResponder()
        return true
    }
    
    @IBAction func DeleteButton(_ sender: UIButton) {
        
        firebase.child("profile").child(self.id.text!).removeValue()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SaveButton(_ sender: UIBarButtonItem) {
        //Receiving data from textField and Label.
        let idText = self.id.text!
        let nameText = self.name.text!
        let ageText = self.age.text!
        let genderText = self.gender.text!
        let hobbyText = self.hobby.text
        var bgcolorText: String? = nil
        bgcolorText = ""
        if self.bgColor.text == bgcolorText {
            if self.gender.text == "  Male" {
                bgcolorText = "  Blue"
            }else if self.gender.text == "  Female" {
                bgcolorText = "  Green"
            }
        }else {
            bgcolorText = self.bgColor.text
        }
        
        //getting image URL from library or photoAlbum.
        var data: NSData = NSData()
        if let image = self.profileImage.image {
            data = UIImageJPEGRepresentation(image, 0.1)! as NSData
        }
        let imageURL = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        
        // Main data to upload into Firebase.
        let profile: NSDictionary = ["id": idText, "name": nameText, "age": ageText, "gender": genderText, "hobby": hobbyText!, "bgColor": bgcolorText!, "image_URL": imageURL] as NSDictionary
        
        //Save function to Firebase.
        if self.edit == false {
            
            if idText == "" {
                let alert = UIAlertController(title: "Sorry", message: "User can not leave the Profile view", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    print("OK")
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                //compaire ID to avoid duplicating.
                var duplicate: Bool = true
                //when user upload the first profile data on firebase.
                if self.ProfileArray.count == 0 {
                    
                    //add firebase child node
                    let child = ["/profile/\(String(describing: idText))": profile]
                    //Write data to Firebase
                    firebase.updateChildValues(child)
                    
                }else {
                    for item in self.ProfileArray {
                        if String(describing: item.id) == String(describing: idText) {
                            let alert = UIAlertController(title: "Sorry", message: "Your profile ID was duplicated. Please input new ID again!", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                                print("OK")
                            }
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                            duplicate = true
                            break
                        }else {
                            duplicate = false
                            
                        }
                    }
                    
                    if duplicate == false{
                        self.progressBarDisplayer(msg: "Uploading...", true)
                        //add firebase child node
                        let child = ["/profile/\(String(describing: idText))": profile]
                        
                        //Write data to Firebase
                        firebase.updateChildValues(child)
                        self.messageFrame.removeFromSuperview()
                        
                    }
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
            }
            //confirm downloading.
            self.progressBarDisplayer(msg: "Uploading...", true)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            firebase = FIRDatabase.database().reference()
            firebase.child("profile").observe(.value, with: { snapshot in
                for item in snapshot.children {
                    let child = item as! FIRDataSnapshot
                    let dict = child.value as! NSDictionary
                    
                    let profile = Profile(dictionary: dict)
                    self.profiles_edit.append(profile)
                }
                self.messageFrame.removeFromSuperview()
                self.navigationController?.popViewController(animated: true)
            })
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let child = ["/profile/\(String(describing: self.selectID!))": profile]
            self.firebase.updateChildValues(child)
            
            //confirm donwnloading.
            self.progressBarDisplayer(msg: "Updating...", true)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            firebase = FIRDatabase.database().reference()
            firebase.child("profile").observe(.value, with: { snapshot in
                for item in snapshot.children {
                    let child = item as! FIRDataSnapshot
                    let dict = child.value as! NSDictionary
                    
                    let profile = Profile(dictionary: dict)
                    self.profiles_edit.append(profile)
                }
                self.messageFrame.removeFromSuperview()
                self.navigationController?.popViewController(animated: true)
            })
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    @IBAction func ProfileImageButton(_ sender: UIButton) {
        
        self.imagePicker.allowsEditing = false
        self.imagePicker.delegate = self
        self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.imagePicker.modalPresentationStyle = .popover
        self.imagePicker.sourceType = .photoLibrary// or savedPhotoAlbume
        self.present(self.imagePicker, animated: true, completion: nil)
        
    }
    
    // UIImagePickerControllerDelegate Mehtods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImage.backgroundColor = UIColor.clear
            self.profileImage.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func BgColorButton(_ sender: UIButton) {
        if bgBool {
            self.bgBool = false
            UIView.transition(with: self.colorTable, duration: 0.5, options: .transitionCurlDown, animations: { self.colorTable.isHidden = false }, completion: nil)
        }else {
            self.bgBool = true
            UIView.transition(with: self.colorTable, duration: 0.5, options: .transitionCurlUp, animations: { self.colorTable.isHidden = true }, completion: nil)
        }
        
    }
    
    @IBAction func GenderButton(_ sender: UIButton) {
        if genderBool {
            self.genderBool = false
            UIView.transition(with: self.genderTable, duration: 0.5, options: .transitionCurlDown, animations: { self.genderTable.isHidden = false }, completion: nil)
        }else {
            self.genderBool = true
            UIView.transition(with: self.genderTable, duration: 0.5, options: .transitionCurlUp, animations: { self.genderTable.isHidden = true }, completion: nil)
        }
    }
    
    //Tableview delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.genderTable {
            return self.genderArray.count
        }else {
            return self.colorArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.genderTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "gender", for: indexPath)
            cell.textLabel?.text = genderArray[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.backgroundColor = UIColor.clear
            cell.layer.backgroundColor = UIColor.clear.cgColor
            
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "color", for: indexPath)
            cell.textLabel?.text = colorArray[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.backgroundColor = UIColor.clear
            cell.layer.backgroundColor = UIColor.clear.cgColor
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.genderTable {
            self.genderBool = true
            self.gender.text = "  \(genderArray[indexPath.row])"
            self.gender.textColor = UIColor.black
            UIView.transition(with: self.genderTable, duration: 0.5, options: .transitionCurlUp, animations: { self.genderTable.isHidden = true }, completion: nil)
        }else {
            self.bgBool = true
            self.bgColor.text = "  \(colorArray[indexPath.row])"
            self.bgColor.textColor = UIColor.black
            UIView.transition(with: self.colorTable, duration: 0.5, options: .transitionCurlUp, animations: { self.colorTable.isHidden = true }, completion: nil)
        }
    }
    
}
