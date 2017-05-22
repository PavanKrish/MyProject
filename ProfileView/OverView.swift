//
//  OverView.swift
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


@objc protocol OverViewDelegate{
    @objc optional func profileImageDelegate(imagePicker: UIImagePickerController)
}
//
//protocol OverViewDelegate: class {
//    func profileImageDelegate(overlayView: OverView)
//}

class OverView: UIView, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    public var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var controller: UIViewController!
    
    var style: Style = .light
    let statusBarStyle: UIStatusBarStyle = UIApplication.shared.statusBarStyle
    var closeButton: UIButton!
    let backgroundcolor = UIColor.clear
    
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
    
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var genderTable: UITableView!
    @IBOutlet weak var hobby: UITextField!
    @IBOutlet weak var bgColor: UILabel!
    @IBOutlet weak var colorTable: UITableView!
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
    
    weak var overDelegate: OverViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    required init() {
        super.init(frame: CGRect.zero)
        let frame = CGRect(x: 0, y: 60, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 60)
        self.frame = frame
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
        self.backgroundColor?.withAlphaComponent(0.1)
        
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
        self.backgroundColor?.withAlphaComponent(0.1)
        
        // Initialization code
        self.progressBarDisplayer(msg: "Loading", true)
        KeyboardAvoiding.avoidingView = self.avoidingView
        //Firebase reference path
        self.firebase = FIRDatabase.database().reference()
        //ImagePicker Delegate confirm
        
        
        //self.controller = ViewContainer()
        var window = UIApplication.shared.keyWindow
        window = UIApplication.shared.windows.first
        //window?.rootViewController?.addChildViewController(control1)
        self.imagePicker.delegate = window?.rootViewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        //        self.genderTable.isHidden = true
        //        self.colorTable.isHidden = true
        //        //specificial cell register
        //        self.genderTable.register(UITableViewCell.self, forCellReuseIdentifier: "gender")
        //        self.colorTable.register(UITableViewCell.self, forCellReuseIdentifier: "color")
        
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
        }
        self.messageFrame.removeFromSuperview()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func open() {
        layer.removeAllAnimations()
        var window = UIApplication.shared.keyWindow
        if window == nil {
            window = UIApplication.shared.windows.first
        }
        if closeButton == nil {
            closeButton = UIButton(type: .system)
            closeButton.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            
            let image = UIImage(named: "close-Icon")?.withRenderingMode(.alwaysTemplate)
            closeButton.setImage(image, for: UIControlState())
        }
        self.addSubview(closeButton)
        
        /**
         HINT:
         To get the status bar to change color, dont forget to
         set UIViewControllerBasedStatusBarAppearance = No in info.plist
         */
        switch style {
        case .dark:
            closeButton.tintColor = UIColor.white
            UIApplication.shared.statusBarStyle = .lightContent
            break
        default:
            closeButton.tintColor = UIColor.darkGray
            UIApplication.shared.statusBarStyle = .default
        }
        
        layer.add(presentationAnimation, forKey: "present")
        
        window?.rootViewController?.view.subviews.first?.addSubview(self)
    }
    
    func dismissView() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.alpha = 0.0
        }, completion: { [unowned self]  (comlete) in
            self.removeFromSuperview()
            self.alpha = 1
            self.transform = CGAffineTransform.identity
            UIApplication.shared.statusBarStyle = self.statusBarStyle
        })
        
        //delegate?.didDismissView(self)
        
        
    }
    
    
    
    //Making ProgressView.
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        print(msg)
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 245, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.white
        messageFrame = UIView(frame: CGRect(x: self.frame.midX - 100, y: self.frame.midY - 25 , width: 215, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.5)
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        self.addSubview(messageFrame)
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
    
    // UIImagePickerControllerDelegate Mehtods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: UIImage? = nil
        
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.profileImage.image = image
        
        var window = UIApplication.shared.keyWindow
        window = UIApplication.shared.windows.first
        
        window?.rootViewController?.view.removeFromSuperview()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        var window = UIApplication.shared.keyWindow
        window = UIApplication.shared.windows.first
        window?.rootViewController?.dismiss(animated: true, completion: nil)
        
        
        
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
    
    @IBAction func ProfileImageButton(_ sender: UIButton) {
        
        self.imagePicker.allowsEditing = false
        self.imagePicker.delegate = self
        self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.imagePicker.modalPresentationStyle = .popover
        self.imagePicker.sourceType = .photoLibrary
        
        
        //overDelegate?.profileImageDelegate!(imagePicker: self.imagePicker)
        let control = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "container") as! ViewContainer
        //self.controller = ViewContainer()
        var window = UIApplication.shared.keyWindow
        window = UIApplication.shared.windows.first
        window?.rootViewController?.addChildViewController(control)
        
        control.present(self.imagePicker, animated: true, completion: nil)
        
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
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
