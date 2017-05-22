//
//  ViewContainer.swift
//  ProfileView
//
//  Created by User on 5/17/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit

class ViewContainer: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var presentationAnimation: CAAnimationGroup {
        get{
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.fromValue = 0.0
            fadeAnimation.toValue = 1.0
            fadeAnimation.duration = 0.5
            fadeAnimation.fillMode = kCAFillModeForwards
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.toValue = 1.0
            scaleAnimation.fromValue = 0.8
            scaleAnimation.duration = 0.5
            scaleAnimation.fillMode = kCAFillModeForwards
            
            let groupAnimation = CAAnimationGroup()
            groupAnimation.duration = 0.5
            groupAnimation.animations = [fadeAnimation, scaleAnimation]
            groupAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            return groupAnimation
        }
    }
    
    @IBOutlet weak var addView: UIView!
    
    let allViewsInXibArray = Bundle.main.loadNibNamed("Overlay", owner: OverView(), options: nil)
    
    //If you only have one view in the xib and you set it's class to MyView class
    
    
    
    var overView: OverView = OverView()
    @IBOutlet weak var deletButton: UIButton!
    // transition data to transite in ProfileViewController
    var ProfileArray: [Profile]!
    var Profiles: Profile!
    var selectID: String!
    var edit: Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.black
        overView = allViewsInXibArray?.first as! OverView
        overView.overDelegate = self
        
        self.open()
    }
    
    //Open OVerlay View.
    func open() {
        
        //Get all views in the xib
        let allViewsInXibArray = Bundle.main.loadNibNamed("Overlay", owner: OverView(), options: nil)
        
        //If you only have one view in the xib and you set it's class to MyView class
        let myView = allViewsInXibArray?.first as! OverView
        
        //Set wanted position and size (frame)
        myView.frame = self.view.bounds
        
        //Add the view
        self.view.layer.removeAllAnimations()
        self.view.layer.add(presentationAnimation, forKey: "present")
        self.view.addSubview(myView)
        
    }
    
    func dismissView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.view.alpha = 0.0
        }, completion: { [unowned self]  (comlete) in
            self.overView.removeFromSuperview()
            self.view.alpha = 1
            self.view.transform = CGAffineTransform.identity
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SaveButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        
    }
    @IBAction func DeleteButton(_ sender: UIButton) {
    }
    
    @IBAction func imageprofile(_sender: UIButton){
        
    }
}

extension ViewContainer: OverViewDelegate {
    
    func profileImageDelegate(imagePicker: UIImagePickerController) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
}

