//
//  OverlayView.swift
//  ProfileView
//
//  Created by User on 5/17/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit

enum Style: Int {
    case light, dark
}

class OverlayView: UIView {
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
    
    required init() {
        super.init(frame: CGRect.zero)
        let frame = UIScreen.main.bounds
        self.frame = frame
        self.isOpaque = false
        self.backgroundColor = backgroundcolor
        self.backgroundColor?.withAlphaComponent(0.1)
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
    
    
}
